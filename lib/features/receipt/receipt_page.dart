import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:ui';

enum SceneState {
  idleCircle,
  leaderApproaching,
  groupArriving,
  semicircleFormed,
  receiptReady,
  receiptOpened,
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

    // 🐰 START RABBITS FIRST
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() => showCircle = true);
      _circleController.forward();
    });

    // ================================
    // 🐰 APPROACH ANIMATION CONTROLLER
    // ================================
    _approachController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _approachController.addListener(() {
      setState(() {
        approachProgress = _approachController.value;
      });
    });

    // 🐰 START APPROACH FLOW (NEW)
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        _approachController.forward();
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

    super.dispose();
  }

  // ================================
  // 🐰 RABBIT POSITION LOGIC
  // ================================
  Offset getPosition(int index, int total, double radius) {
    if (total <= 1) {
      return Offset.zero;
    }

    final angle = (2 * pi * index) / total;

    final circleOffset = Offset(
      radius * _circleController.value * cos(angle),
      radius * _circleController.value * sin(angle),
    );

    // 🐰 APPROACH OFFSET (move toward center ball)
    final approachOffset = Offset(
      circleOffset.dx * (1 - approachProgress),
      circleOffset.dy * (1 - approachProgress),
    );

    return approachOffset;
  }

  // ================================
  // 🧾 OPEN RECEIPT
  // ================================
  void openReceipt() {
    setState(() {
      showReceipt = true;
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
              AnimatedBuilder(
                animation: _circleController,
                builder: (context, child) {
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
                      // 🟡 STEP 1: leader approaches receipt
                      // ================================
                      if (sceneState == SceneState.leaderApproaching) {
                        if (i == leaderIndex) {
                          base = Offset.lerp(
                            base,
                            receiptPosition,
                            approachProgress,
                          )!;
                        }
                      }

                      // ================================
                      // 🟠 STEP 2: group follows wave
                      // ================================
                      if (sceneState == SceneState.groupArriving) {
                        final delay = i * 0.08;
                        final t = (approachProgress - delay).clamp(0.0, 1.0);
                        base = Offset.lerp(base, receiptPosition, t)!;
                      }

                      // ================================
                      // 🟣 STEP 3: semicircle formation
                      // ================================
                      if (sceneState == SceneState.semicircleFormed) {
                        final radius = 170.0;
                        final angleStep = pi / (widget.members.length - 1);
                        final angle = -pi / 2 + (i * angleStep);

                        base = Offset(
                          receiptPosition.dx + radius * cos(angle),
                          receiptPosition.dy + radius * sin(angle),
                        );
                      }

                      final pos = base;
                      return Transform.translate(
                        offset: pos,

                        child: Transform.rotate(
                          angle: showReceipt ? (pos.dx > 0 ? -0.12 : 0.12) : 0,

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

                                    scale:
                                        selectedMembers.contains(
                                          widget.members[i],
                                        )
                                        ? 1.15
                                        : 1.0,

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

            // ================================
            // 🧾 FLOATING MAGIC CRUMPLED RECEIPT BALL (CENTER FIXED)
            // ================================
            if (showCircle && !showReceipt)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
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
                offset: Offset.zero,
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

                    child: Container(
                      width: 330,
                      height: 620,

                      margin: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        image: const DecorationImage(
                          image: AssetImage("assets/images/receipt.jpg"),
                          fit: BoxFit.cover,
                        ),

                        borderRadius: BorderRadius.circular(24),

                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 25,
                            color: Colors.black26,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),

                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 34, 28, 28),

                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              // ================================
                              // 🧾 DESCRIPTION
                              // ================================
                              const Text(
                                "Expense Description",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 10),

                              TextField(
                                controller: descriptionController,

                                decoration: InputDecoration(
                                  hintText: "Example: Korean BBQ 🍖",

                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.75),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),

                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ================================
                              // 💰 AMOUNT
                              // ================================
                              const Text(
                                "Amount",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 10),

                              TextField(
                                controller: amountController,
                                keyboardType: TextInputType.number,

                                decoration: InputDecoration(
                                  hintText: "0.00",

                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.75),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),

                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ================================
                              // 👤 WHO PAID
                              // ================================
                              const Text(
                                "Who Paid?",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 10),

                              DropdownButtonFormField<String>(
                                value: selectedPayer,

                                items: widget.members.map((member) {
                                  return DropdownMenuItem(
                                    value: member,
                                    child: Text(member),
                                  );
                                }).toList(),

                                onChanged: (value) {
                                  setState(() {
                                    selectedPayer = value;
                                  });
                                },

                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.75),

                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),

                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // ================================
                              // 🐰 SPLIT AMONG
                              // ================================
                              const Text(
                                "Split Among",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 14),

                              Wrap(
                                spacing: 12,
                                runSpacing: 12,

                                children: widget.members.map((member) {
                                  final isSelected = selectedMembers.contains(
                                    member,
                                  );

                                  return GestureDetector(
                                    onTap: () => toggleMember(member),
                                    behavior: HitTestBehavior.opaque,

                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),

                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 14,
                                      ),

                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,

                                        borderRadius: BorderRadius.circular(20),

                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.black
                                              : Colors.grey.shade300,
                                        ),

                                        boxShadow: isSelected
                                            ? [
                                                const BoxShadow(
                                                  blurRadius: 10,
                                                  color: Colors.black26,
                                                ),
                                              ]
                                            : [],
                                      ),

                                      child: Text(
                                        "🐰 $member",

                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,

                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),

                              const SizedBox(height: 28),

                              // ================================
                              // 📸 UPLOAD RECEIPT IMAGE
                              // ================================
                              Container(
                                height: 150,
                                width: double.infinity,

                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.75),

                                  borderRadius: BorderRadius.circular(22),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: const Center(
                                  child: Text("📸 Upload Receipt Image"),
                                ),
                              ),

                              const SizedBox(height: 34),

                              // ================================
                              // 💾 SAVE BUTTON
                              // ================================
                              SizedBox(
                                width: double.infinity,

                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,

                                    foregroundColor: Colors.white,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(22),
                                    ),
                                  ),

                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Expense Saved ✨"),
                                      ),
                                    );
                                  },

                                  child: const Text("Save Expense"),
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
