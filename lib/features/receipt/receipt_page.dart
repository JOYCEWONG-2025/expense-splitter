import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// ✅ ADD FOUNDATION IMPORT TO DETECT WEB RUNTIME Safely
import 'package:flutter/foundation.dart' show kIsWeb;

enum SceneState {
  idleCircle,
  leaderApproaching,
  groupArriving,
  semicircleFormed,
  receiptReady,
  receiptOpened,
}

// ✍️ STEP 3 — “INK WRITING ANIMATION” (Enhanced with character-by-character reveal)
class InkText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const InkText(this.text, {super.key, this.style});

  @override
  State<InkText> createState() => _InkTextState();
}

class _InkTextState extends State<InkText>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200), // Updated to matching requested millisecond pacing
    )..forward();
  }

  @override
  void didUpdateWidget(covariant InkText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        // 🪶 OPTION A: “Ink typing reveal” character-by-character mapping calculation
        final len = (widget.text.length * controller.value).floor();
        return Text(
          widget.text.substring(0, len),
          style: widget.style ?? const TextStyle(
            fontFamily: "Caveat", // ✨ Updated to use Caveat Handwriting font
            fontSize: 22,         // ✨ Adjusted to match requested sizing footprint
            color: Colors.black87,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

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
  // 🧾 ORIGINAL CONTROLLERS (KEEP LOGIC)
  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController amountController = TextEditingController();

  String? selectedPayer;
  List<String> selectedMembers = [];

  // 🎬 RECEIPT ANIMATION (KEEP ORIGINAL LOGIC)
  late AnimationController _receiptController;
  late Animation<double> animation;

  // 🐰 RABBIT CIRCLE ANIMATION
  late AnimationController _circleController;

  // RABBIT APPROACH RECEIPT
  late AnimationController _approachController;

  // ================================
  // 🧾 ADD: RECEIPT UNFOLD ANIMATION
  // ================================
  late AnimationController _unfoldController;
  late Animation<double> _scaleAnim;
  late Animation<double> _rotateAnim;
  late Animation<double> _fadeAnim;

  // ================================
  // ✨ ADD: FLOATING RECEIPT BALL ANIMATION
  // ================================
  late AnimationController _floatingController;

  late Animation<double> _floatingRotate;
  late Animation<double> _floatingScale;
  late Animation<double> _floatingMove;
  late Animation<double> _iconGlow;

  // Step 3: add variable
  File? uploadedImage;
  // ✅ ADD A STRING REFERENCE FOR WEB BLOB PATH RETENTION
  String? webImageBlobPath;
  final picker = ImagePicker();

  // ================================
  // 🧠 FLOW CONTROL
  // ================================
  bool showCircle = false;
  bool showReceipt = false;

  // ================================
  // 🎮 SCENE STATE CONTROLLER (NEW)
  // ================================
  SceneState sceneState = SceneState.idleCircle;

  // 🧠 animation progress (0 → 1)
  double approachProgress = 0.0;

  // 🐰 leader rabbit index
  int leaderIndex = 0;

  // 📍 receipt target position (center)
  final Offset receiptPosition = Offset(0, 0);

  @override
  void initState() {
    super.initState();

    // 🧾 ORIGINAL RECEIPT ANIMATION
    _receiptController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animation = CurvedAnimation(
      parent: _receiptController,
      curve: Curves.easeOut, // safer for opacity
    );

    // 🐰 RABBIT CIRCLE ANIMATION
    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // ================================
    // 🧾 ADD: REAL RECEIPT UNFOLD EFFECT
    // ================================
    _unfoldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    // ================================
    // ✨ FLOATING RECEIPT BALL
    // ================================
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatingRotate = Tween<double>(begin: -0.12, end: 0.12).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floatingScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _floatingMove = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _iconGlow = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    final curve = CurvedAnimation(
      parent: _unfoldController,
      curve: Curves.easeOutBack,
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(curve);

    _rotateAnim = Tween<double>(begin: -0.35, end: 0.0).animate(curve);

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    // ================================
    // 🐰 APPROACH ANIMATION CONTROLLER
    // ================================
    _approachController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 🐰 START RABBITS FIRST
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          showCircle = true;
        });

        _circleController.forward();
      }
    });
  }

  @override
  void dispose() {
    _receiptController.dispose();
    _circleController.dispose();

    // 🧾 ADD
    _unfoldController.dispose();
    _floatingController.dispose();

    // ✅ ADD THIS
    _approachController.dispose();

    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // Step 4: function
  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        // ✅ On Web, picked.path contains the blob address needed for display
        if (kIsWeb) {
          webImageBlobPath = picked.path;
        } else {
          uploadedImage = File(picked.path);
        }
      });
    }
  }

  // ✏️ STEP 2 — Add simple edit function
  void _edit(TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        final temp = TextEditingController(text: controller.text);

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Edit"),
          content: TextField(
            controller: temp,
            style: const TextStyle(fontFamily: "Caveat", fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  controller.text = temp.text;
                });
                Navigator.pop(context);
              },
              child: const Text("Done"),
            )
          ],
        );
      },
    );
  }

  // Helper dialog specifically processing selection assignment lists
  void _showPayerSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("Select Payer"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.members.length,
              itemBuilder: (context, index) {
                final member = widget.members[index];
                return ListTile(
                  title: Text(member, style: const TextStyle(fontFamily: "Caveat", fontSize: 18)),
                  trailing: selectedPayer == member ? const Icon(Icons.check, color: Colors.black) : null,
                  onTap: () {
                    setState(() {
                      selectedPayer = member;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ================================
  // 🐰 RABBIT POSITION LOGIC
  // ================================
  Offset getPosition(int index, int total, double radius) {
    if (total <= 1) {
      return Offset.zero;
    }

    final angle = (2 * pi * index) / total;

    return Offset(
      radius * _circleController.value * cos(angle),
      radius * _circleController.value * sin(angle),
    );
  }

  // ================================
  // 🧾 OPEN RECEIPT
  // ================================
  void openReceipt() {
    setState(() {
      showReceipt = true;
      sceneState = SceneState.receiptOpened;
    });

    _receiptController.forward(from: 0);
    _unfoldController.forward(from: 0);
  }

  // ================================
  // 🐰 MEMBER SELECT LOGIC
  // ================================
  void toggleMember(String member) {
    setState(() {
      if (selectedMembers.contains(member)) {
        selectedMembers.remove(member);
      } else {
        selectedMembers.add(member);
      }
    });
  }

  // ================================
  // 🎬 SCENE FLOW CONTROLLER (NEW)
  // ================================
  void startSceneFlow() async {
    setState(() {
      sceneState = SceneState.leaderApproaching;
    });

    _approachController.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 700));

    setState(() {
      sceneState = SceneState.groupArriving;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    setState(() {
      sceneState = SceneState.semicircleFormed;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      sceneState = SceneState.receiptReady;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F8),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("${widget.groupName} 🐰 Receipt"),
      ),

      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ================================
            // 🐰 RABBITS FORMING CIRCLE
            // ================================
            if (showCircle)
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_circleController, _approachController, _unfoldController]),
                  builder: (context, child) {
                    approachProgress = _approachController.value;
                    return Stack(
                      alignment: Alignment.center,
                      children: List.generate(widget.members.length, (i) {
                        final animatedRadius = lerpDouble(
                          155,
                          widget.members.length <= 4 ? 420 : 360,
                          _unfoldController.value,
                        )!;

                        Offset base = getPosition(
                          i,
                          widget.members.length,
                          animatedRadius,
                        );

                        // ================================
                        // 🟡 STEP 1 — ONLY LEADER MOVES
                        // ================================
                        if (sceneState == SceneState.leaderApproaching) {
                          if (i == leaderIndex) {
                            base = Offset.lerp(
                              base,
                              const Offset(0, 40),
                              approachProgress,
                            )!;
                          }
                        }
                        // ================================
                        // 🟠 STEP 2 — OTHER RABBITS FOLLOW
                        // ================================
                        else if (sceneState == SceneState.groupArriving) {
                          if (i == leaderIndex) {
                            base = const Offset(0, 40);
                          } else {
                            final delay = (i - 1) * 0.12;

                            final t = ((approachProgress - delay) / (1 - delay))
                                .clamp(0.0, 1.0);

                            base = Offset.lerp(
                              base,
                              Offset(base.dx * 0.45, base.dy * 0.45),
                              t,
                            )!;
                          }
                        }
                        // ================================
                        // 🟣 STEP 3 — FORM SEMICIRCLE
                        // Dynamic Left/Right Balance Split
                        // ================================
                        else if (sceneState == SceneState.semicircleFormed ||
                            sceneState == SceneState.receiptReady ||
                            showReceipt) {
                          
                          final int totalCount = widget.members.length;
                          final double radius = totalCount <= 4 ? 260.0 : 300.0;

                          if (totalCount <= 4) {
                            // 👈 If max 4 people: Keep entirely on the LEFT side arc
                            final double startAngle = pi * 0.7;
                            final double endAngle = pi * 1.3;
                            final double angleStep = totalCount <= 1 ? 0.0 : (endAngle - startAngle) / (totalCount - 1);
                            final double angle = startAngle + (i * angleStep);
                            final Offset arcCenter = const Offset(-170, 0);

                            base = Offset(
                              arcCenter.dx + radius * cos(angle),
                              arcCenter.dy + radius * sin(angle),
                            );
                          } else {
                            // ⚖️ If 5 or more people: Split and balance them between Left and Right wings
                            final int leftSideCount = (totalCount / 2).ceil();
                            final bool isLeftSide = i < leftSideCount;

                            if (isLeftSide) {
                              final double startAngle = pi * 0.7;
                              final double endAngle = pi * 1.3;
                              final double angleStep = leftSideCount <= 1 ? 0.0 : (endAngle - startAngle) / (leftSideCount - 1);
                              final double angle = startAngle + (i * angleStep);
                              final Offset arcCenter = const Offset(-170, 0);

                              base = Offset(
                                arcCenter.dx + radius * cos(angle),
                                arcCenter.dy + radius * sin(angle),
                              );
                            } else {
                              final int rightSideIndex = i - leftSideCount;
                              final int rightSideCount = totalCount - leftSideCount;
                              
                              final double startAngle = -pi * 0.3;
                              final double endAngle = pi * 0.3;
                              final double angleStep = rightSideCount <= 1 ? 0.0 : (endAngle - startAngle) / (rightSideCount - 1);
                              final double angle = startAngle + (rightSideIndex * angleStep);
                              final Offset arcCenter = const Offset(170, 0);

                              base = Offset(
                                arcCenter.dx + radius * cos(angle),
                                arcCenter.dy + radius * sin(angle),
                              );
                            }
                          }
                        }

                        final pos = base;
                        return Transform.translate(
                          offset: pos,
                          child: Transform.rotate(
                            angle: atan2(-pos.dy, -pos.dx) * 0.12,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // ================================
                                // 🐰 ANIMATED RABBIT
                                // ================================
                                GestureDetector(
                                  onTap: () => toggleMember(widget.members[i]),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow:
                                          selectedMembers.contains(
                                            widget.members[i],
                                          )
                                          ? [
                                              BoxShadow(
                                                color: Colors.amber.withOpacity(
                                                  0.7,
                                                ),
                                                blurRadius: 25,
                                                spreadRadius: 4,
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: AnimatedScale(
                                      duration: const Duration(milliseconds: 250),
                                      scale: showReceipt
                                          ? 0.88
                                          : (selectedMembers.contains(
                                                  widget.members[i],
                                                )
                                                ? 1.15
                                                : 1.0),
                                      child: Lottie.asset(
                                        "assets/rabbits/Rabbit Kick Scooter.json",
                                        width: 145,
                                        height: 145,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // ================================
                                // 🏷️ MEMBER NAME LABEL
                                // ================================
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    widget.members[i],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),

            // ================================
            // 🧾 FLOATING MAGIC CRUMPLED RECEIPT BALL (CENTER FIXED)
            // ================================
            if (showCircle && !showReceipt)
              Positioned.fill(
                bottom: 40,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: sceneState == SceneState.receiptReady
                        ? openReceipt
                        : startSceneFlow,
                    child: AnimatedBuilder(
                      animation: _floatingController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _floatingMove.value),
                          child: Transform.rotate(
                            angle: _floatingRotate.value,
                            child: Transform.scale(
                              scale: _floatingScale.value,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/crumpled_ball.png",
                                    width: 165,
                                    height: 165,
                                  ),
                                  Opacity(
                                    opacity: _iconGlow.value,
                                    child: const Icon(
                                      Icons.touch_app,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

            // ================================
            // 🧾 UNFOLDED RECEIPT PAPER
            // ================================
            if (showReceipt)
              Transform.translate(
                offset: widget.members.length <= 4 
                    ? const Offset(110, 0) 
                    : const Offset(0, 0),
                child: ScaleTransition(
                  scale: animation,
                  child: AnimatedBuilder(
                    animation: _unfoldController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _fadeAnim.value.clamp(0.0, 1.0),
                        child: Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..rotateZ(_rotateAnim.value)
                            ..scale(_scaleAnim.value)
                            ..translate(0.0, 10.0 * (1 - _fadeAnim.value)),
                          child: child,
                        ),
                      );
                    },
                    // ✅ FINAL STRUCTURE (what you should build) - Strict Stack Architecture
                    child: Container(
                      width: 330,
                      height: 620,
                      margin: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 25,
                            color: Colors.black26,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          width: 330,
                          height: 620,
                          child: Stack(
                            children: [
                              // ======================
                              // 🧾 BACKGROUND IMAGE ONLY
                              // ======================
                              Positioned.fill(
                                child: Image.asset(
                                  "assets/images/receipt.jpg",
                                  fit: BoxFit.cover,
                                ),
                              ),

                              // ======================
                              // ✏️ DESCRIPTION (TOP AREA)
                              // ======================
                              Positioned(
                                top: 120,
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _edit(descriptionController),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Item Label:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black.withOpacity(0.4),
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      // ✨ 6. “INK APPEARANCE” ANIMATION Layer via localized state injection
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(
                                          descriptionController.text.isEmpty
                                              ? "Tap to write..."
                                              : descriptionController.text,
                                          style: const TextStyle(
                                            fontFamily: "Caveat",
                                            fontSize: 22,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ======================
                              // 💰 AMOUNT (MIDDLE AREA)
                              // ======================
                              Positioned(
                                top: 200,
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _edit(amountController),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Total Due:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black.withOpacity(0.4),
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(
                                          amountController.text.isEmpty
                                              ? "0.00"
                                              : amountController.text,
                                          style: const TextStyle(
                                            fontFamily: "Caveat",
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ======================
                              // 🧾 STEP 2 — TURN EVERYTHING INTO “INK TEXT” - WHO PAID
                              // ======================
                              Positioned(
                                top: 280,
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _showPayerSelectionDialog,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Settled By:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black.withOpacity(0.4),
                                          fontFamily: 'serif',
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(
                                          selectedPayer ?? "Who paid? ✎",
                                          style: const TextStyle(
                                            fontFamily: "Caveat",
                                            fontSize: 20,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // ======================
                              // 👥 SPLIT MEMBERS INK LAYER
                              // ======================
                              Positioned(
                                top: 360,
                                left: 40,
                                right: 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Split Contribution Workspace:",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black.withOpacity(0.4),
                                        fontFamily: 'serif',
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    AnimatedOpacity(
                                      duration: const Duration(milliseconds: 600),
                                      opacity: showReceipt ? 1.0 : 0.0,
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: widget.members.map((member) {
                                          final isSelected = selectedMembers.contains(member);
                                          return GestureDetector(
                                            onTap: () => toggleMember(member),
                                            child: Text(
                                              isSelected ? "[✓] $member" : "[ ] $member",
                                              style: TextStyle(
                                                fontFamily: "Caveat",
                                                fontSize: 18,
                                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                color: isSelected ? Colors.black87 : Colors.black45,
                                                decoration: isSelected ? TextDecoration.none : TextDecoration.lineThrough,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // ======================
                              // 📸 STEP 4 — “Upload button disappears into paper”
                              // ======================
                              Positioned(
                                bottom: 150, 
                                left: 40,
                                right: 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: pickImage,
                                      child: AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(
                                          (kIsWeb ? webImageBlobPath == null : uploadedImage == null)
                                              ? "Attach receipt ✎"
                                              : "✓ receipt attached",
                                          style: const TextStyle(
                                            fontFamily: "Caveat",
                                            fontSize: 18,
                                            color: Colors.black87,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Subtle background layout reference displayer
                                    if (kIsWeb ? webImageBlobPath != null : uploadedImage != null) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 40,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          image: kIsWeb
                                              ? DecorationImage(
                                                  image: NetworkImage(webImageBlobPath!), 
                                                  fit: BoxFit.cover,
                                                )
                                              : DecorationImage(
                                                  image: FileImage(uploadedImage!), 
                                                  fit: BoxFit.cover,
                                                ),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),

                              // ======================
                              // 💾 STEP 5 — SAVE BUTTON (NO BOX)
                              // ======================
                              Positioned(
                                bottom: 60,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Expense Saved ✨")),
                                    );
                                  },
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 600),
                                    opacity: showReceipt ? 1.0 : 0.0,
                                    child: const Text(
                                      "Save →",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "Caveat",
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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