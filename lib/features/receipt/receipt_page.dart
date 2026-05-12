import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ReceiptPage extends StatefulWidget {
  final String groupName;
  final List<String> members;

  const ReceiptPage({
    super.key,
    required this.groupName,
    required this.members,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage>
    with TickerProviderStateMixin {

  // 🧾 controllers (ORIGINAL - KEEP)
  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  String? selectedPayer;
  List<String> selectedMembers = [];

  // 🎬 original animation (KEEP)
  late AnimationController _controller;
  late Animation<double> animation;

  // ================================
  // 🐰 ADD: CIRCLE ANIMATION CONTROLLER
  // ================================
  late AnimationController _circleController;

  @override
  void initState() {
    super.initState();

    // ================================
    // ORIGINAL RECEIPT ANIMATION
    // ================================
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // ================================
    // 🐰 ADD: CIRCLE ANIMATION INIT
    // ================================
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _circleController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    // 🐰 ADD
    _circleController.dispose();

    super.dispose();
  }

  // ================================
  // 🐰 ADD: SAFE POSITION LOGIC
  // ================================
  Offset getPosition(int index, int total, double radius) {
    if (total == 1) {
      return const Offset(0, 0);
    }

    if (total == 2) {
      double angle = index == 0 ? 0 : pi;
      return Offset(
        radius * _circleController.value * cos(angle),
        radius * _circleController.value * sin(angle),
      );
    }

    final angle = (2 * pi * index) / total;

    return Offset(
      radius * _circleController.value * cos(angle),
      radius * _circleController.value * sin(angle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F8),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${widget.groupName} Receipt 🧾",
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [

            // ================================
            // 🐰 ADD: RABBITS FORMING CIRCLE
            // ================================
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _circleController,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: List.generate(widget.members.length, (i) {
                      final pos = getPosition(
                        i,
                        widget.members.length,
                        120,
                      );

                      return Transform.translate(
                        offset: pos,
                        child: Lottie.asset(
                          "assets/rabbits/Rabbit Kick Scooter.json",
                          width: 60,
                          height: 60,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),

            // ================================
            // 🧾 ORIGINAL RECEIPT UI (UNCHANGED)
            // ================================
            if (!(_circleController.isAnimating))
              GestureDetector(
                child: Container(
                  width: 85,
                  height: 85,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black26,
                      )
                    ],
                  ),
                  child: const Icon(Icons.receipt_long, size: 50),
                ),
              ),

            if (_circleController.isCompleted)
              ScaleTransition(
                scale: animation,
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBF2),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 20,
                        color: Colors.black12,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),

                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Expense Receipt ✨",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            hintText: "Expense Description",
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Amount",
                          ),
                        ),

                        const SizedBox(height: 20),

                        DropdownButtonFormField<String>(
                          value: selectedPayer,
                          items: widget.members
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPayer = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        Column(
                          children: widget.members.map((member) {
                            return CheckboxListTile(
                              title: Text(member),
                              value: selectedMembers.contains(member),
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    selectedMembers.add(member);
                                  } else {
                                    selectedMembers.remove(member);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 20),

                        Container(
                          height: 120,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Text("Upload Receipt Image"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: () {},
                          child: const Text("Save Expense"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}