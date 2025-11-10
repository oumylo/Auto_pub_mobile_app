import 'package:flutter/material.dart';

class DetailsCampagnePage extends StatelessWidget {
  final Map<String, dynamic> campagne;

  const DetailsCampagnePage({super.key, required this.campagne});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(campagne['titre'] ?? "Détails de la campagne"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎯 Titre
                Text(
                  campagne['titre'] ?? 'Sans titre',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFDA800),
                  ),
                ),
                const SizedBox(height: 16),

                // 💰 Budget
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Color(0xFFFDA800)),
                    const SizedBox(width: 8),
                    Text(
                      "Budget : ${campagne['budget'] ?? 0} FCFA",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFFFDA800)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Zones cibles : ${(campagne['zonesCibles'] as List?)?.join(', ') ?? 'Non précisées'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                
                const Text(
                  "Description :",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFDA800),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  campagne['description'] ?? "Aucune description fournie",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),

                
                const Text(
                  "Proposition choisie :",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFDA800),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  campagne['propositionChoisie'] ??
                      "Aucune proposition choisie",
                  style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 16),

                // 📅 Date de création
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFFFDA800)),
                    const SizedBox(width: 8),
                    Text(
                      "Créée le : ${campagne['createdAt'] ?? 'Inconnue'}",
                      style: const TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 🔙 Bouton retour
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDA800),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    label: const Text(
                      "Retour",
                      style: TextStyle(color: Colors.white, fontSize: 16),
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
