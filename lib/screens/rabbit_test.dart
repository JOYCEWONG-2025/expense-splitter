import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RabbitTest extends StatelessWidget {
  const RabbitTest({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          "assets/rabbits/bunny_hop.json",
          width: 200,
        ),
      ),
    );
  }
}