import 'package:auto_pub_mobil_app/admin/liste_conducteurs_page.dart';
import 'package:auto_pub_mobil_app/admin/suivi_campagne_page.dart';
import 'package:auto_pub_mobil_app/admin/validation_campagne_page.dart';
import 'package:auto_pub_mobil_app/annonceur/mes_campagnes_annonceur_page.dart';
import 'package:auto_pub_mobil_app/annonceur/publier_campagne_page.dart';
import 'package:auto_pub_mobil_app/conducteur/historique_page.dart';
import 'package:auto_pub_mobil_app/conducteur/mes_campagnes_conducteur_page.dart';
import 'package:auto_pub_mobil_app/screens/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userRole;

  const HomePage({super.key, required this.userName, required this.userRole});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  Future<void> signOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Déconnexion'),
            content: const Text('Voulez-vous vraiment vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (shouldSignOut == true) {
      try {
        await Amplify.Auth.signOut();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LandingPage()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur déconnexion : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
        return const [
          MesCampagnesConducteurPage(),
          //PaiementsPage(),
          HistoriquePage(),
        ];
      case 'annonceur':
        return const [
          PublierCampagnePage(),
          MesCampagnesAnnonceurPage(),
          //SuiviStatistiquesPage(),
          //PaiementsPage(),
          HistoriquePage(),
        ];
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
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.payments),
          //   label: 'Paiements',
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Historique',
          ),
        ];
      case 'annonceur':
        return const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Publier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Campagnes',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Suivi'),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Paiements',
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

  String _getRoleDisplayName() {
    switch (widget.userRole.toLowerCase()) {
      case 'admin':
        return 'Administrateur';
      case 'conducteur':
        return 'Conducteur';
      case 'annonceur':
        return 'Annonceur';
      default:
        return widget.userRole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.userName.isNotEmpty ? widget.userName : 'Utilisateur',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              _getRoleDisplayName(),
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: signOut,
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        elevation: 8,
      ),
    );
  }
}
