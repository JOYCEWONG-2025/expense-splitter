import 'package:flutter/material.dart';
import 'package:expense_splitter/features/group/group_creation_page.dart';

class TimelinePage extends StatefulWidget {
  final String worldTitle;
  final String worldImage;

  const TimelinePage({
    super.key,
    required this.worldTitle,
    required this.worldImage,
  });

  @override
  State<TimelinePage> createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  int selectedDay = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🌍 Background
          SizedBox.expand(
            child: Image.asset(widget.worldImage, fit: BoxFit.cover),
          ),

          // 🌫 Overlay
          Container(color: Colors.black.withOpacity(0.45)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),

                Text(
                  "${widget.worldTitle} Timeline 📖",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // 📅 Timeline Days
                Expanded(
                  child: ListView.builder(
                    itemCount: 31,

                    itemBuilder: (context, index) {
                      final day = index + 1;

                      final isSelected = selectedDay == day;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDay = day;
                          });
                        },

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),

                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),

                          padding: const EdgeInsets.all(22),

                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : Colors.white.withOpacity(0.15),

                            borderRadius: BorderRadius.circular(24),

                            border: Border.all(color: Colors.white24),
                          ),

                          child: Row(
                            children: [
                              // 🐰 Rabbit indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),

                                width: isSelected ? 70 : 0,

                                child: isSelected
                                    ? const Text(
                                        "🐰",
                                        style: TextStyle(fontSize: 30),
                                      )
                                    : null,
                              ),

                              Text(
                                "$day May",
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.white,

                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 🚀 Continue Button
                Padding(
                  padding: const EdgeInsets.all(24),

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
                        // 🔜 next phase
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => GroupCreationPage(
                              worldTitle: widget.worldTitle,
                              selectedDay: selectedDay,
                            ),
                          ),
                        );
                      },

                      child: Text(
                        "Start Story — $selectedDay May ✨",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
