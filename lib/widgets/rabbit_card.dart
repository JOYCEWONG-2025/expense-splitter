import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RabbitCard extends StatelessWidget {

  final String rabbitName;
  final String rabbitAsset;

  const RabbitCard({
    super.key,
    required this.rabbitName,
    required this.rabbitAsset,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),

        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [

          // 🐰 rabbit animation
          SizedBox(
            width: 70,
            height: 70,

            child: Lottie.asset(
              rabbitAsset,
              repeat: true,
            ),
          ),

          const SizedBox(width: 16),

          // 🏷️ rabbit name
          Expanded(
            child: Text(
              rabbitName,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        ],
      ),
    );
  }
}