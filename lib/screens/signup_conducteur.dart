import 'package:auto_pub_mobil_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';


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
  int _currentStep = 0;

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

      setState(() {
        _isSignedUp = true;
        _isLoading = false;
        _currentStep = 3;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Inscription réussie ! Vérifiez votre email pour le code.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
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
                builder:
                    (context) => HomePage(
                      userName: _nomController.text,
                      userRole: 'conducteur',
                    ),
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
                    if (_currentStep == 3) {
                      setState(() => _currentStep = 2);
                    } else if (_currentStep == 2) {
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
            'Créer un Compte Conducteur',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Rejoignez notre réseau de conducteurs',
            style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 40),
          const Text(
            'Nom Complet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('Prénom Nom', _nomController),
          const SizedBox(height: 20),
          const Text(
            'Email',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('votre.email@exemple.sn', _emailController),
          const SizedBox(height: 20),
          const Text(
            'Téléphone',
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
          const SizedBox(height: 20),
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
                    side: const BorderSide(color: Color(0xFF616161)),
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
            'Informations Véhicule',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Détails sur votre véhicule et zones',
            style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 40),
          const Text(
            'Type de Voiture',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernDropdown(
            value: _typeVoiture,
            items: _typesVoiture,
            hint: 'Sélectionnez le type',
            onChanged: (val) => setState(() => _typeVoiture = val),
          ),
          const SizedBox(height: 20),
          const Text(
            'Type de Support',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernDropdown(
            value: _typeSupport,
            items: _typesSupport,
            hint: 'Sélectionnez le support',
            onChanged: (val) => setState(() => _typeSupport = val),
          ),
          const SizedBox(height: 20),
          const Text(
            'Zones Fréquentées',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _zonesDisponibles.map((zone) {
                  final isSelected = _zonesFrequentees.contains(zone);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected
                            ? _zonesFrequentees.remove(zone)
                            : _zonesFrequentees.add(zone);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFFDB60A)
                                : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        zone,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          const Text(
            'Heures de Conduite',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernDropdown(
            value: _heuresConduite,
            items: _heuresDisponibles,
            hint: 'Sélectionnez les heures',
            onChanged: (val) => setState(() => _heuresConduite = val),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        if (_formKey.currentState!.validate() &&
                            _zonesFrequentees.isNotEmpty) {
                          setState(() => _currentStep = 2);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Sélectionnez au moins une zone'),
                              backgroundColor: Colors.red,
                            ),
                          );
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
          const SizedBox(height: 20),
        ];

      case 2:
        return [
          const SizedBox(height: 20),
          const Text(
            'Documents Requis',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Téléchargez vos documents d\'identification',
            style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 40),
          _buildModernDocumentCard(
            'Carte d\'Identité (Recto)',
            _ciRecto,
            () => pickFile((f) => _ciRecto = f, 'CI Recto'),
          ),
          const SizedBox(height: 16),
          _buildModernDocumentCard(
            'Carte d\'Identité (Verso)',
            _ciVerso,
            () => pickFile((f) => _ciVerso = f, 'CI Verso'),
          ),
          const SizedBox(height: 16),
          _buildModernDocumentCard(
            'Carte Grise (Recto)',
            _cgRecto,
            () => pickFile((f) => _cgRecto = f, 'CG Recto'),
          ),
          const SizedBox(height: 16),
          _buildModernDocumentCard(
            'Carte Grise (Verso)',
            _cgVerso,
            () => pickFile((f) => _cgVerso = f, 'CG Verso'),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _isLoading
                      ? null
                      : () {
                        if (_ciRecto != null &&
                            _ciVerso != null &&
                            _cgRecto != null &&
                            _cgVerso != null) {
                          signup();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Veuillez sélectionner tous les documents',
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
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
                        'Créer mon Compte',
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

      case 3:
        return [
          const SizedBox(height: 20),
          const Text(
            'Confirmation du Compte',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Un code de confirmation a été envoyé à votre email.',
            style: TextStyle(fontSize: 14, color: Color(0xFF616161)),
          ),
          const SizedBox(height: 40),
          const Text(
            'Code de Confirmation',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildModernTextField('Entrez le code', _codeController),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: _isLoading ? null : resendConfirmationCode,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFFDB60A)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Renvoyer le code',
              style: TextStyle(
                color: Color(0xFFFDB60A),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : confirmSignupAndUploadDocuments,
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
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFDB60A), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
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
        hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFDB60A), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            visible ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF616161),
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
      validator: (val) => val == null || val.isEmpty ? 'Champ requis' : null,
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF616161), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFDB60A), width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      items:
          items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
      onChanged: onChanged,
      validator: (val) => val == null ? 'Champ requis' : null,
    );
  }

  Widget _buildModernDocumentCard(
    String title,
    File? file,
    VoidCallback onPick,
  ) {
    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                file != null
                    ? const Color(0xFFFDB60A)
                    : const Color(0xFF616161),
            width: file != null ? 2 : 1,
          ),
        ),
        child:
            file == null
                ? Column(
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
                        color: Color(0xFF616161),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'JPG, PNG (MAX 5MB)',
                      style: TextStyle(color: Color(0xFF616161), fontSize: 12),
                    ),
                  ],
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFFFDB60A),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
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
                    Text(
                      'Appuyez pour changer',
                      style: TextStyle(color: Color(0xFF616161), fontSize: 12),
                    ),
                  ],
                ),
      ),
    );
  }
}
