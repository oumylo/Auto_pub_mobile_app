import 'package:flutter/material.dart';
import 'package:auto_pub_mobil_app/screens/LoginPage.dart';
import 'package:auto_pub_mobil_app/screens/signup_conducteur.dart';

class ConductIntroPage extends StatelessWidget {
  const ConductIntroPage({super.key});

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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Texte principal
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Gagnez de l'argent\navec votre ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 50, 
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                          letterSpacing: 1.2,
                        ),
                      ),
                      TextSpan(
                        text: "véhicule",
                        style: TextStyle(
                          color: Color.fromARGB(255, 190, 166, 32),
                          fontSize: 50, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Transformez vos trajets quotidiens en revenus supplémentaires. "
                  "Rejoignez notre réseau de conducteurs et gagnez jusqu’à 50,000 FCFA par mois.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Bouton principal
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
                          builder: (context) => const SignupConducteurPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "Commencer maintenant",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Bouton secondaire
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      "J'ai déjà un compte",
                      style: TextStyle(
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
}
