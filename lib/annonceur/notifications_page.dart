import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _loading = true);

    try {
      final user = await Amplify.Auth.getCurrentUser();

      final request = GraphQLRequest<String>(
        document: '''
        query ListNotifications(\$owner: String!) {
          listNotifications(filter: {owner: {eq: \$owner}}) {
            items {
              id
              titre
              message
              lue
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
        final data = response.data;
        final jsonData = data != null ? jsonDecode(data) : null;

       
        List<dynamic> items = jsonData?['listNotifications']?['items'] ?? [];
        items.sort((a, b) {
          final dateA = DateTime.parse(a['createdAt'] ?? '');
          final dateB = DateTime.parse(b['createdAt'] ?? '');
          return dateB.compareTo(dateA); 
        });

        setState(() {
          notifications = items;
        });
      } else {
        throw response.errors.first.message;
      }
    } catch (e) {
      safePrint("Erreur fetch notifications: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors du chargement des notifications : $e"),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      final request = GraphQLRequest<String>(
        document: '''
        mutation UpdateNotification(\$id: ID!) {
          updateNotification(input: { id: \$id, lue: true }) {
            id
            lue
          }
        }
      ''',
        variables: {'id': notificationId},
        authorizationMode: APIAuthorizationType.userPools,
      );
      await Amplify.API.mutate(request: request).response;

      // Mettre à jour localement
      setState(() {
        final index = notifications.indexWhere(
          (n) => n['id'] == notificationId,
        );
        if (index != -1) {
          notifications[index]['lue'] = true;
        }
      });
    } catch (e) {
      safePrint("Erreur lors du marquage de la notification : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['lue'] == false).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body:
          _loading
              ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF1565C0)),
              )
              : _buildNotificationList(unreadCount),
    );
  }

  Widget _buildNotificationList(int unreadCount) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "Aucune notification",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Bannière de notifications en attente
        if (unreadCount > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDA800),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Campagnes en attente de validation",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDA800),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$unreadCount",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Liste des notifications
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final isUnread = notif['lue'] == false;
              final titre = notif['titre'] ?? "Notification";
              final message = notif['message'] ?? "";

              return GestureDetector(
                onTap: () {
                  if (isUnread) _markAsRead(notif['id']);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          isUnread
                              ? const Color(0xFFFDA800).withOpacity(0.3)
                              : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête avec titre et badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titre,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDA800),
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Message de la notification
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),

                      // Section "Hier" ou date
                      if (index > 0 && _shouldShowDateSeparator(index))
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            "Hier",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _shouldShowDateSeparator(int index) {
    // Cette fonction peut être utilisée pour afficher "Aujourd'hui" / "Hier"
    // Pour l'instant, elle retourne false, mais vous pouvez l'améliorer
    // en comparant les dates de création des notifications
    return false;
  }
}
