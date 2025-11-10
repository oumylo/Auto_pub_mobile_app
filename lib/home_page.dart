import 'dart:async';
import 'dart:convert';
import 'package:auto_pub_mobil_app/annonceur/notifications_page.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

import 'package:auto_pub_mobil_app/admin/liste_conducteurs_page.dart';
import 'package:auto_pub_mobil_app/admin/suivi_campagne_page.dart';
import 'package:auto_pub_mobil_app/admin/validation_campagne_page.dart';
import 'package:auto_pub_mobil_app/annonceur/campagne_form_page.dart';
import 'package:auto_pub_mobil_app/annonceur/mes_campagnes_page.dart';
import 'package:auto_pub_mobil_app/conducteur/historique_page.dart';
import 'package:auto_pub_mobil_app/conducteur/mes_campagnes_conducteur_page.dart';
import 'package:auto_pub_mobil_app/services/notification_service.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userRole;

  const HomePage({super.key, required this.userName, required this.userRole});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _unreadCount = 0;
  Timer? _timer;
  StreamSubscription<GraphQLResponse<String>>? _subscription;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      _currentUserId = user.userId;

      safePrint('🚀 Initialisation notifications pour: $_currentUserId');

      await _fetchUnreadCount();
      await _subscribeToNewNotifications();

      _timer = Timer.periodic(const Duration(seconds: 15), (timer) {
        _fetchUnreadCount();
      });
    } catch (e) {
      safePrint('❌ Erreur initialisation notifications: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _subscribeToNewNotifications() async {
    if (_currentUserId == null) return;

    try {
      safePrint('👂 Tentative de souscription aux notifications...');

      final subscriptionRequest = GraphQLRequest<String>(
        document: '''
        subscription OnCreateNotification {
          onCreateNotification {
            id
            titre
            message
            owner
            lue
            createdAt
          }
        }
        ''',
        authorizationMode: APIAuthorizationType.userPools,
      );

      final stream = Amplify.API.subscribe(
        subscriptionRequest,
        onEstablished: () {
          safePrint('✅ Subscription établie pour $_currentUserId');
        },
      );

      _subscription = stream.listen(
        (event) {
          safePrint('📨 Événement reçu: ${event.data}');

          if (event.data != null) {
            try {
              final jsonData = jsonDecode(event.data!);
              final notif = jsonData['onCreateNotification'];

              if (notif != null && notif['owner'] == _currentUserId) {
                safePrint(
                  '🔔 Nouvelle notification pour $_currentUserId: ${notif['titre']}',
                );

                NotificationService.showNotification(
                  title: notif['titre'] ?? 'Notification',
                  body: notif['message'] ?? '',
                );

                _fetchUnreadCount();
              } else {
                safePrint(
                  '⚠️ Notification pour un autre utilisateur: ${notif?['owner']}',
                );
              }
            } catch (e) {
              safePrint('❌ Erreur parsing notification: $e');
            }
          }
        },
        onError: (error) {
          safePrint('❌ Erreur abonnement notifications: $error');
        },
        onDone: () {
          safePrint('⚠️ Abonnement notifications terminé');
        },
      );
    } catch (e) {
      safePrint('❌ Erreur lors de la souscription : $e');
    }
  }

  Future<void> _fetchUnreadCount() async {
    try {
      final user = await Amplify.Auth.getCurrentUser();
      final request = GraphQLRequest<String>(
        document: '''
        query ListNotifications(\$owner: String!) {
          listNotifications(filter: {owner: {eq: \$owner}}) {
            items {
              id
              lue
            }
          }
        }
        ''',
        variables: {'owner': user.userId},
        authorizationMode: APIAuthorizationType.userPools,
      );

      final response = await Amplify.API.query(request: request).response;
      if (response.errors.isEmpty && response.data != null) {
        final data = jsonDecode(response.data!);
        final items = data['listNotifications']['items'] as List<dynamic>;
        final newCount =
            items.where((n) => n['lue'] == false || n['lue'] == null).length;

        if (mounted) {
          setState(() {
            _unreadCount = newCount;
          });
        }
        safePrint('📊 Notifications non lues: $_unreadCount');
      }
    } catch (e) {
      safePrint('❌ Erreur fetch unread count: $e');
    }
  }

  List<Widget> get _screens {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
        return const [
          ListeConducteursPage(userRole: '', userId: ''),
          ValidationCampagnePage(),
          SuiviCampagnePage(),
        ];
      case 'conducteur':
        return const [MesCampagnesConducteurPage(), HistoriquePage()];
      case 'annonceur':
        return const [CampagneFormPage(), MesCampagnesPage(), HistoriquePage()];
      default:
        return [Center(child: Text('Rôle inconnu : ${widget.userRole}'))];
    }
  }

  List<BottomNavigationBarItem> get _navItems {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Conducteurs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Validation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Suivi',
          ),
        ];
      case 'conducteur':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Campagnes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ];
      case 'annonceur':
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Créer'),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Campagnes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenu principal
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _screens[_currentIndex],
          ),

          // Bouton de notification flottant
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                  _fetchUnreadCount();
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.notifications_outlined,
                        color: Colors.black87,
                        size: 24,
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDA800),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$_unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFFF7900),
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 8,
        backgroundColor: Colors.white,
      ),
    );
  }
}
