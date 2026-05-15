import 'dart:math';
import 'package:flutter/material.dart';
import 'package:expense_splitter/features/receipt/receipt_page.dart';
import 'package:expense_splitter/features/models/rabbit_model.dart';
import 'package:expense_splitter/widgets/rabbit_card.dart';

class GroupCreationPage extends StatefulWidget {
  final String worldTitle;
  final int selectedDay;

  const GroupCreationPage({
    super.key,
    required this.worldTitle,
    required this.selectedDay,
  });

  @override
  State<GroupCreationPage> createState() => _GroupCreationPageState();
}

class _GroupCreationPageState extends State<GroupCreationPage>
    with TickerProviderStateMixin {
  final TextEditingController groupController = TextEditingController();
  final TextEditingController memberController = TextEditingController();
  List<RabbitModel> members = [];

  // ✨ STAR TWINKLE ANIMATION
  AnimationController? _starController;
  AnimationController? _bubbleController;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _starController?.dispose();
    _bubbleController?.dispose();
    groupController.dispose();
    memberController.dispose();
    super.dispose();
  }

  // 🪄 DISNEY STYLE INLINE MEMBER NAME EDITING UTILITY
  void _editRabbitName(int index) {
    final TextEditingController editController = TextEditingController(
      text: members[index].name,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            "Change Friend Identity 🪄",
            style: TextStyle(
              fontFamily: "Caveat",
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: editController,
            style: const TextStyle(fontFamily: "Caveat", fontSize: 20),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF6F1F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9B7FBD),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (editController.text.isNotEmpty) {
                  setState(() {
                    members[index] = RabbitModel(
                      name: editController.text,
                      rabbitAsset: members[index].rabbitAsset,
                    );
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Apply ✨"),
            ),
          ],
        );
      },
    );
  }

  // 🏰 DISNEY CASTLE PAINTER
  Widget _buildCastleSilhouette() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: CustomPaint(
        size: const Size(double.infinity, 220),
        painter: _CastlePainter(),
      ),
    );
  }

  // ✨ FLOATING STAR
  Widget _buildStar(double top, double left, double size, double opacity) {
    return AnimatedBuilder(
      animation: _starController!,
      builder: (context, child) {
        return Positioned(
          top: top + ((_starController?.value ?? 0) * 6),
          left: left,
          child: Opacity(
            opacity: opacity * (0.5 + (_starController?.value ?? 0) * 0.5),
            child: Text(
              "✦",
              style: TextStyle(fontSize: size, color: const Color(0xFF9B7FBD)),
            ),
          ),
        );
      },
    );
  }

  // 🫧 FLOATING BUBBLE
  Widget _buildBubble(double top, double left, double size) {
    return AnimatedBuilder(
      animation: _bubbleController!,
      builder: (context, child) {
        return Positioned(
          top: top + ((_bubbleController?.value ?? 0) * 10),
          left: left,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE8D5F5).withOpacity(0.35),
              border: Border.all(
                color: const Color(0xFF9B7FBD).withOpacity(0.25),
                width: 1.5,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 🎨 MACARON LAVENDER BACKGROUND
      backgroundColor: const Color(0xFFF5F0FF),

      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "${widget.worldTitle} Group 🐰",
          style: const TextStyle(
            color: Color(0xFF6B4F8A),
            fontFamily: "Caveat",
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF6B4F8A)),
      ),

      body: Stack(
        children: [
          // ⭐ STEP 1: LAVENDER GRADIENT BACKGROUND
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFEDE0FF), // lavender top
                    Color(0xFFFDF8FF), // cream bottom
                  ],
                ),
              ),
            ),
          ),

          // 🏰 STEP 2: CASTLE SILHOUETTE
          _buildCastleSilhouette(),

          // ✨ STEP 3: FLOATING STARS
          _buildStar(60, 20, 14, 0.7),
          _buildStar(100, 300, 10, 0.5),
          _buildStar(150, 180, 12, 0.6),
          _buildStar(200, 50, 8, 0.4),
          _buildStar(80, 340, 16, 0.8),
          _buildStar(130, 120, 10, 0.5),

          // 🫧 STEP 4: FLOATING BUBBLES
          _buildBubble(300, 20, 40),
          _buildBubble(450, 320, 28),
          _buildBubble(550, 60, 50),
          _buildBubble(400, 280, 35),
          _buildBubble(620, 180, 22),

          // 📋 STEP 5: MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🌟 CASTLE SPACE
                  const SizedBox(height: 130),

                  Text(
                    "${widget.selectedDay} May Timeline ✨",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF9B7FBD),
                      fontFamily: "Caveat",
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 📖 GROUP NAME
                  const Text(
                    "Group / Trip Name",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4F8A),
                      fontFamily: "Caveat",
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: groupController,
                    style: const TextStyle(fontFamily: "Caveat", fontSize: 18),
                    decoration: InputDecoration(
                      hintText: "Example: Korea Food Trip 🍜",
                      hintStyle: TextStyle(
                        fontFamily: "Caveat",
                        color: Colors.purple.withOpacity(0.4),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.85),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 👥 MEMBER SECTION
                  const Text(
                    "Add Rabbit Friends 👥",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B4F8A),
                      fontFamily: "Caveat",
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: memberController,
                          style: const TextStyle(
                            fontFamily: "Caveat",
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter friend name",
                            hintStyle: TextStyle(
                              fontFamily: "Caveat",
                              color: Colors.purple.withOpacity(0.4),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.85),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B7FBD),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          if (memberController.text.isNotEmpty) {
                            setState(() {
                              members.add(
                                RabbitModel(
                                  name: memberController.text,
                                  rabbitAsset:
                                      "assets/rabbits/Rabbit Kick Scooter.json",
                                ),
                              );
                              memberController.clear();
                            });
                          }
                        },
                        child: const Text(
                          "Add",
                          style: TextStyle(fontFamily: "Caveat", fontSize: 18),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 🐰 MEMBER LIST
                  Expanded(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 90.0),
                              child: DefaultTextStyle(
                                style: const TextStyle(
                                  fontFamily: "Caveat",
                                  fontSize: 22,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                child: RabbitCard(
                                  rabbitName: members[index].name,
                                  rabbitAsset: members[index].rabbitAsset,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ✏️ EDIT BUTTON
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: Color(0xFF9B7FBD),
                                    size: 22,
                                  ),
                                  onPressed: () => _editRabbitName(index),
                                ),
                                // 🗑️ DELETE BUTTON
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      members.removeAt(index);
                                    });
                                  },
                                ),
                                const SizedBox(width: 16),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  // 🚀 START STORY BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B7FBD),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF9B7FBD).withOpacity(0.4),
                      ),
                      onPressed: () {
                        if (groupController.text.isEmpty || members.isEmpty) {
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReceiptPage(
                              groupName: groupController.text,
                              members: members
                                  .map((rabbit) => rabbit.name)
                                  .toList(),
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Start Expense Story ✨",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Caveat",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🏰 DISNEY CASTLE CUSTOM PAINTER
class _CastlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFD8C2F0) // soft lavender castle
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = const Color(0xFFBFA3E0).withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // === MAIN CASTLE BODY ===
    // Central tall tower
    _drawTower(canvas, paint, shadowPaint, w * 0.5 - 30, h * 0.1, 60, h * 0.75);

    // Left tall tower
    _drawTower(
      canvas,
      paint,
      shadowPaint,
      w * 0.3 - 20,
      h * 0.25,
      40,
      h * 0.65,
    );

    // Right tall tower
    _drawTower(
      canvas,
      paint,
      shadowPaint,
      w * 0.7 - 20,
      h * 0.25,
      40,
      h * 0.65,
    );

    // Far left small tower
    _drawTower(
      canvas,
      paint,
      shadowPaint,
      w * 0.15 - 15,
      h * 0.4,
      30,
      h * 0.55,
    );

    // Far right small tower
    _drawTower(
      canvas,
      paint,
      shadowPaint,
      w * 0.85 - 15,
      h * 0.4,
      30,
      h * 0.55,
    );

    // === CONNECTING WALLS ===
    final wallPath = Path()
      ..moveTo(w * 0.1, h)
      ..lineTo(w * 0.1, h * 0.6)
      ..lineTo(w * 0.9, h * 0.6)
      ..lineTo(w * 0.9, h)
      ..close();
    canvas.drawPath(wallPath, paint);

    // === GATE ARCH ===
    final gatePaint = Paint()
      ..color = const Color(0xFFC4A8E8)
      ..style = PaintingStyle.fill;

    final gateRect = Rect.fromLTWH(w * 0.44, h * 0.72, w * 0.12, h * 0.3);
    canvas.drawArc(gateRect, pi, pi, true, gatePaint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.44, h * 0.85, w * 0.12, h * 0.2),
      gatePaint,
    );

    // === WINDOWS ===
    final windowPaint = Paint()
      ..color = const Color(0xFFC4A8E8)
      ..style = PaintingStyle.fill;

    // Central tower window
    _drawWindow(canvas, windowPaint, w * 0.5 - 8, h * 0.3, 16, 22);

    // Left tower window
    _drawWindow(canvas, windowPaint, w * 0.3 - 10, h * 0.42, 12, 18);

    // Right tower window
    _drawWindow(canvas, windowPaint, w * 0.7 - 2, h * 0.42, 12, 18);

    // === LITTLE FLAGS ===
    final flagPaint = Paint()
      ..color = const Color(0xFFE8D5F5)
      ..style = PaintingStyle.fill;

    _drawFlag(canvas, flagPaint, w * 0.5, h * 0.08);
    _drawFlag(canvas, flagPaint, w * 0.3, h * 0.23);
    _drawFlag(canvas, flagPaint, w * 0.7, h * 0.23);
    _drawFlag(canvas, flagPaint, w * 0.15, h * 0.38);
    _drawFlag(canvas, flagPaint, w * 0.85, h * 0.38);
  }

  void _drawTower(
    Canvas canvas,
    Paint paint,
    Paint shadowPaint,
    double x,
    double y,
    double width,
    double height,
  ) {
    // Tower body
    canvas.drawRect(Rect.fromLTWH(x, y, width, height), paint);

    // Battlements (top crenellations)
    final battlementWidth = width / 5;
    for (int i = 0; i < 3; i++) {
      canvas.drawRect(
        Rect.fromLTWH(
          x + (i * battlementWidth * 1.5),
          y - battlementWidth,
          battlementWidth,
          battlementWidth,
        ),
        paint,
      );
    }

    // Cone roof
    final roofPaint = Paint()
      ..color = const Color(0xFFBFA3E0)
      ..style = PaintingStyle.fill;

    final roofPath = Path()
      ..moveTo(x + width / 2, y - width * 0.9)
      ..lineTo(x, y)
      ..lineTo(x + width, y)
      ..close();
    canvas.drawPath(roofPath, roofPaint);
  }

  void _drawWindow(
    Canvas canvas,
    Paint paint,
    double x,
    double y,
    double w,
    double h,
  ) {
    final windowPath = Path()
      ..addOval(Rect.fromLTWH(x, y, w, w))
      ..addRect(Rect.fromLTWH(x, y + w / 2, w, h - w / 2));
    canvas.drawPath(windowPath, paint);
  }

  void _drawFlag(Canvas canvas, Paint paint, double x, double y) {
    final flagPath = Path()
      ..moveTo(x, y)
      ..lineTo(x + 12, y + 5)
      ..lineTo(x, y + 10)
      ..close();
    canvas.drawPath(flagPath, paint);

    // Flag pole
    final polePaint = Paint()
      ..color = const Color(0xFFBFA3E0)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(x, y - 5), Offset(x, y + 12), polePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
