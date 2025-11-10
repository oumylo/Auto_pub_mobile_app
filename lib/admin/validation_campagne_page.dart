import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class ValidationCampagnePage extends StatefulWidget {
  const ValidationCampagnePage({super.key});

  @override
  State<ValidationCampagnePage> createState() => _ValidationCampagnePageState();
}

class _ValidationCampagnePageState extends State<ValidationCampagnePage> {
  List<dynamic> campagnes = [];
  bool _loading = false;
  String _selectedStatut = "EN_ATTENTE"; // 🔸 filtre par défaut

  @override
  void initState() {
    super.initState();
    _fetchCampagnes();
  }

  Future<void> _fetchCampagnes() async {
    setState(() => _loading = true);
    try {
      final request = GraphQLRequest<String>(
        document: '''
        query ListCampagnes {
          listCampagnes {
            items {
              id
              titre
              budget
              owner
              propositionChoisie
              statut
            }
          }
        }
        ''',
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isEmpty) {
        final data = jsonDecode(response.data!);
        final all = data['listCampagnes']['items'] ?? [];

        // 🔸 On filtre selon l'onglet sélectionné
        setState(() {
          campagnes = all.where((c) => c['statut'] == _selectedStatut).toList();
        });

        safePrint('✅ ${campagnes.length} campagnes chargées ($_selectedStatut)');
      } else {
        throw response.errors.first.message;
      }
    } catch (e) {
      safePrint('❌ Erreur fetch campagnes: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _sendNotification(
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
        safePrint('✅ Notification "$titre" envoyée à $ownerId');
      } else {
        throw response.errors.first.message;
      }
    } catch (e) {
      safePrint('❌ Erreur notification : $e');
    }
  }

  Future<void> _validerCampagne(String id, String owner) async {
    await _updateStatutCampagne(id, owner, 'VALIDEE',
        'Votre campagne a été validée par l\'administrateur. Merci de déposer votre argent avant 24h.');
  }

  Future<void> _rejeterCampagne(String id, String owner) async {
    await _updateStatutCampagne(id, owner, 'REJETEE',
        'Votre campagne a été rejetée par l\'administrateur. Veuillez nous contacter pour plus d\'informations.');
  }

  Future<void> _updateStatutCampagne(
      String id, String owner, String newStatut, String message) async {
    setState(() => _loading = true);
    try {
      final request = GraphQLRequest<String>(
        document: '''
        mutation UpdateCampagne(\$input: UpdateCampagneInput!) {
          updateCampagne(input: \$input) {
            id
            statut
            owner
          }
        }
        ''',
        variables: {
          'input': {'id': id, 'statut': newStatut},
        },
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.mutate(request: request).response;

      if (response.errors.isEmpty) {
        safePrint('✅ Campagne $id mise à jour : $newStatut');

        await _sendNotification(owner, 'Campagne $newStatut', message);
        await _fetchCampagnes();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Campagne $newStatut'),
          backgroundColor: newStatut == 'VALIDEE' ? Colors.green : Colors.red,
        ));
      } else {
        throw response.errors.first.message;
      }
    } catch (e) {
      safePrint('❌ Erreur mise à jour: $e');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erreur : $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Campagnes'),
        backgroundColor: const Color(0xFF0A426D),
      ),
      body: Column(
        children: [
          // 🔸 Onglets de filtrage
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterButton("EN_ATTENTE", Colors.amber),
                _buildFilterButton("VALIDEE", Colors.green),
                _buildFilterButton("REJETEE", Colors.red),
              ],
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0A426D)),
                  )
                : campagnes.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune campagne à afficher',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: campagnes.length,
                        itemBuilder: (context, index) {
                          final c = campagnes[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            elevation: 3,
                            child: ListTile(
                              title: Text(
                                c['titre'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                'Budget : ${c['budget']} FCFA\n'
                                'Proposition : ${c['propositionChoisie'] ?? '-'}\n'
                                'Statut: ${c['statut']}',
                              ),
                              isThreeLine: true,
                              trailing: _selectedStatut == "EN_ATTENTE"
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check,
                                              color: Colors.green),
                                          onPressed: () => _validerCampagne(
                                              c['id'], c['owner']),
                                          tooltip: 'Valider',
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close,
                                              color: Colors.red),
                                          onPressed: () => _rejeterCampagne(
                                              c['id'], c['owner']),
                                          tooltip: 'Rejeter',
                                        ),
                                      ],
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // 🔸 Bouton de filtre stylé
  Widget _buildFilterButton(String statut, Color color) {
    final bool isActive = _selectedStatut == statut;
    return TextButton(
      onPressed: () {
        setState(() => _selectedStatut = statut);
        _fetchCampagnes();
      },
      style: TextButton.styleFrom(
        backgroundColor: isActive ? color : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        statut,
        style: TextStyle(
          color: isActive ? Colors.white : color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
