import 'package:flutter/material.dart';
import 'dart:math';

class WorldScene extends StatefulWidget {
  final List<String> members;

  const WorldScene({
    super.key,
    required this.members,
  });

  @override
  State<WorldScene> createState() => _WorldSceneState();
}

class _WorldSceneState extends State<WorldScene>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _circlePosition(double radius, double angle) {
    return Offset(
      radius * cos(angle),
      radius * sin(angle),
    );
  }

  @override
  Widget build(BuildContext context) {

    final center = MediaQuery.of(context).size.width / 2;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F8),

      body: Center(
        child: AnimatedBuilder(
          animation: _animation,

          builder: (context, child) {

            return Stack(
              alignment: Alignment.center,
              children: [

                // 🔵 center point (future: receipt)
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black12,
                      )
                    ],
                  ),
                  child: const Icon(Icons.receipt_long),
                ),

                // 🐰 rabbits forming circle
                for (int i = 0; i < widget.members.length; i++)
                  Transform.translate(
                    offset: _circlePosition(
                      120 * _animation.value,
                      (2 * pi * i) / widget.members.length,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        const Text("🐰", style: TextStyle(fontSize: 30)),

                        Text(widget.members[i]),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}