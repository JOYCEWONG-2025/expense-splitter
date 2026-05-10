import 'package:flutter/material.dart';

class WorldScene extends StatelessWidget {
  final String title;
  final String image;

  const WorldScene({
    super.key,
    required this.title,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌍 BACKGROUND
          SizedBox.expand(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),

          // 🌫 DARK OVERLAY
          Container(
            color: Colors.black.withOpacity(0.4),
          ),

          // 🧭 CONTENT
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const Spacer(),

                const Text(
                  "World Loaded 🎮",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}