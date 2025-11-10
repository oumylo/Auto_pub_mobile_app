import 'package:auto_pub_mobil_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

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
      }
    } catch (_) {}
  }

  Future<void> pickLogo() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) setState(() => _logo = File(pickedFile.path));
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
        _currentStep = 2;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inscription réussie ! Vérifiez votre email pour le code.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur d\'inscription : $e')));
    }
  }

  Future<void> confirmSignup() async {
    if (_codeController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final res = await Amplify.Auth.confirmSignUp(
        username: _emailController.text.trim(),
        confirmationCode: _codeController.text.trim(),
      );

      if (res.isSignUpComplete) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte confirmé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomePage(
                  userName: _nomController.text,
                  userRole: 'annonceur',
                ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            _currentStep > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    if (_currentStep == 2) {
                      setState(() => _currentStep = 1);
                    } else if (_currentStep == 1) {
                      setState(() => _currentStep = 0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                )
                : IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _getFormStep(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getFormStep() {
    switch (_currentStep) {
      case 0:
        return [
          const SizedBox(height: 20),
          const Text(
            'Créer un Compte Entreprise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rejoignez votre plateforme publicitaire',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 40),
          const Text(
            'Nom de l\'Entreprise',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('ABC Technologie', _nomController),
          const SizedBox(height: 20),
          const Text(
            'Email Professionnel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('contact@entreprise.sn', _emailController),
          const SizedBox(height: 20),
          const Text(
            'Contact',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('+221 XX XXX XX XX', _phoneController),
          const SizedBox(height: 20),
          const Text(
            'Mot de Passe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildPasswordField('********', _passwordController, true),
          const SizedBox(height: 40),
          const Text(
            'Confirmer le Mot de Passe',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildPasswordField('********', _confirmPasswordController, false),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 86, 85, 85),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),

                  child: const Text(
                    '← Précédent',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _currentStep = 1);
                            }
                          },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDB60A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Suivant →',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ];

      case 1:
        return [
          const SizedBox(height: 20),
          const Text(
            'Créer un Compte Entreprise',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Naviguez votre plateforme publicitaire',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 86, 85, 85),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Domaine d\'activité',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField(
            'Ressources renouvelables',
            _domaineActiviteController,
          ),
          const SizedBox(height: 20),
          const Text(
            'Adresse',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('Mermoz, rue 124', _adresseController),
          const SizedBox(height: 20),
          const Text(
            'Logo de l\'entreprise',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: pickLogo,
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color.fromARGB(255, 86, 85, 85)),
              ),
              child:
                  _logo == null
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.cloud_upload_outlined,
                              size: 32,
                              color: Color.fromARGB(255, 86, 85, 85),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Choisir pour télécharger',
                            style: TextStyle(
                              color: Color.fromARGB(255, 86, 85, 85),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'JPG, PNG ou PDF (MAX 5MB)',
                            style: TextStyle(
                              color: Color.fromARGB(255, 86, 85, 85),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.file(_logo!, fit: BoxFit.cover),
                      ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDB60A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Créer mon Compte',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {},
              child: RichText(
                text: const TextSpan(
                  text: 'Déjà un compte ? ',
                  style: TextStyle(color: Colors.black, fontSize: 14),
                  children: [
                    TextSpan(
                      text: 'Se connecter',
                      style: TextStyle(
                        color: Color(0xFFFDB60A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ];

      case 2:
        return [
          const SizedBox(height: 20),
          const Text(
            'Confirmation du compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Un code de confirmation a été envoyé à votre email.',
            style: TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 86, 85, 85),
            ),
          ),
          const SizedBox(height: 40),
          const Text(
            'Code de confirmation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('Entrez le code', _codeController),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : confirmSignup,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDB60A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : const Text(
                        'Confirmer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          ),
          const SizedBox(height: 20),
        ];

      default:
        return [];
    }
  }

  Widget _buildModernTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType:
          controller == _phoneController
              ? TextInputType.phone
              : (controller == _emailController
                  ? TextInputType.emailAddress
                  : TextInputType.text),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 86, 85, 85),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFFFDB60A), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Champ requis';
        }

        // Validation email
        if (controller == _emailController) {
          final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
          if (!emailRegex.hasMatch(val.trim())) {
            return 'Entrez une adresse email valide';
          }
        }
        if (controller == _phoneController) {
          final phoneRegex = RegExp(r'^[0-9+ ]+$');
          if (!phoneRegex.hasMatch(val.trim())) {
            return 'Le contact ne doit contenir que des chiffres';
          }
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField(
    String hint,
    TextEditingController controller,
    bool first,
  ) {
    final visible = first ? _obscurePassword : _obscureConfirmPassword;
    return TextFormField(
      controller: controller,
      obscureText: visible,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color.fromARGB(255, 86, 85, 85),
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFFDB60A), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off : Icons.visibility,
            color: Color.fromARGB(255, 86, 85, 85),
          ),
          onPressed:
              () => setState(() {
                if (first) {
                  _obscurePassword = !_obscurePassword;
                } else {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                }
              }),
        ),
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return 'Champ requis';
        }

        // Vérifie que les mots de passe correspondent
        if (!first && val != _passwordController.text) {
          return 'Les mots de passe ne correspondent pas';
        }

        // Optionnel : longueur minimale du mot de passe
        if (first && val.length < 6) {
          return 'Le mot de passe doit contenir au moins 6 caractères';
        }

        return null;
      },
    );
  }
}
