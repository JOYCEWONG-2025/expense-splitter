import 'package:flutter/material.dart';
import 'timeline_page.dart';

class WorldScene extends StatelessWidget {
  final String title;
  final String image;

  const WorldScene({super.key, required this.title, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌍 BACKGROUND
          SizedBox.expand(child: Image.asset(image, fit: BoxFit.cover)),

          // 🌫 DARK OVERLAY
          Container(color: Colors.black.withOpacity(0.4)),

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
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),

                  child: SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,

                        padding: const EdgeInsets.symmetric(vertical: 18),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),

                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimelinePage(
                              worldTitle: title,
                              worldImage: image,
                            ),
                          ),
                        );
                      },

                      child: const Text(
                        "Open Timeline 📖",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
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
