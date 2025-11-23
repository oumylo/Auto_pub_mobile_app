import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amplify_flutter/amplify_flutter.dart';

class SelectionConducteursDialog extends StatefulWidget {
  final String campagneId;
  final String campagneTitre;
  final List<String> zonesCibles;
  final List<String>? conducteursDejaAssignes;

  const SelectionConducteursDialog({
    super.key,
    required this.campagneId,
    required this.campagneTitre,
    required this.zonesCibles,
    this.conducteursDejaAssignes,
  });

  @override
  State<SelectionConducteursDialog> createState() =>
      _SelectionConducteursDialogState();
}

class _SelectionConducteursDialogState
    extends State<SelectionConducteursDialog> {
  List<dynamic> _conducteurs = [];
  Set<String> _conducteursSelectionnes = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _conducteursSelectionnes = Set<String>.from(
      widget.conducteursDejaAssignes ?? [],
    );
    _fetchConducteursDisponibles();
  }

  Future<void> _fetchConducteursDisponibles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(
          'https://5gkqsrlvvd.execute-api.eu-north-1.amazonaws.com/default/matching_api',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'campagne_id': widget.campagneId,
          'zones_cibles': widget.zonesCibles,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final conducteurs = data['matching_result'] ?? [];

        // ⭐ Enrichir chaque conducteur avec son owner depuis GraphQL
        List<dynamic> conducteursEnrichis = [];

        for (var conducteur in conducteurs) {
          final conducteurId = conducteur['conducteur_id'];

          // Récupérer le owner depuis GraphQL
          final getConducteurRequest = GraphQLRequest<String>(
            document: '''
          query GetConducteur(\$id: ID!) {
            getConducteur(id: \$id) {
              id
              owner
              nom
              email
              telephone
              typeVoiture
              zones
            }
          }
          ''',
            variables: {'id': conducteurId},
            authorizationMode: APIAuthorizationType.userPools,
          );

          final getConducteurResponse =
              await Amplify.API.query(request: getConducteurRequest).response;

          if (getConducteurResponse.errors.isEmpty &&
              getConducteurResponse.data != null) {
            final conducteurData = jsonDecode(getConducteurResponse.data!);
            final fullConducteur = conducteurData['getConducteur'];

            // Fusionner les données
            conducteursEnrichis.add({
              ...conducteur,
              'owner': fullConducteur['owner'],
              'nom': fullConducteur['nom'],
              'email': fullConducteur['email'],
              'telephone': fullConducteur['telephone'],
              'typeVoiture': fullConducteur['typeVoiture'],
              'zones': fullConducteur['zones'],
            });
          }
        }

        setState(() {
          _conducteurs = conducteursEnrichis;
          _isLoading = false;
        });

        safePrint('✅ ${_conducteurs.length} conducteurs disponibles');
      } else {
        throw Exception(
          'Erreur API: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      safePrint('❌ Erreur fetch conducteurs: $e');
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _assignerConducteurs() async {
    try {
      // 1️⃣ Mettre à jour la campagne avec les conducteurs sélectionnés
      final updateCampagneRequest = GraphQLRequest<String>(
        document: '''
        mutation UpdateCampagne(\$input: UpdateCampagneInput!) {
          updateCampagne(input: \$input) {
            id
            conducteursAssignes
          }
        }
      ''',
        variables: {
          'input': {
            'id': widget.campagneId,
            'conducteursAssignes': _conducteursSelectionnes.toList(),
            // ❌ SUPPRIMÉ : 'conducteurOwner': _conducteursSelectionnes.toList(),
          },
        },
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response =
          await Amplify.API.mutate(request: updateCampagneRequest).response;

      if (response.errors.isEmpty) {
        safePrint('✅ Conducteurs assignés à la campagne');

        // 2️⃣ Mettre à jour le champ campagnesAssignees pour chaque conducteur
        for (String conducteurId in _conducteursSelectionnes) {
          await _updateConducteurCampagnes(conducteurId);
        }

        // 3️⃣ Envoyer une notification à chaque conducteur sélectionné
        for (String conducteurId in _conducteursSelectionnes) {
          // ⚠️ IMPORTANT : Récupérer le 'owner' du conducteur pour la notification
          final conducteur = _conducteurs.firstWhere(
            (c) => c['conducteur_id'] == conducteurId,
            orElse: () => null,
          );

          if (conducteur != null && conducteur['owner'] != null) {
            await _sendNotificationConducteur(
              conducteur['owner'], // ✅ Utiliser le owner, pas l'ID
              "Nouvelle campagne assignée",
              "Vous avez été assigné(e) à la campagne : ${widget.campagneTitre}",
            );
          }
        }

        // 4️⃣ Fermer le dialogue
        if (mounted) {
          Navigator.of(context).pop(true);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${_conducteursSelectionnes.length} conducteur(s) assigné(s)',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw response.errors.first.message;
      }
    } catch (e) {
      safePrint('❌ Erreur assignation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _updateConducteurCampagnes(String conducteurId) async {
    try {
      // 1️⃣ Récupérer d'abord les campagnes actuelles du conducteur
      final getRequest = GraphQLRequest<String>(
        document: '''
        query GetConducteur(\$id: ID!) {
          getConducteur(id: \$id) {
            id
            campagnesAssignees
          }
        }
      ''',
        variables: {'id': conducteurId},
        authorizationMode: APIAuthorizationType.userPools,
      );

      final getResponse = await Amplify.API.query(request: getRequest).response;

      List<String> campagnesExistantes = [];

      if (getResponse.errors.isEmpty && getResponse.data != null) {
        final data = jsonDecode(getResponse.data!);

        // ✅ Sécuriser l'accès avec ? et transformer le format AWS DynamoDB en List<String>
        final campagnesRaw = data['getConducteur']?['campagnesAssignees'] ?? [];
        campagnesExistantes =
            campagnesRaw.map<String>((e) {
              if (e is Map && e.containsKey('S')) return e['S'].toString();
              return e.toString();
            }).toList();
      }

      // 2️⃣ Ajouter la nouvelle campagne si elle n'existe pas déjà
      if (!campagnesExistantes.contains(widget.campagneId)) {
        campagnesExistantes.add(widget.campagneId);
      }

      // 3️⃣ Mettre à jour le conducteur
      final updateRequest = GraphQLRequest<String>(
        document: '''
        mutation UpdateConducteur(\$input: UpdateConducteurInput!) {
          updateConducteur(input: \$input) {
            id
            campagnesAssignees
          }
        }
      ''',
        variables: {
          'input': {
            'id': conducteurId,
            'campagnesAssignees': campagnesExistantes,
          },
        },
        authorizationMode: APIAuthorizationType.userPools,
      );

      await Amplify.API.mutate(request: updateRequest).response;
      safePrint(
        '✅ Conducteur $conducteurId mis à jour avec ${campagnesExistantes.length} campagne(s)',
      );
    } catch (e) {
      safePrint('❌ Erreur update conducteur $conducteurId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                const Icon(Icons.people, color: Color(0xFF0A426D), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sélectionner des conducteurs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.campagneTitre,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(height: 24),

            // Compteur de sélection
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    '${_conducteursSelectionnes.length} conducteur(s) sélectionné(s)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Liste des conducteurs
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _fetchConducteursDisponibles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                      : _conducteurs.isEmpty
                      ? const Center(
                        child: Text(
                          'Aucun conducteur disponible pour cette campagne',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _conducteurs.length,
                        itemBuilder: (context, index) {
                          final conducteur = _conducteurs[index];
                          final conducteurId =
                              conducteur['conducteur_id']; // ✅ ici
                          final isSelected = _conducteursSelectionnes.contains(
                            conducteurId,
                          );

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: isSelected ? 4 : 1,
                            color:
                                isSelected ? Colors.blue.shade50 : Colors.white,
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _conducteursSelectionnes.add(conducteurId);
                                  } else {
                                    _conducteursSelectionnes.remove(
                                      conducteurId,
                                    );
                                  }
                                });
                              },
                              title: Text(
                                conducteur['nom'] ?? 'Nom inconnu',
                                style: TextStyle(
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(conducteur['email'] ?? ''),
                                  Text(
                                    'Tel: ${conducteur['telephone'] ?? 'N/A'}',
                                  ),
                                  Text(
                                    'Véhicule: ${conducteur['typeVoiture'] ?? 'N/A'}',
                                  ),
                                  if (conducteur['zones'] != null)
                                    Wrap(
                                      spacing: 4,
                                      children:
                                          (conducteur['zones'] as List)
                                              .map(
                                                (zone) => Chip(
                                                  label: Text(
                                                    zone,
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Colors.grey.shade200,
                                                  padding: const EdgeInsets.all(
                                                    2,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                                ],
                              ),
                              isThreeLine: true,
                              activeColor: const Color(0xFF0A426D),
                            ),
                          );
                        },
                      ),
            ),

            // Boutons d'action
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _conducteursSelectionnes.isEmpty
                            ? null
                            : _assignerConducteurs,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A426D),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Assigner'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _sendNotificationConducteur(
  String ownerId,
  String titre,
  String message,
) async {
  try {
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
          'titre': titre,
          'message': message,
          'lue': false,
        },
      },
      authorizationMode: APIAuthorizationType.userPools,
    );

    final response = await Amplify.API.mutate(request: request).response;

    if (response.errors.isEmpty) {
      safePrint('📨 Notification envoyée à $ownerId');
    } else {
      throw response.errors.first.message;
    }
  } catch (e) {
    safePrint('❌ Erreur notif conducteur : $e');
  }
}
