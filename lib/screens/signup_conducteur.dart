import 'package:auto_pub_mobil_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';

class SignupConducteurPage extends StatefulWidget {
  const SignupConducteurPage({super.key});

  @override
  _SignupConducteurPageState createState() => _SignupConducteurPageState();
}

class _SignupConducteurPageState extends State<SignupConducteurPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  File? _ciRecto;
  File? _ciVerso;
  File? _cgRecto;
  File? _cgVerso;

  String? _typeSupport;
  String? _typeVoiture;
  final List<String> _zonesFrequentees = [];
  String? _heuresConduite;

  bool _isSignedUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  int _currentPage = 0;

  final List<String> _typesSupport = ['Ecran', 'Vinyle', 'Ecran + Vinyle'];
  final List<String> _typesVoiture = ['Taxi', 'Bus', 'Voiture particulier'];
  final List<String> _zonesDisponibles = [
    'Dakar Centre',
    'Plateau',
    'VDN',
    'Yoff',
    'Sacré-Cœur',
    'Hann',
    'Parcelles',
    'Pikine',
    'Guédiawaye',
    'Grand Dakar',
    'Grand Yoff',
  ];
  final List<String> _heuresDisponibles = [
    'Matin',
    'Soir',
    'Nuit',
    'Nuit et jour',
    'Toute la journée',
  ];

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
        safePrint('Utilisateur déconnecté au démarrage');
      }
    } catch (e) {
      safePrint('Erreur vérification session : $e');
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
    super.dispose();
  }

  Future<void> resendConfirmationCode() async {
    setState(() => _isLoading = true);

    try {
      await Amplify.Auth.resendSignUpCode(
        username: _emailController.text.trim(),
      );

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Un nouveau code a été envoyé à votre email'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> pickFile(Function(File) setFile, String documentName) async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        setFile(File(pickedFile.path));
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$documentName sélectionné')));
      }
    }
  }

  Future<String> uploadFile(File file, String userId, String filename) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final key = 'public/conducteurs/$userId/$filename-$timestamp.png';

      safePrint('Upload vers: $key');

      await Amplify.Storage.uploadFile(
        localFile: AWSFile.fromPath(file.path),
        path: StoragePath.fromString(key),
      ).result;

      safePrint('Upload réussi: $key');
      return key;
    } catch (e) {
      safePrint('Erreur upload $filename: $e');
      rethrow;
    }
  }

  Future<void> createConducteur({
    required String nom,
    required String email,
    required String telephone,
    required String typeSupport,
    required String typeVoiture,
    required List<String> zones,
    required String heuresConduite,
    String? ciRectoUrl,
    String? ciVersoUrl,
    String? cgRectoUrl,
    String? cgVersoUrl,
  }) async {
    try {
      final variables = {
        'input': {
          'nom': nom,
          'email': email,
          'telephone': telephone,
          'typeSupport': typeSupport,
          'typeVoiture': typeVoiture,
          'zones': zones,
          'heuresConduite': heuresConduite,
          if (ciRectoUrl != null) 'ciRectoUrl': ciRectoUrl,
          if (ciVersoUrl != null) 'ciVersoUrl': ciVersoUrl,
          if (cgRectoUrl != null) 'cgRectoUrl': cgRectoUrl,
          if (cgVersoUrl != null) 'cgVersoUrl': cgVersoUrl,
        },
      };

      const mutation = r'''
        mutation CreateConducteur($input: CreateConducteurInput!) {
          createConducteur(input: $input) {
            id
            nom
            email
            telephone
            typeSupport
            typeVoiture
            zones
            heuresConduite
            ciRectoUrl
            ciVersoUrl
            cgRectoUrl
            cgVersoUrl
            createdAt
            updatedAt
          }
        }
      ''';

      safePrint('Variables GraphQL: $variables');

      final request = GraphQLRequest<String>(
        document: mutation,
        variables: variables,
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isNotEmpty) {
        final errorMsg = response.errors.map((e) => e.message).join(', ');
        safePrint('Erreurs GraphQL: $errorMsg');
        throw Exception('Erreur GraphQL: $errorMsg');
      }

      safePrint('Conducteur créé avec succès');
      safePrint('Données: ${response.data}');
    } catch (e) {
      safePrint('Erreur createConducteur: $e');
      rethrow;
    }
  }

  Future<void> signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_ciRecto == null ||
        _ciVerso == null ||
        _cgRecto == null ||
        _cgVerso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner tous les documents requis'),
        ),
      );
      return;
    }

    if (_typeSupport == null ||
        _typeVoiture == null ||
        _zonesFrequentees.isEmpty ||
        _heuresConduite == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires'),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      try {
        await Amplify.Auth.signOut();
      } catch (e) {
        safePrint('Aucun utilisateur à déconnecter');
      }

      await Amplify.Auth.signUp(
        username: _emailController.text.trim(),
        password: _passwordController.text,
        options: SignUpOptions(
          userAttributes: {
            AuthUserAttributeKey.email: _emailController.text.trim(),
            AuthUserAttributeKey.name: _nomController.text,
            AuthUserAttributeKey.phoneNumber: _phoneController.text,
            const CognitoUserAttributeKey.custom('custom:role'): 'conducteur',
          },
        ),
      );

      setState(() => _isSignedUp = true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Vérifiez votre email.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> confirmSignupAndUploadDocuments() async {
    final code = _codeController.text.trim().replaceAll(RegExp(r'\s+'), '');

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrez le code de confirmation')),
      );
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le code doit contenir uniquement des chiffres'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      try {
        final session = await Amplify.Auth.fetchAuthSession();
        if (session.isSignedIn) {
          await Amplify.Auth.signOut();
        }
      } catch (e) {
        safePrint('Vérification session: $e');
      }

      final confirmRes = await Amplify.Auth.confirmSignUp(
        username: _emailController.text.trim(),
        confirmationCode: code,
      );

      if (confirmRes.isSignUpComplete) {
        final signInRes = await Amplify.Auth.signIn(
          username: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (signInRes.isSignedIn) {
          final user = await Amplify.Auth.getCurrentUser();
          final userId = user.userId;

          final ciRectoKey = await uploadFile(_ciRecto!, userId, 'ciRecto');
          final ciVersoKey = await uploadFile(_ciVerso!, userId, 'ciVerso');
          final cgRectoKey = await uploadFile(_cgRecto!, userId, 'cgRecto');
          final cgVersoKey = await uploadFile(_cgVerso!, userId, 'cgVerso');

          await createConducteur(
            nom: _nomController.text,
            email: _emailController.text.trim(),
            telephone: _phoneController.text,
            typeSupport: _typeSupport!,
            typeVoiture: _typeVoiture!,
            zones: _zonesFrequentees,
            heuresConduite: _heuresConduite!,
            ciRectoUrl: ciRectoKey,
            ciVersoUrl: ciVersoKey,
            cgRectoUrl: cgRectoKey,
            cgVersoUrl: cgVersoKey,
          );

          setState(() => _isLoading = false);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compte conducteur créé avec succès !'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            await Future.delayed(const Duration(seconds: 1));

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(userName: '', userRole: ''),
              ),
              (route) => false,
            );
          }
        }
      }
    } on CodeMismatchException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code invalide. Vérifiez votre email.'),
          backgroundColor: Colors.red,
        ),
      );
    } on ExpiredCodeException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code expiré. Demandez un nouveau code.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildDocumentCard(String title, File? file, VoidCallback onPick) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (file != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  file,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onPick,
                icon: Icon(
                  file == null ? Icons.upload_file : Icons.check_circle,
                  color: file == null ? Colors.blue : Colors.green,
                ),
                label: Text(file == null ? 'Sélectionner' : 'Sélectionné'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getPageContent() {
    switch (_currentPage) {
      case 0:
        return [
          const Icon(Icons.person_outline, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Informations personnelles',
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
              labelText: 'Nom complet',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
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
            validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: 'Téléphone',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
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
            validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
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
            validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
          ),
        ];

      case 1:
        return [
          const Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          const Text(
            'Informations véhicule',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 30),
          DropdownButtonFormField<String>(
            value: _typeVoiture,
            decoration: const InputDecoration(
              labelText: 'Type de voiture',
              prefixIcon: Icon(Icons.directions_car),
              border: OutlineInputBorder(),
            ),
            items:
                _typesVoiture
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (val) => setState(() => _typeVoiture = val),
            validator: (val) => val == null ? 'Requis' : null,
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _typeSupport,
            decoration: const InputDecoration(
              labelText: 'Type de support',
              prefixIcon: Icon(Icons.tv),
              border: OutlineInputBorder(),
            ),
            items:
                _typesSupport
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (val) => setState(() => _typeSupport = val),
            validator: (val) => val == null ? 'Requis' : null,
          ),
          const SizedBox(height: 20),
          const Text(
            'Zones fréquentées',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _zonesDisponibles.map((zone) {
                  final isSelected = _zonesFrequentees.contains(zone);
                  return FilterChip(
                    label: Text(zone),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selected
                            ? _zonesFrequentees.add(zone)
                            : _zonesFrequentees.remove(zone);
                      });
                    },
                    selectedColor: Colors.blue.shade200,
                  );
                }).toList(),
          ),
          const SizedBox(height: 15),
          DropdownButtonFormField<String>(
            value: _heuresConduite,
            decoration: const InputDecoration(
              labelText: 'Heures de conduite',
              prefixIcon: Icon(Icons.access_time),
              border: OutlineInputBorder(),
            ),
            items:
                _heuresDisponibles
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
            onChanged: (val) => setState(() => _heuresConduite = val),
            validator: (val) => val == null ? 'Requis' : null,
          ),
        ];

      case 2:
        return [
          const Icon(Icons.folder_outlined, size: 80, color: Colors.blue),
          const SizedBox(height: 16),
          const Text(
            'Documents requis',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 30),
          _buildDocumentCard(
            'CI Recto',
            _ciRecto,
            () => pickFile((f) => _ciRecto = f, 'CI Recto'),
          ),
          const SizedBox(height: 10),
          _buildDocumentCard(
            'CI Verso',
            _ciVerso,
            () => pickFile((f) => _ciVerso = f, 'CI Verso'),
          ),
          const SizedBox(height: 10),
          _buildDocumentCard(
            'CG Recto',
            _cgRecto,
            () => pickFile((f) => _cgRecto = f, 'CG Recto'),
          ),
          const SizedBox(height: 10),
          _buildDocumentCard(
            'CG Verso',
            _cgVerso,
            () => pickFile((f) => _cgVerso = f, 'CG Verso'),
          ),
        ];

      case 3:
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
            'Un code de confirmation a été envoyé à votre adresse e-mail.',
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
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: _isLoading ? null : resendConfirmationCode,
            icon: const Icon(Icons.refresh),
            label: const Text('Renvoyer le code'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(children: _getPageContent()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: OutlinedButton(
                                onPressed: () => setState(() => _currentPage--),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(0, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('Précédent'),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: _currentPage > 0 ? 8 : 0,
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  _isLoading
                                      ? null
                                      : () {
                                        if (_formKey.currentState!.validate()) {
                                          if (_currentPage < 3) {
                                            if (_currentPage == 2) {
                                              signup();
                                              setState(() => _currentPage++);
                                            } else {
                                              setState(() => _currentPage++);
                                            }
                                          } else {
                                            confirmSignupAndUploadDocuments();
                                          }
                                        } else {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Veuillez remplir tous les champs obligatoires.',
                                              ),
                                              backgroundColor: Colors.red,
                                              duration: Duration(seconds: 2),
                                            ),
                                          );
                                        }
                                      },
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : Text(
                                        _currentPage == 2
                                            ? 'S\'inscrire'
                                            : _currentPage == 3
                                            ? 'Confirmer'
                                            : 'Suivant',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
