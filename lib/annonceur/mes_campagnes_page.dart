import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class MesCampagnesPage extends StatefulWidget {
  const MesCampagnesPage({super.key});

  @override
  State<MesCampagnesPage> createState() => _MesCampagnesPageState();
}

class _MesCampagnesPageState extends State<MesCampagnesPage> {
  List<dynamic> campagnes = [];
  List<dynamic> campagnesFiltrees = [];
  bool _loading = true;
  String filtreActif = "TOUTES"; 

  @override
  void initState() {
    super.initState();
    _fetchMesCampagnes();
  }

  Future<void> _fetchMesCampagnes() async {
    try {
      setState(() => _loading = true);

      final user = await Amplify.Auth.getCurrentUser();

      final request = GraphQLRequest<String>(
        document: '''
          query ListCampagnes(\$owner: String!) {
            listCampagnes(filter: {owner: {eq: \$owner}}) {
              items {
                id
                titre
                budget
                statut
                zonesCibles
                description
                createdAt
              }
            }
          }
        ''',
        variables: {'owner': user.userId},
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isEmpty) {
        final data = jsonDecode(response.data!);
        final all = (data['listCampagnes']['items'] as List).reversed.toList();
        setState(() {
          campagnes = all;
          campagnesFiltrees = all;
        });
      } else {
        safePrint('Erreur GraphQL: ${response.errors.first.message}');
      }
    } catch (e) {
      safePrint('Erreur chargement campagnes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _filtrer(String statut) {
    setState(() {
      filtreActif = statut;
      if (statut == "TOUTES") {
        campagnesFiltrees = campagnes;
      } else {
        campagnesFiltrees =
            campagnes.where((c) => c['statut'] == statut).toList();
      }
    });
  }

  Color _getColor(String statut) {
    switch (statut) {
      case "VALIDÉE":
        return Colors.green;
      case "REJETÉE":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes Campagnes"),
        backgroundColor: const Color(0xFFFF7900),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF7900)),
            )
          : Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text("🟡 En attente"),
                        selected: filtreActif == "EN_ATTENTE",
                        selectedColor: Colors.orange.shade100,
                        onSelected: (_) => _filtrer("EN_ATTENTE"),
                      ),
                      FilterChip(
                        label: const Text("🟢 Validées"),
                        selected: filtreActif == "VALIDÉE",
                        selectedColor: Colors.green.shade100,
                        onSelected: (_) => _filtrer("VALIDÉE"),
                      ),
                      FilterChip(
                        label: const Text("🔴 Rejetées"),
                        selected: filtreActif == "REJETÉE",
                        selectedColor: Colors.red.shade100,
                        onSelected: (_) => _filtrer("REJETÉE"),
                      ),
                      FilterChip(
                        label: const Text("Toutes"),
                        selected: filtreActif == "TOUTES",
                        selectedColor: Colors.grey.shade200,
                        onSelected: (_) => _filtrer("TOUTES"),
                      ),
                    ],
                  ),
                ),

                const Divider(),

                // 🧾 Liste des campagnes filtrées
                Expanded(
                  child: campagnesFiltrees.isEmpty
                      ? const Center(
                          child: Text("Aucune campagne trouvée."),
                        )
                      : ListView.builder(
                          itemCount: campagnesFiltrees.length,
                          itemBuilder: (context, index) {
                            final campagne = campagnesFiltrees[index];
                            final statut = campagne['statut'];
                            final zones =
                                (campagne['zonesCibles'] as List).join(', ');

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  campagne['titre'] ?? "Sans titre",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 6.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Zones : $zones"),
                                      Text(
                                          "Budget : ${campagne['budget']} FCFA"),
                                      Text(
                                        "Statut : $statut",
                                        style: TextStyle(
                                          color: _getColor(statut),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.campaign,
                                  color: Color(0xFFFF7900),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
