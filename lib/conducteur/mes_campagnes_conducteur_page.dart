import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

class MesCampagnesConducteurPage extends StatefulWidget {
  const MesCampagnesConducteurPage({super.key});

  @override
  State<MesCampagnesConducteurPage> createState() =>
      _MesCampagnesConducteurPageState();
}

class _MesCampagnesConducteurPageState
    extends State<MesCampagnesConducteurPage> {
  List<dynamic> _campagnes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCampagnes();
  }

  Future<void> _fetchCampagnes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1️⃣ Récupérer le userSub
      final user = await Amplify.Auth.getCurrentUser();
      final userSub = user.userId;

      safePrint("🔍 UserSub: $userSub");

      // 2️⃣ Chercher le conducteur par owner
      final conducteurRequest = GraphQLRequest<String>(
        document: '''
      query ListConducteurs(\$owner: String!) {
        listConducteurs(filter: {
          owner: { eq: \$owner }
        }) {
          items {
            id
            nom
            campagnesAssignees
          }
        }
      }
    ''',
        variables: {"owner": userSub},
        authorizationMode: APIAuthorizationType.userPools,
      );

      final conducteurResponse =
          await Amplify.API.query(request: conducteurRequest).response;

      if (conducteurResponse.errors.isNotEmpty) {
        safePrint("❌ Erreurs GraphQL: ${conducteurResponse.errors}");
        setState(() {
          _errorMessage =
              "Erreur GraphQL: ${conducteurResponse.errors.first.message}";
        });
        return;
      }

      final conducteurData = jsonDecode(conducteurResponse.data!);
      final conducteurs = conducteurData["listConducteurs"]["items"] ?? [];

      if (conducteurs.isEmpty) {
        safePrint("⚠️ Conducteur introuvable");
        setState(() {
          _errorMessage = "Profil conducteur non trouvé.";
        });
        return;
      }

      final conducteur = conducteurs[0];
      final campagnesList =
          (conducteur["campagnesAssignees"] as List?)?.cast<String>() ?? [];

      safePrint("📋 Campagnes assignées: $campagnesList");

      if (campagnesList.isEmpty) {
        safePrint("ℹ️ Aucune campagne assignée");
        setState(() {
          _campagnes = [];
        });
        return;
      }

      // 3️⃣ Récupérer chaque campagne individuellement
      List<Map<String, dynamic>> results = [];

      for (String campagneId in campagnesList) {
        try {
          final campagneReq = GraphQLRequest<String>(
            document: '''
          query GetCampagne(\$id: ID!) {
            getCampagne(id: \$id) {
              id
              titre
              budget
              zonesCibles
              description
              visuelUrl
              propositionChoisie
              statut
              createdAt
            }
          }
        ''',
            variables: {"id": campagneId},
            authorizationMode: APIAuthorizationType.userPools,
          );

          final campagneResp =
              await Amplify.API.query(request: campagneReq).response;

          if (campagneResp.errors.isEmpty && campagneResp.data != null) {
            final campagneData = jsonDecode(campagneResp.data!)["getCampagne"];
            if (campagneData != null) {
              results.add(campagneData);
              safePrint("✅ Campagne récupérée: ${campagneData['titre']}");
            }
          } else {
            safePrint("⚠️ Campagne $campagneId: ${campagneResp.errors}");
          }
        } catch (e) {
          safePrint("❌ Erreur campagne $campagneId: $e");
        }
      }

      setState(() {
        _campagnes = results;
      });

      safePrint("✅ ${results.length} campagne(s) affichée(s)");
    } catch (e) {
      safePrint("❌ Erreur: $e");
      setState(() {
        _errorMessage = "Impossible de récupérer les campagnes: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showCampagneDetails(Map<String, dynamic> campagne) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            campagne['titre'] ?? 'Sans titre',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    if (campagne['visuelUrl'] != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          campagne['visuelUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 100,
                              ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.monetization_on,
                      'Budget',
                      '${campagne['budget']} FCFA',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.info,
                      'Statut',
                      campagne['statut'] ?? 'EN_ATTENTE',
                    ),
                    if (campagne['propositionChoisie'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.campaign,
                        'Proposition',
                        campagne['propositionChoisie'],
                      ),
                    ],
                    if (campagne['description'] != null) ...[
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.description,
                        'Description',
                        campagne['description'],
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (campagne['zonesCibles'] != null) ...[
                      const Text(
                        'Zones cibles:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            (campagne['zonesCibles'] as List)
                                .map(
                                  (zone) => Chip(
                                    label: Text(zone),
                                    backgroundColor: Colors.blue.shade100,
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0A426D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Fermer'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0A426D)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Campagnes'),
        backgroundColor: const Color(0xFF0A426D),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchCampagnes,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF0A426D)),
              )
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchCampagnes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A426D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : _campagnes.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.campaign_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucune campagne assignée',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Les campagnes qui vous sont assignées apparaîtront ici',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _fetchCampagnes,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0A426D),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchCampagnes,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.campaign, color: Color(0xFF0A426D)),
                          const SizedBox(width: 8),
                          Text(
                            '${_campagnes.length} campagne(s) assignée(s)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._campagnes.map(
                      (c) => _buildCampagneCard(c as Map<String, dynamic>),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
    );
  }

  Widget _buildCampagneCard(Map<String, dynamic> campagne) {
    final zones = (campagne['zonesCibles'] as List?)?.cast<String>() ?? [];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showCampagneDetails(campagne),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      campagne['titre'] ?? 'Sans titre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatutColor(campagne['statut']),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      campagne['statut'] ?? 'EN_ATTENTE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Color(0xFF0A426D),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Budget: ${campagne['budget']} FCFA',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              if (zones.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      zones
                          .map(
                            (zone) => Chip(
                              label: Text(
                                zone,
                                style: const TextStyle(fontSize: 12),
                              ),
                              backgroundColor: Colors.blue.shade50,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _showCampagneDetails(campagne),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Voir détails'),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF0A426D),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatutColor(String? statut) {
    switch (statut) {
      case 'VALIDEE':
        return Colors.green;
      case 'EN_ATTENTE':
        return Colors.orange;
      case 'REJETEE':
        return Colors.red;
      case 'EN_COURS':
        return Colors.blue;
      case 'TERMINEE':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
