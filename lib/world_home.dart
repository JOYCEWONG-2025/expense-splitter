import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class WorldHome extends StatefulWidget {
  const WorldHome({super.key});

  @override
  State<WorldHome> createState() => _WorldHomeState();
}

class _WorldHomeState extends State<WorldHome> {
  final PageController _controller = PageController(viewportFraction: 0.78);

  final List<Map<String, String>> worlds = [
    {
      "title": "Food World 🍔",
      "desc": "Track your meals & snacks",
      "image": "assets/backgrounds/food.jpg",
    },
    {
      "title": "Transport World 🚗",
      "desc": "Travel & commute expenses",
      "image": "assets/backgrounds/transport.jpeg",
    },
    {
      "title": "Shopping World 🛍️",
      "desc": "All your shopping spending",
      "image": "assets/backgrounds/shopping.jpg",
    },
    {
      "title": "Accommodation World 🏨",
      "desc": "Stay & lodging costs",
      "image": "assets/backgrounds/Accomo.jpg",
    },
    {
      "title": "Trip World ✈️",
      "desc": "Travel adventures & trips",
      "image": "assets/backgrounds/trip.jpeg",
    },
    {
      "title": "Others 🌈",
      "desc": "Custom / uncategorized expenses",
      "image": "assets/backgrounds/others.jpg",
    },
  ];

  double currentPage = 0;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      setState(() {
        currentPage = _controller.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF3EEF5),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            const Text(
              "Rabbit Expense Worlds 🐰",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            const Text(
              "Swipe to explore your expense adventure",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 🌍 MAIN WORLD + RABBIT LAYER
            Expanded(
              child: Stack(
                children: [

                  // 🌍 WORLD SWIPER (UNCHANGED LOGIC)
                  PageView.builder(
                    controller: _controller,
                    itemCount: worlds.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double value = 1.0;

                          if (_controller.hasClients &&
                              _controller.position.haveDimensions) {
                            value = (_controller.page ?? 0) - index;
                          } else {
                            value = (index == 0) ? 0 : 1;
                          }

                          value = (1 - (value.abs() * 0.45)).clamp(0.65, 1.0);

                          return Center(
                            child: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..scale(value)
                                ..rotateY((1 - value) * -0.6),
                              child: Opacity(
                                opacity: value,
                                child: buildWorldCard(worlds[index]),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),

                  // 🐰 GLOBAL RABBIT (ONLY ONE SYSTEM)
                  Positioned(
                    bottom: 20,

                    // smooth world-to-world movement
                    left: currentPage *
                        screenWidth *
                        0.65 /
                        (worlds.length - 1),

                    child: SizedBox(
                      height: 140,
                      width: 140,
                      child: Lottie.asset(
                        "assets/rabbits/Rabbit Kick Scooter.json",
                        fit: BoxFit.contain,
                        repeat: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 🌍 WORLD CARD (UNCHANGED EXCEPT REMOVING DUPLICATE RABBIT)
  Widget buildWorldCard(Map<String, String> world) {
    return FractionallySizedBox(
      widthFactor: 0.92,

      child: Container(
        height: 560,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          image: DecorationImage(
            image: AssetImage(world["image"]!),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 25,
              color: Colors.black38,
              offset: Offset(0, 15),
            ),
          ],
        ),

        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.85),
              ],
            ),
          ),

          child: Padding(
            padding: const EdgeInsets.all(28),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,

              children: [
                // 🧠 IMPORTANT FIX:
                // ❌ removed AnimatedContainer rabbit here
                // ✔ rabbit is now ONLY global (Stack level)

                const SizedBox(height: 30),

                Text(
                  world["title"]!,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  world["desc"]!,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      "Enter World ✨",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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