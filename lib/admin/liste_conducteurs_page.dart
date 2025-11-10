import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class ListeConducteursPage extends StatefulWidget {
  const ListeConducteursPage({
    super.key,
    required this.userRole,
    required this.userId,
  });

  final String userRole;
  final String userId;

  @override
  State<ListeConducteursPage> createState() => _ListeConducteursPageState();
}

class _ListeConducteursPageState extends State<ListeConducteursPage> {
  List<Map<String, dynamic>> _conducteurs = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConducteurs();
  }

  Future<void> _loadConducteurs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Vérifier l'authentification
      final session = await Amplify.Auth.fetchAuthSession();
      if (!session.isSignedIn) {
        throw Exception('Vous devez être connecté');
      }

      const query = '''
        query ListConducteurs {
          listConducteurs {
            items {
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
              owner
            }
          }
        }
      ''';

      final request = GraphQLRequest<String>(document: query, variables: {});

      final response = await Amplify.API.query(request: request).response;

      if (response.errors.isNotEmpty) {
        final errorMsg = response.errors.map((e) => e.message).join(', ');
        throw Exception('Erreur GraphQL: $errorMsg');
      }

      if (response.data != null) {
        final data = response.data!;
        final decoded = jsonDecode(data);
        final items = decoded['listConducteurs']['items'] as List;

        setState(() {
          _conducteurs =
              items.map((item) => item as Map<String, dynamic>).toList();
          _isLoading = false;
        });

        safePrint('${_conducteurs.length} conducteurs chargés');
      }
    } catch (e) {
      safePrint('Erreur chargement conducteurs: $e');
      setState(() {
        _errorMessage = 'Erreur lors du chargement: $e';
        _isLoading = false;
      });
    }
  }

  // Future<void> _deleteConducteur(String id, String nom) async
  // {
  //   final confirm = await showDialog<bool>(
  //     context: context,
  //     builder:
  //         (context) => AlertDialog(
  //           title: const Text('Confirmer la suppression'),
  //           content: Text(
  //             'Voulez-vous vraiment supprimer le conducteur "$nom" ?',
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context, false),
  //               child: const Text('Annuler'),
  //             ),
  //             ElevatedButton
  //             (
  //               onPressed: () => Navigator.pop(context, true),
  //               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  //               child: const Text('Supprimer'),
  //             ),
  //           ],
  //         ),
  //   );

  //   if (confirm != true) return;

  //   try {
  //     const mutation = '''
  //       mutation DeleteConducteur(\$input: DeleteConducteurInput!) {
  //         deleteConducteur(input: \$input) {
  //           id
  //         }
  //       }
  //     ''';

  //     final variables = {
  //       'input': {'id': id},
  //     };

  //     final request = GraphQLRequest<String>(
  //       document: mutation,
  //       variables: variables,
  //     );

  //     final response = await Amplify.API.mutate(request: request).response;

  //     if (response.errors.isNotEmpty) {
  //       final errorMsg = response.errors.map((e) => e.message).join(', ');
  //       safePrint('Erreurs GraphQL: $errorMsg');
  //       throw Exception('Erreur GraphQL: $errorMsg');
  //     }

  //     safePrint('Conducteur supprimé avec succès');

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Conducteur "$nom" supprimé avec succès'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //       _loadConducteurs();
  //     }
  //   } catch (e) {
  //     safePrint('Erreur suppression: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Erreur: $e'),
  //           backgroundColor: Colors.red,
  //           duration: const Duration(seconds: 5),
  //         ),
  //       );
  //     }
  //   }
  // }

  Future<void> _viewDocuments(Map<String, dynamic> conducteur) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Documents - ${conducteur['nom']}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentLink('CI Recto', conducteur['ciRectoUrl']),
                  const SizedBox(height: 10),
                  _buildDocumentLink('CI Verso', conducteur['ciVersoUrl']),
                  const SizedBox(height: 10),
                  _buildDocumentLink('CG Recto', conducteur['cgRectoUrl']),
                  const SizedBox(height: 10),
                  _buildDocumentLink('CG Verso', conducteur['cgVersoUrl']),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  Widget _buildDocumentLink(String label, String? url) {
    return Row(
      children: [
        const Icon(Icons.insert_drive_file, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        if (url != null)
          const Icon(Icons.check_circle, color: Colors.green, size: 20)
        else
          const Icon(Icons.cancel, color: Colors.red, size: 20),
      ],
    );
  }

  Widget _buildConducteurCard(Map<String, dynamic> conducteur) {
    final zones = (conducteur['zones'] as List?)?.cast<String>() ?? [];

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFF0A426D),
          child: Text(
            conducteur['nom']?.substring(0, 1).toUpperCase() ?? 'C',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          conducteur['nom'] ?? 'Nom inconnu',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          conducteur['email'] ?? '',
          style: const TextStyle(color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.phone,
                  'Téléphone',
                  conducteur['telephone'] ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.directions_car,
                  'Type véhicule',
                  conducteur['typeVoiture'] ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.tv,
                  'Support',
                  conducteur['typeSupport'] ?? 'N/A',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time,
                  'Heures',
                  conducteur['heuresConduite'] ?? 'N/A',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Zones fréquentées:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _viewDocuments(conducteur),
                        icon: const Icon(Icons.folder_open, size: 18),
                        label: const Text('Documents'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Expanded(
                    //   child: ElevatedButton.icon(
                    //     onPressed:
                    //         () => _deleteConducteur(
                    //           conducteur['id'],
                    //           conducteur['nom'] ?? 'Inconnu',
                    //         ),
                    //     icon: const Icon(Icons.delete, size: 18),
                    //     label: const Text('Supprimer'),
                    //     style: ElevatedButton.styleFrom(
                    //       backgroundColor: Colors.red,
                    //       foregroundColor: Colors.white,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(8),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Color(0xFF0A426D)),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar
      // (
      //   title: const Text('Liste des Conducteurs'),
      //   backgroundColor: Colors.blue,
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh),
      //       onPressed: _loadConducteurs,
      //       tooltip: 'Actualiser',
      //     ),
      //   ],
      // ),
      body:
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
                      onPressed: _loadConducteurs,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
              : _conducteurs.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.person_off_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun conducteur inscrit',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadConducteurs,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Actualiser'),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadConducteurs,
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.people, color: Color(0xFF0A426D)),
                          const SizedBox(width: 8),
                          Text(
                            '${_conducteurs.length} conducteur(s) inscrit(s)',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._conducteurs.map((c) => _buildConducteurCard(c)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
    );
  }
}
