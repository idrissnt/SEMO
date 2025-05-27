import 'package:flutter/material.dart';

class RewardMessage extends StatelessWidget {
  final String? userName;

  const RewardMessage({super.key, this.userName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.amber.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔼 Green banner at the top
            Container(
              decoration: BoxDecoration(
                color: Colors.green[800],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: const Center(
                child: Expanded(
                  child: Text(
                    "Vous êtes notre Héros",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "🌟 Un immense merci pour votre service ! 🌟",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "💰 En plus de votre récompense monétaire,\n⭐ vous gagnerez 10 étoiles !",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "✨ Au bout de 1000 étoiles, elles deviendront une étoile filante... 🌠",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      // fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "🪄 Vous pourrez alors faire un vœu (il s’exaucera, vous verrez ! 😉)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
