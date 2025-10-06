import 'package:auto_pub_mobil_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class SignupAnnonceurPage extends StatefulWidget {
  const SignupAnnonceurPage({super.key});

  @override
  _SignupAnnonceurPageState createState() => _SignupAnnonceurPageState();
}

class _SignupAnnonceurPageState extends State<SignupAnnonceurPage> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();
  final _domaineActiviteController = TextEditingController();
  final _adresseController = TextEditingController();

  File? _logo;
  bool _isSignedUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _checkAndSignOut();
  }

  Future<void> _checkAndSignOut() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();
      if (session.isSignedIn) {
        await Amplify.Auth.signOut();
        print('Utilisateur déconnecté au démarrage');
      }
    } catch (e) {
      print('Erreur lors de la vérification de session : $e');
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    _domaineActiviteController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _logo = File(pickedFile.path));
    }
  }

  Future<String?> uploadLogo(File file, String userId) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final key = 'public/logos/$userId-$timestamp.png';

      final result =
          await Amplify.Storage.uploadFile(
            localFile: AWSFile.fromPath(file.path),
            path: StoragePath.fromString(key),
            options: StorageUploadFileOptions(
              metadata: {
                'userId': userId,
                'type': 'logo',
                'uploadedAt': timestamp.toString(),
              },
            ),
          ).result;

      print('✅ Logo uploadé : ${result.uploadedItem.path}');
      return result.uploadedItem.path;
    } catch (e) {
      print('❌ Erreur upload logo : $e');
      return null;
    }
  }

  Future<bool> saveAnnonceurToDynamo(String userId, String logoKey) async {
    try {
      final mutation = '''
      mutation CreateAnnonceur {
        createAnnonceur(input: {
          id: "$userId",
          nom: "${_nomController.text}",
          email: "${_emailController.text}",
          telephone: "${_phoneController.text}",
          domaineActivite: "${_domaineActiviteController.text}",
          adresse: "${_adresseController.text}",
          logoUrl: "$logoKey"
        }) {
          id
        }
      }
      ''';

      final request = GraphQLRequest(document: mutation);
      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isEmpty) {
        print('Annonceur créé dans DynamoDB');
        return true;
      } else {
        print('Erreur création annonceur DynamoDB : ${response.errors}');
        return false;
      }
    } catch (e) {
      print('Exception création annonceur DynamoDB : $e');
      return false;
    }
  }

  Future<void> signup() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Amplify.Auth.signOut().catchError((_) {});

      await Amplify.Auth.signUp(
        username: _emailController.text.trim(),
        password: _passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: _emailController.text.trim(),
            AuthUserAttributeKey.name: _nomController.text,
            AuthUserAttributeKey.phoneNumber: _phoneController.text,
            const CognitoUserAttributeKey.custom('custom:role'): 'annonceur',
          },
        ),
      );

      setState(() {
        _isSignedUp = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inscription réussie ! Vérifiez votre email pour le code.',
          ),
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      print('Erreur signup : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur d\'inscription: $e')));
    }
  }

  Future<void> confirmSignupAndUploadLogo() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer le code de confirmation'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final confirmRes = await Amplify.Auth.confirmSignUp(
        username: _emailController.text.trim(),
        confirmationCode: _codeController.text.trim(),
      );

      if (confirmRes.isSignUpComplete) {
        final signInRes = await Amplify.Auth.signIn(
          username: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (signInRes.isSignedIn && _logo != null) {
          final user = await Amplify.Auth.getCurrentUser();
          final logoKey = await uploadLogo(_logo!, user.userId);

          if (logoKey != null) {
            await saveAnnonceurToDynamo(user.userId, logoKey);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Compte confirmé, logo uploadé et annonceur enregistré avec succès !',
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            await Future.delayed(const Duration(seconds: 1));

            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(userName: '', userRole: ''),
                ),
                (route) => false,
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Compte confirmé mais erreur lors de l\'upload du logo',
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Erreur confirmation : $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur de confirmation: $e')));
    }

    setState(() => _isLoading = false);
  }

  List<Widget> getFormStep() {
    switch (_currentStep) {
      case 0:
        return [
          const Icon(Icons.business_outlined, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Créer un compte annonceur',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _nomController,
            decoration: const InputDecoration(
              labelText: 'Nom de l\'entreprise',
              prefixIcon: Icon(Icons.business),
              border: OutlineInputBorder(),
            ),
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.emailAddress,
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Numéro de téléphone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              hintText: '+221XXXXXXXXX',
            ),
            keyboardType: TextInputType.phone,
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed:
                    () => setState(() {
                      _obscurePassword = !_obscurePassword;
                    }),
              ),
            ),
            obscureText: _obscurePassword,
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmer mot de passe',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                ),
                onPressed:
                    () => setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    }),
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _currentStep = 1);
              }
            },
            child: const Text(
              'Suivant',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ];

      case 1:
        return [
          const Icon(Icons.store_outlined, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Détails de l\'entreprise',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _domaineActiviteController,
            decoration: const InputDecoration(
              labelText: 'Domaine d\'activité',
              prefixIcon: Icon(Icons.work_outline),
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _adresseController,
            decoration: const InputDecoration(
              labelText: 'Adresse',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
            validator:
                (val) => val == null || val.isEmpty ? 'Champ requis' : null,
          ),
          const SizedBox(height: 20),
          const Text(
            'Logo de l\'entreprise',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: pickLogo,
            icon: const Icon(Icons.image),
            label: Text(_logo == null ? 'Choisir un logo' : 'Changer le logo'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_logo != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _logo!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_domaineActiviteController.text.isNotEmpty &&
                  _adresseController.text.isNotEmpty &&
                  _logo != null) {
                signup();
                setState(() => _currentStep = 2);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Veuillez remplir tous les champs et choisir un logo',
                    ),
                  ),
                );
              }
            },
            child: const Text(
              'Suivant',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _currentStep = 0),
            child: const Text(
              'Retour',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ];

      case 2:
        return [
          const Icon(
            Icons.verified_user_outlined,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Confirmation du compte',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Un code de confirmation a été envoyé à votre email.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          TextFormField(
            controller: _codeController,
            decoration: const InputDecoration(
              labelText: 'Code de confirmation',
              prefixIcon: Icon(Icons.pin_outlined),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 25),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isLoading ? null : confirmSignupAndUploadLogo,
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                      'Confirmer et finaliser l\'inscription',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => setState(() => _currentStep = 1),
            child: const Text(
              'Retour',
              style: TextStyle(color: Colors.blueAccent),
            ),
          ),
        ];

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: getFormStep(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
