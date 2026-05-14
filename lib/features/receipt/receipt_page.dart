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
      duration: const Duration(milliseconds: 1200),
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
        final len = (widget.text.length * controller.value).floor();
        return Text(
          widget.text.substring(0, len),
          style: widget.style ?? const TextStyle(
            fontFamily: "Caveat", // ✨ Re-verified: Global matching font identifier mapping
            fontSize: 22,
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

  // 🧪 EXPERT SELECTIVE SPLITTING DATA STORAGE STRUCTURES
  bool isSelectiveModeActive = false;
  final Map<String, List<Map<String, dynamic>>> selectiveLedgers = {};

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

  // 🎈 TAP ME EXPRESSION MOTION ANIMATION CONTROLLER
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  File? uploadedImage;
  String? webImageBlobPath;
  final picker = ImagePicker();

  // ================================
  // 🧠 FLOW CONTROL
  // ================================
  bool showCircle = false;
  bool showReceipt = false;

  // ================================
  // 245 SCENE STATE CONTROLLER (NEW)
  // ================================
  SceneState sceneState = SceneState.idleCircle;

  double approachProgress = 0.0;
  int leaderIndex = 0;
  final Offset receiptPosition = Offset(0, 0);

  @override
  void initState() {
    super.initState();

    _receiptController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animation = CurvedAnimation(
      parent: _receiptController,
      curve: Curves.easeOut,
    );

    _circleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _unfoldController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

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

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );

    final curve = CurvedAnimation(
      parent: _unfoldController,
      curve: Curves.easeOutBack,
    );

    _scaleAnim = Tween<double>(begin: 0.3, end: 1.0).animate(curve);
    _rotateAnim = Tween<double>(begin: -0.35, end: 0.0).animate(curve);
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curve);

    _approachController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    for (var member in widget.members) {
      selectiveLedgers[member] = [];
    }

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
    _unfoldController.dispose();
    _floatingController.dispose();
    _bounceController.dispose();
    _approachController.dispose();
    descriptionController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        if (kIsWeb) {
          webImageBlobPath = picked.path;
        } else {
          uploadedImage = File(picked.path);
        }
      });
    }
  }

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

  void _triggerModeExplanationBanner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text("Choose Your Split Theme 📖", style: TextStyle(fontFamily: "Caveat", fontSize: 26, fontWeight: FontWeight.bold)),
          content: const Text(
            "Would you like a Fair Global Split for everyone? Or a personalized tale?\n\n💡 Tip: If your friends paid for different things, tap 'Selective Ledger 🎨' in the lower section to customize item bills for each rabbit individual step-by-step!",
            style: TextStyle(fontFamily: "Caveat", fontSize: 20, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Let's Begin ✨", style: TextStyle(fontFamily: "Caveat", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple)),
            )
          ],
        );
      },
    );
  }

  void _openRabbitCustomLedgerForm(String name) {
    final TextEditingController itemNameInput = TextEditingController();
    final TextEditingController itemCostInput = TextEditingController();
    List<String> involvedParty = List.from(widget.members);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setInnerState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Text("🐰 Customize $name's Story", style: const TextStyle(fontFamily: "Caveat", fontSize: 24, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: itemNameInput, decoration: const InputDecoration(hintText: "What did they pay for? (e.g., Food 🍖)")),
                  TextField(controller: itemCostInput, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Total expense amount")),
                  const SizedBox(height: 16),
                  const Align(alignment: Alignment.centerLeft, child: Text("Split Shared Among:", style: TextStyle(fontFamily: "Caveat", fontSize: 16, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: widget.members.map((friend) {
                      final bool isChecked = involvedParty.contains(friend);
                      return ChoiceChip(
                        label: Text(friend, style: const TextStyle(fontFamily: "Caveat", fontSize: 14)),
                        selected: isChecked,
                        selectedColor: Colors.purple.shade100,
                        onSelected: (val) {
                          setInnerState(() {
                            if (val) {
                              involvedParty.add(friend);
                            } else {
                              involvedParty.remove(friend);
                            }
                          });
                        },
                      );
                    }).toList(),
                  )
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      selectiveLedgers[name]!.add({"label": "Skipped 🍃", "cost": 0.0, "splitWith": []});
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name skipped this entry round.")));
                  },
                  child: const Text("Skip Rabbit 🍃", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                  onPressed: () {
                    if (itemNameInput.text.isNotEmpty && itemCostInput.text.isNotEmpty) {
                      setState(() {
                        selectiveLedgers[name]!.add({
                          "label": itemNameInput.text,
                          "cost": double.tryParse(itemCostInput.text) ?? 0.0,
                          "splitWith": involvedParty,
                        });
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save Entry", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  Offset getPosition(int index, int total, double radius) {
    if (total <= 1) return Offset.zero;
    final angle = (2 * pi * index) / total;
    return Offset(
      radius * _circleController.value * cos(angle),
      radius * _circleController.value * sin(angle),
    );
  }

  void openReceipt() {
    setState(() {
      showReceipt = true;
      sceneState = SceneState.receiptOpened;
    });
    _receiptController.forward(from: 0);
    _unfoldController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 950), () {
      _triggerModeExplanationBanner();
    });
  }

  void toggleMember(String member) {
    setState(() {
      if (selectedMembers.contains(member)) {
        selectedMembers.remove(member);
      } else {
        selectedMembers.add(member);
      }
    });
  }

  void startSceneFlow() async {
    if (sceneState == SceneState.receiptOpened) return;

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
    String? firstUnconfiguredRabbit;
    if (showReceipt && isSelectiveModeActive) {
      for (var m in widget.members) {
        if (selectiveLedgers[m]!.isEmpty) {
          firstUnconfiguredRabbit = m;
          break;
        }
      }
    }

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
            // ==========================================
            // LAYER 1: THE RABBIT WORKSPACE 
            // ==========================================
            if (showCircle)
              IgnorePointer(
                ignoring: !showReceipt, 
                child: RepaintBoundary(
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

                        Offset base = getPosition(i, widget.members.length, animatedRadius);

                        if (sceneState == SceneState.receiptOpened) {
                          final int totalCount = widget.members.length;
                          final double radius = totalCount <= 4 ? 260.0 : 300.0;
                          if (totalCount <= 4) {
                            final double startAngle = pi * 0.7;
                            final double endAngle = pi * 1.3;
                            final double angleStep = totalCount <= 1 ? 0.0 : (endAngle - startAngle) / (totalCount - 1);
                            base = Offset(const Offset(-170, 0).dx + radius * cos(startAngle + (i * angleStep)), const Offset(-170, 0).dy + radius * sin(startAngle + (i * angleStep)));
                          } else {
                            final int leftSideCount = (totalCount / 2).ceil();
                            if (i < leftSideCount) {
                              final double startAngle = pi * 0.7;
                              final double endAngle = pi * 1.3;
                              final double angleStep = leftSideCount <= 1 ? 0.0 : (endAngle - startAngle) / (leftSideCount - 1);
                              base = Offset(const Offset(-170, 0).dx + radius * cos(startAngle + (i * angleStep)), const Offset(-170, 0).dy + radius * sin(startAngle + (i * angleStep)));
                            } else {
                              final int rightSideIndex = i - leftSideCount;
                              final int rightSideCount = totalCount - leftSideCount;
                              final double startAngle = -pi * 0.3;
                              final double endAngle = pi * 0.3;
                              final double angleStep = rightSideCount <= 1 ? 0.0 : (endAngle - startAngle) / (rightSideCount - 1);
                              base = Offset(const Offset(170, 0).dx + radius * cos(startAngle + (rightSideIndex * angleStep)), const Offset(170, 0).dy + radius * sin(startAngle + (rightSideIndex * angleStep)));
                            }
                          }
                        } else {
                          if (sceneState == SceneState.leaderApproaching && i == leaderIndex) {
                            base = Offset.lerp(base, const Offset(0, 40), approachProgress)!;
                          } else if (sceneState == SceneState.groupArriving) {
                            if (i == leaderIndex) {
                              base = const Offset(0, 40);
                            } else {
                              final delay = (i - 1) * 0.12;
                              final t = ((approachProgress - delay) / (1 - delay)).clamp(0.0, 1.0);
                              base = Offset.lerp(base, Offset(base.dx * 0.45, base.dy * 0.45), t)!;
                            }
                          } else if (sceneState == SceneState.semicircleFormed || sceneState == SceneState.receiptReady) {
                            final int totalCount = widget.members.length;
                            final double radius = totalCount <= 4 ? 260.0 : 300.0;
                            if (totalCount <= 4) {
                              final double startAngle = pi * 0.7;
                              final double endAngle = pi * 1.3;
                              final double angleStep = totalCount <= 1 ? 0.0 : (endAngle - startAngle) / (totalCount - 1);
                              base = Offset(const Offset(-170, 0).dx + radius * cos(startAngle + (i * angleStep)), const Offset(-170, 0).dy + radius * sin(startAngle + (i * angleStep)));
                            } else {
                              final int leftSideCount = (totalCount / 2).ceil();
                              if (i < leftSideCount) {
                                final double startAngle = pi * 0.7;
                                final double endAngle = pi * 1.3;
                                final double angleStep = leftSideCount <= 1 ? 0.0 : (endAngle - startAngle) / (leftSideCount - 1);
                                base = Offset(const Offset(-170, 0).dx + radius * cos(startAngle + (i * angleStep)), const Offset(-170, 0).dy + radius * sin(startAngle + (i * angleStep)));
                              } else {
                                final int rightSideIndex = i - leftSideCount;
                                final int rightSideCount = totalCount - leftSideCount;
                                final double startAngle = -pi * 0.3;
                                final double endAngle = pi * 0.3;
                                final double angleStep = rightSideCount <= 1 ? 0.0 : (endAngle - startAngle) / (rightSideCount - 1);
                                base = Offset(const Offset(170, 0).dx + radius * cos(startAngle + (rightSideIndex * angleStep)), const Offset(170, 0).dy + radius * sin(startAngle + (rightSideIndex * angleStep)));
                              }
                            }
                          }
                        }

                        final pos = base;
                        final currentRabbitName = widget.members[i];

                        return Transform.translate(
                          offset: pos,
                          child: Transform.rotate(
                            angle: atan2(-pos.dy, -pos.dx) * 0.12,
                            child: GestureDetector(
                              key: ValueKey("rabbit_$currentRabbitName"),
                              behavior: HitTestBehavior.opaque, 
                              onTap: () {
                                if (showReceipt && isSelectiveModeActive) {
                                  _openRabbitCustomLedgerForm(currentRabbitName);
                                } else if (!showReceipt) {
                                  toggleMember(currentRabbitName);
                                }
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                alignment: Alignment.topCenter,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 250),
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: selectedMembers.contains(currentRabbitName) ? [BoxShadow(color: Colors.amber.withOpacity(0.7), blurRadius: 25, spreadRadius: 4)] : [],
                                        ),
                                        child: AnimatedScale(
                                          duration: const Duration(milliseconds: 250),
                                          scale: showReceipt ? 0.88 : (selectedMembers.contains(currentRabbitName) ? 1.15 : 1.0),
                                          child: Lottie.asset("assets/rabbits/Rabbit Kick Scooter.json", width: 145, height: 145),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                                        child: Text(currentRabbitName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      ),
                                    ],
                                  ),
                                  if (currentRabbitName == firstUnconfiguredRabbit)
                                    AnimatedBuilder(
                                      animation: _bounceAnimation,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: -30 + _bounceAnimation.value,
                                          child: child!,
                                        );
                                      },
                                      child: Material(
                                        color: Colors.purple.shade700,
                                        elevation: 6,
                                        borderRadius: BorderRadius.circular(10),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Tap Me!",
                                                style: TextStyle(fontFamily: "Caveat", color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                              ),
                                              SizedBox(width: 4),
                                              Text(
                                                "🐾",
                                                style: TextStyle(color: Colors.white, fontSize: 14), 
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),

            if (showCircle && !showReceipt)
              Positioned.fill(
                bottom: 40,
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: sceneState == SceneState.receiptReady ? openReceipt : startSceneFlow, 
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
                                  Image.asset("assets/images/crumpled_ball.png", width: 165, height: 165),
                                  Opacity(opacity: _iconGlow.value, child: const Icon(Icons.touch_app, size: 40)),
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

            // ==========================================
            // LAYER 2: THE UNFOLDED RECEIPT SHEET
            // ==========================================
            if (showReceipt)
              Transform.translate(
                offset: widget.members.length <= 4 ? const Offset(110, 0) : const Offset(0, 0),
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
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(blurRadius: 25, color: Colors.black26, offset: Offset(0, 12))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          width: 330,
                          height: 620,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Image.asset("assets/images/receipt.jpg", fit: BoxFit.cover),
                              ),

                              Positioned(
                                top: 120,
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!isSelectiveModeActive) _edit(descriptionController);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Item Label:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45, fontFamily: "Caveat")),
                                      const SizedBox(height: 2),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(isSelectiveModeActive ? "Selective Tracking Active" : (descriptionController.text.isEmpty ? "Tap to write..." : descriptionController.text)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 200,
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!isSelectiveModeActive) _edit(amountController);
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Total Due:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45, fontFamily: "Caveat")),
                                      const SizedBox(height: 2),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(
                                          isSelectiveModeActive ? "Multi-Ledger Calculated" : (amountController.text.isEmpty ? "0.00" : amountController.text),
                                          style: const TextStyle(fontFamily: "Caveat", fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 280,
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    if (!isSelectiveModeActive) _showPayerSelectionDialog();
                                  },
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Settled By:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45, fontFamily: "Caveat")),
                                      const SizedBox(height: 2),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 600),
                                        opacity: showReceipt ? 1.0 : 0.0,
                                        child: InkText(isSelectiveModeActive ? "Tap Rabbits Individually" : (selectedPayer ?? "Who paid? ✎")),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Positioned(
                                top: 360,
                                left: 40,
                                right: 40,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Split Contribution Workspace:", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45, fontFamily: "Caveat")),
                                    const SizedBox(height: 6),
                                    AnimatedOpacity(
                                      duration: const Duration(milliseconds: 600),
                                      opacity: showReceipt ? 1.0 : 0.0,
                                      child: isSelectiveModeActive 
                                        ? const Text("✨ Selective Mode Active! Tap rabbits outside to append rows.", style: TextStyle(fontFamily: "Caveat", fontSize: 16, color: Colors.purple, fontWeight: FontWeight.bold))
                                        : Wrap(
                                            spacing: 8,
                                            runSpacing: 4,
                                            children: widget.members.map((member) {
                                              final isSelected = selectedMembers.contains(member);
                                              return GestureDetector(
                                                onTap: () => toggleMember(member),
                                                child: Text(
                                                  isSelected ? "[✓] $member" : "[ ] $member",
                                                  style: TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black87 : Colors.black45, decoration: isSelected ? TextDecoration.none : TextDecoration.lineThrough),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // ==========================================
                              // 📸 IMAGE ATTACHMENT FIELD
                              // ==========================================
                              Positioned(
                                bottom: 165,
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
                                          (kIsWeb ? webImageBlobPath == null : uploadedImage == null) ? "Attach receipt ✎" : "✓ receipt attached",
                                          style: const TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.black87, decoration: TextDecoration.underline),
                                        ),
                                      ),
                                    ),
                                    if (kIsWeb ? webImageBlobPath != null : uploadedImage != null) ...[
                                      const SizedBox(height: 6),
                                      Container(
                                        height: 40,
                                        width: 100,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          image: kIsWeb
                                              ? DecorationImage(image: NetworkImage(webImageBlobPath!), fit: BoxFit.cover)
                                              : DecorationImage(image: FileImage(uploadedImage!), fit: BoxFit.cover),
                                        ),
                                      )
                                    ]
                                  ],
                                ),
                              ),

                              // ========================================================
                              // 🧾 FINE-TUNED SELECTIVE SPLIT TRIGGER
                              // ✅ LOCKED COORD POSITION: Set at exactly bottom: 132 so it floats safely
                              // underneath the file attachment widget zone.
                              // ========================================================
                              Positioned(
                                bottom: 132, 
                                left: 40,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      isSelectiveModeActive = !isSelectiveModeActive;
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(isSelectiveModeActive ? "Selective Ledger Enabled! Tap rabbits to add rows." : "Returned to Global Split Mode.")),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      isSelectiveModeActive ? "✓ Selective Mode Enabled" : "➔ Switch to Selective Ledger 🎨",
                                      style: TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: FontWeight.bold, color: isSelectiveModeActive ? Colors.purple : Colors.black54),
                                    ),
                                  ),
                                ),
                              ),

                              Positioned(
                                bottom: 60,
                                right: 40,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Expense Story Saved ✨")),
                                    );
                                  },
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 600),
                                    opacity: showReceipt ? 1.0 : 0.0,
                                    child: const Text("Save →", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: "Caveat", color: Colors.black87)),
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