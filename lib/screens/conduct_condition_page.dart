import 'package:flutter/material.dart';
import 'conduct_intro_page.dart';

class ConductConditionPage extends StatelessWidget {
  const ConductConditionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        // ✅ Ajout d’un SingleChildScrollView + centré verticalement
        child: SingleChildScrollView(
          child: Container(
            // ✅ Ajoute un espace haut pour descendre le contenu
            margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height * 0.10,
              bottom: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Prêt à commencer ?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Rejoignez plus de 500 conducteurs qui gagnent déjà de l’argent avec AutoPub Studio.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 40),

                // ✅ Carte des conditions
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Conditions requises",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        "Documents nécessaires :",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckItem("Carte d’identité valide"),
                      _buildCheckItem(
                        "Permis de conduire en cours de validité",
                      ),
                      _buildCheckItem("Assurance véhicule valide"),
                      _buildCheckItem("Carte grise du véhicule"),

                      const SizedBox(height: 16),
                      const Text(
                        "Critères véhicule :",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      _buildCheckItem("Véhicule de moins de 15 ans"),
                      _buildCheckItem("Bon état général"),
                      _buildCheckItem("Circulation régulière dans Dakar"),
                      _buildCheckItem("Disponibilité minimum 4h/jour"),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // ✅ Bouton "Se connecter"
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDA800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ConductIntroPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Se connecter",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
