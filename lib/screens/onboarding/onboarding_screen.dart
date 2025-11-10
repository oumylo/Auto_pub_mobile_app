import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../welcomePage.dart';

const Color accentOrange = Color(0xFFFDA800);

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "Suivi d'Exposition en Temps Réel",
      "body":
          "Le système de notation basé sur GPS assure un suivi précis de l'exposition des campagnes et une distribution équitable des paiements.",
      "image": "assets/images/onb_tracking.png",
      "highlight": "540",
    },
    {
      "title": "Paiements Sécurisés par Séquestre",
      "body":
          "Système de paiement sécurisé avec libération automatique à atteinte des objectifs de la campagne.",
      "image": "assets/images/onb_payments.png",
      "highlight": "870.000",
    },
    {
      "title": "Design & Habillage Vinyle",
      "body":
          "Service de design professionnel et habillage de véhicules pour assurer que votre marque soit parfaite sur chaque véhicule.",
      "image": "assets/images/onb_design.png",
      "highlight": "30",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF083B55),
      body: SafeArea(
        child: Column(
          children: [
            // PageView avec scroll si le contenu dépasse
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => currentIndex = i),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 36,
                    ),
                    child: _buildOnboardingPage(page),
                  );
                },
              ),
            ),

            // Indicateurs des pages
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: i == currentIndex ? 30 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: i == currentIndex ? accentOrange : Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Bouton "Commencer" seulement sur la dernière page
            if (currentIndex == pages.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Text(
                      'Commencer',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, String> page) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image
        Image.asset(
          page["image"]!,
          height: 220,
          width: double.infinity,
          fit: BoxFit.contain,
        ),

        const SizedBox(height: 30),

        // Carte contenant texte et highlight
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF09445F),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                page["title"]!,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                page["body"]!,
                style: GoogleFonts.poppins(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                maxLines: 6, // limite le texte pour éviter overflow
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              Text(
                page["highlight"]!,
                style: GoogleFonts.poppins(
                  color: accentOrange,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
