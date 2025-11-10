import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:http/http.dart' as http;

class CampagneFormPage extends StatefulWidget {
  const CampagneFormPage({super.key});

  @override
  State<CampagneFormPage> createState() => _CampagneFormPageState();
}

class _CampagneFormPageState extends State<CampagneFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _budgetController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> zonesDisponibles = [
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
  List<String> zonesChoisies = [];
  File? _image;
  bool _loading = false;
  List<dynamic> propositions = [];
  String? _campagneId;
  String? propositionChoisie;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = File(pickedFile.path));
  }

  Future<void> _sendNotificationEnAttente(
    String ownerId,
    String titreCampagne,
  ) async {
    try {
      final now = DateTime.now();
      final dateFormatted =
          "${now.day}/${now.month}/${now.year} à ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

      final request = GraphQLRequest<String>(
        document: '''
        mutation CreateNotification(\$input: CreateNotificationInput!) {
          createNotification(input: \$input) {
            id
            titre
            message
            owner
          }
        }
        ''',
        variables: {
          'input': {
            'owner': ownerId,
            'titre': 'Campagne "$titreCampagne" - Validation en attente',
            'message':
                'Votre campagne "$titreCampagne" a été soumise le $dateFormatted. Elle est en cours de traitement. Nous reviendrons vers vous dès que l\'administrateur validera votre campagne.',
            'lue': false,
          },
        },
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isEmpty) {
        safePrint(
          '✅ Notification en attente envoyée à $ownerId pour "$titreCampagne"',
        );
      } else {
        safePrint('❌ Erreurs GraphQL : ${response.errors}');
      }
    } catch (e) {
      safePrint('❌ Erreur création notification en attente : $e');
    }
  }

  Future<void> _creerCampagne() async {
    if (!_formKey.currentState!.validate() || zonesChoisies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner au moins une zone'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = await Amplify.Auth.getCurrentUser();
      final input = {
        "titre": _titreController.text.trim(),
        "budget": double.parse(_budgetController.text.replaceAll(' ', '')),
        "zonesCibles": zonesChoisies,
        "description": _descriptionController.text.trim(),
        "visuelUrl": _image?.path ?? "",
        "owner": user.userId,
        "statut": "EN_ATTENTE",
      };

      final request = GraphQLRequest<String>(
        document: '''
        mutation CreateCampagne(\$input: CreateCampagneInput!) {
          createCampagne(input: \$input) {
            id
            titre
            owner
            statut
          }
        }
        ''',
        variables: {'input': input},
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isEmpty) {
        final data = jsonDecode(response.data!);
        _campagneId = data['createCampagne']['id'];

        safePrint('✅ Campagne créée avec ID: $_campagneId');
        await _sendNotificationEnAttente(
          user.userId,
          _titreController.text.trim(),
        );
        await _obtenirPropositions(_campagneId!);
      } else {
        throw 'Erreur GraphQL: ${response.errors.first.message}';
      }
    } catch (e) {
      safePrint('❌ Erreur complète: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _obtenirPropositions(String campagneId) async {
    setState(() => _loading = true);
    try {
      const apiUrl =
          'https://76mfcvkaoi.execute-api.eu-north-1.amazonaws.com/offre/autopub_offre_api';
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'campagne_id': campagneId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> offres = data is List ? data : (data['offres'] ?? [data]);
        setState(() => propositions = offres);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur API IA : ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _publierCampagne(String proposition) async {
    if (_campagneId == null) return;
    setState(() => _loading = true);

    try {
      final user = await Amplify.Auth.getCurrentUser();
      final input = {"id": _campagneId, "propositionChoisie": proposition};

      final request = GraphQLRequest<String>(
        document: '''
        mutation UpdateCampagne(\$input: UpdateCampagneInput!) {
          updateCampagne(input: \$input) {
            id
            propositionChoisie
            statut
          }
        }
        ''',
        variables: {'input': input},
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isEmpty) {
        safePrint('✅ Campagne publiée avec succès');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Campagne soumise avec succès ! En attente de validation.",
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );

          setState(() {
            propositions = [];
            propositionChoisie = null;
            _campagneId = null;
          });

          _titreController.clear();
          _budgetController.clear();
          _descriptionController.clear();
          zonesChoisies.clear();
          _image = null;
        }
      } else {
        throw response.errors.first.message;
      }
    } catch (e) {
      safePrint('❌ Erreur publication campagne: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Map<String, dynamic> _parseProposition(dynamic proposition) {
    try {
      if (proposition is Map<String, dynamic>) {
        return {
          'categorie':
              proposition['categorie']?.toString() ??
              proposition['type']?.toString() ??
              'Standard',
          'nbVehicules':
              proposition['nb_vehicules']?.toString() ??
              proposition['vehicules']?.toString() ??
              proposition['nombre_vehicules']?.toString() ??
              '0',
          'duree':
              proposition['duree']?.toString() ??
              proposition['semaines']?.toString() ??
              proposition['duree_semaines']?.toString() ??
              '0',
          'support':
              proposition['type_support']?.toString() ??
              proposition['support']?.toString() ??
              proposition['publicite']?.toString() ??
              'VINYLES',
        };
      }

      String propStr = proposition.toString();
      try {
        if (propStr.startsWith('{')) {
          Map<String, dynamic> parsed = jsonDecode(propStr);
          return _parseProposition(parsed);
        }
      } catch (e) {
        safePrint('Non-JSON proposition: $propStr');
      }

      // Par défaut
      return {
        'categorie': 'Standard',
        'nbVehicules': '0',
        'duree': '0',
        'support': 'VINYLES',
      };
    } catch (e) {
      safePrint('Erreur parsing proposition: $e');
      return {
        'categorie': 'Standard',
        'nbVehicules': '0',
        'duree': '0',
        'support': 'VINYLES',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Campagnes",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF7900)),
              )
              : propositions.isEmpty
              ? _buildForm()
              : _buildPropositions(),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Configurer Votre Campagne",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              _buildInput(_titreController, "Titre de la Campagne"),
              const SizedBox(height: 14),

              _buildBudgetInput(),
              const SizedBox(height: 14),

              _buildDropdownZone(),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  zonesChoisies.isEmpty
                      ? "Aucune zone sélectionnée"
                      : "Zones : ${zonesChoisies.join(', ')}",
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),

              _buildInput(_descriptionController, "Description", maxLines: 3),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _creerCampagne,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDA800),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Voir les possibilités",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
        validator: (v) => v!.isEmpty ? "Champ requis" : null,
      ),
    );
  }

  Widget _buildBudgetInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: "Budget (min 150 000 FCFA)",
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(12),
        ),
        validator: (v) {
          if (v == null || v.isEmpty) return "Champ requis";
          final montant = double.tryParse(v.replaceAll(' ', ''));
          if (montant == null || montant < 150000) {
            return "Montant invalide ou trop petit";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdownZone() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(border: InputBorder.none),
        hint: const Text("Choisir une zone"),
        items:
            zonesDisponibles
                .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                .toList(),
        onChanged: (val) {
          if (val != null && !zonesChoisies.contains(val)) {
            setState(() => zonesChoisies.add(val));
          }
        },
      ),
    );
  }

  Widget _buildPropositions() {
    return Column(
      children: [
        // En-tête avec bouton retour
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFFFF3E0),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Choisissez une offre puis cliquez sur Soumettre',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child:
              propositions.isEmpty
                  ? const Center(
                    child: Text(
                      'Aucune proposition disponible',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: propositions.length,
                    itemBuilder: (context, index) {
                      final p = propositions[index];
                      final isSelected = propositionChoisie == p.toString();

                      final data = _parseProposition(p);

                      return GestureDetector(
                        onTap: () {
                          setState(() => propositionChoisie = p.toString());
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: isSelected ? 4 : 2,
                          color:
                              isSelected
                                  ? const Color(0xFFFFF3E0)
                                  : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // En-tête avec catégorie et radio
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Catégorie
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDA800),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        data['categorie'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    // Radio button
                                    Radio<String>(
                                      value: p.toString(),
                                      groupValue: propositionChoisie,
                                      activeColor: const Color(0xFFFF7900),
                                      onChanged: (val) {
                                        setState(
                                          () => propositionChoisie = val,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                                // Informations horizontales
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    // Nombre de véhicules
                                    _buildInfoItem(
                                      icon: Icons.directions_car,
                                      value: data['nbVehicules'],
                                      label: 'Véhicules',
                                    ),

                                    // Durée
                                    _buildInfoItem(
                                      icon: Icons.calendar_today,
                                      value: '${data['duree']} sem',
                                      label: 'Durée',
                                    ),

                                    // Support
                                    _buildInfoItem(
                                      icon: Icons.campaign,
                                      value: data['support'],
                                      label: 'Support',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),

        // Bouton de soumission
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  propositionChoisie == null
                      ? null
                      : () => _publierCampagne(propositionChoisie!),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFDA800),
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                propositionChoisie == null
                    ? "Sélectionnez une offre"
                    : "Soumettre la campagne",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color:
                      propositionChoisie == null ? Colors.grey : Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget pour afficher chaque information
  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFF7900), size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
