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
  summaryView, // ✨ NEW STATE: The Magical Book-Flip Summary Canvas
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

  // 🪙 NEW DATA STRUCTURES FOR MAGIC MATHEMATICS
  List<Map<String, dynamic>> computedDebts = [];
  Map<String, double> totalSpendingPerRabbit = {};
  Map<String, double> totalBenefitPerRabbit = {};
  bool isEntirelySettled = false;

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

  // 📖 NEW BOOK FLIP TRANSITION ANIMATION CONTROLLERS
  late AnimationController _bookFlipController;
  late Animation<double> _bookFlipAnimation;

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

    _bookFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _bookFlipAnimation = CurvedAnimation(
      parent: _bookFlipController,
      curve: Curves.easeInOutCubic,
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
      totalSpendingPerRabbit[member] = 0.0;
      totalBenefitPerRabbit[member] = 0.0;
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
    _bookFlipController.dispose();
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Text("🐰 $name's Travel Diary Entry ✨", style: const TextStyle(fontFamily: "Caveat", fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("What magical thing did you buy?", style: TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.purple.shade400, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: itemNameInput, 
                    style: const TextStyle(fontFamily: "Caveat", fontSize: 18),
                    decoration: const InputDecoration(hintText: "e.g., Train Rides 🚂, Yummy Feast 🍖"),
                  ),
                  const SizedBox(height: 18),
                  Text("How many coins did it cost? 🪙", style: TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.purple.shade400, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: itemCostInput, 
                    keyboardType: TextInputType.number, 
                    style: const TextStyle(fontFamily: "Caveat", fontSize: 18),
                    decoration: const InputDecoration(hintText: "0.00"),
                  ),
                  const SizedBox(height: 22),
                  const Align(
                    alignment: Alignment.centerLeft, 
                    child: Text("Share this cost with your companions: 👥", style: TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54))
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: widget.members.map((friend) {
                      final bool isChecked = involvedParty.contains(friend);
                      return ChoiceChip(
                        label: Text(friend, style: const TextStyle(fontFamily: "Caveat", fontSize: 15)),
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
                  child: const Text("Skip Rabbit 🍃", style: TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                  ),
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
                  child: const Text("Add to Ledger 📖", style: TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // 🪙 EXECUTABLE TREASURY ALGORITHM ENGINE FOR STABLE RE-ARRANGEMENTS
  void _executeSettlementMathematics() {
    Map<String, double> balances = {};
    for (var m in widget.members) {
      balances[m] = 0.0;
      totalSpendingPerRabbit[m] = 0.0;
      totalBenefitPerRabbit[m] = 0.0;
    }

    if (!isSelectiveModeActive) {
      // GLOBAL MODE CALCULATION
      double totalCost = double.tryParse(amountController.text) ?? 0.0;
      String payer = selectedPayer ?? (widget.members.isNotEmpty ? widget.members.first : "");
      List<String> activeConsumers = selectedMembers.isEmpty ? widget.members : selectedMembers;

      if (widget.members.contains(payer)) {
        totalSpendingPerRabbit[payer] = totalCost;
      }
      
      double costPerHead = activeConsumers.isNotEmpty ? (totalCost / activeConsumers.length) : 0.0;
      for (var consumer in activeConsumers) {
        totalBenefitPerRabbit[consumer] = costPerHead;
      }

      for (var m in widget.members) {
        balances[m] = totalSpendingPerRabbit[m]! - totalBenefitPerRabbit[m]!;
      }
    } else {
      // SELECTIVE LEDGER ENGINE DECOMPOSITION LOOP
      selectiveLedgers.forEach((payer, entryList) {
        for (var entry in entryList) {
          double cost = entry["cost"] ?? 0.0;
          List<String> sharingList = List<String>.from(entry["splitWith"] ?? []);
          
          totalSpendingPerRabbit[payer] = (totalSpendingPerRabbit[payer] ?? 0.0) + cost;
          if (sharingList.isNotEmpty) {
            double sharedPart = cost / sharingList.length;
            for (var recipient in sharingList) {
              totalBenefitPerRabbit[recipient] = (totalBenefitPerRabbit[recipient] ?? 0.0) + sharedPart;
            }
          }
        }
      });

      for (var m in widget.members) {
        balances[m] = (totalSpendingPerRabbit[m] ?? 0.0) - (totalBenefitPerRabbit[m] ?? 0.0);
      }
    }

    // GREEDY TWO-POINTER DEBT MINIMIZER MIN-MAX MATCHER
    computedDebts.clear();
    List<Map<String, dynamic>> debtors = [];
    List<Map<String, dynamic>> creditors = [];

    balances.forEach((rabbit, bal) {
      if (bal < -0.01) {
        debtors.add({"name": rabbit, "bal": bal.abs()});
      } else if (bal > 0.01) {
        creditors.add({"name": rabbit, "bal": bal});
      }
    });

    int dIdx = 0, cIdx = 0;
    while (dIdx < debtors.length && cIdx < creditors.length) {
      var d = debtors[dIdx];
      var c = creditors[cIdx];
      double executionAmount = min(d["bal"], c["bal"]);

      computedDebts.add({
        "from": d["name"],
        "to": c["name"],
        "amount": executionAmount,
      });

      d["bal"] -= executionAmount;
      c["bal"] -= executionAmount;

      if (d["bal"] < 0.01) dIdx++;
      if (c["bal"] < 0.01) cIdx++;
    }

    setState(() {
      isEntirelySettled = computedDebts.isEmpty;
      sceneState = SceneState.summaryView;
    });
    _bookFlipController.forward(from: 0.0);
  }

  // 📜 POPUP DIARY NOTEBOOK WITH AUTOMATED DISNEY CHARACTER AWARDS
  void _showRabbitStorybookAwardDialog(String name) {
    double spent = totalSpendingPerRabbit[name] ?? 0.0;
    double consumed = totalBenefitPerRabbit[name] ?? 0.0;
    
    String awardTitle = "🍃 Clever Forest Explorer";
    String awardDesc = "You traveled along beautifully, keeping your coin purse perfectly balanced under the canopy shadows!";
    String stickerEmoji = "🎒";

    if (spent >= consumed && spent > 0) {
      awardTitle = "🍯 The Kind Payer Award";
      awardDesc = "Like Pooh sharing his honey pot, you protected your companions by settling the treasury bills down first!";
      stickerEmoji = "🍯";
    } else if (consumed > spent && consumed > 50) {
      awardTitle = "🍖 Grand Duke of the Feast";
      awardDesc = "You enjoyed the kingdom's bounty to the absolute fullest! A magnificent royal banquet champion!";
      stickerEmoji = "🍖";
    } else if (spent == 0 && consumed == 0) {
      awardTitle = "🍃 Carefree Woodland Sprite";
      awardDesc = "You simply danced through the woods this round without leaving any trace in the ledger diaries!";
      stickerEmoji = "🍃";
    } else if (consumed < 15 && consumed > 0) {
      awardTitle = "🪙 The Wise Micro-Saver";
      awardDesc = "Incredibly cautious with your treasure stash! You managed to claim maximum happiness for the least coins!";
      stickerEmoji = "🪙";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDFBF7),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: const BorderSide(color: Color(0xFFE6D5C3), width: 3)),
          title: Row(
            children: [
              Text(stickerEmoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text("$name's Adventure Chapter", style: const TextStyle(fontFamily: "Caveat", fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF3EDE2), borderRadius: BorderRadius.circular(14)),
                child: Column(
                  children: [
                    Text("Spent: ${spent.toStringAsFixed(2)} coins 🪙", style: const TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Consumed: ${consumed.toStringAsFixed(2)} coins 🍽️", style: const TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(awardTitle, style: const TextStyle(fontFamily: "Caveat", fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple)),
              ),
              const SizedBox(height: 6),
              Text(
                "\"$awardDesc\"",
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: "Caveat", fontSize: 18, fontStyle: FontStyle.italic, color: Colors.black87),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close Log 📜", style: TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
            )
          ],
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
        title: Text(sceneState == SceneState.summaryView ? "📖 The Chronicles of Split" : "${widget.groupName} 🐰 Receipt"),
        leading: sceneState == SceneState.summaryView 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
              onPressed: () => setState(() => sceneState = SceneState.receiptOpened),
            )
          : null,
      ),
      body: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ==========================================
            // LAYER 1: THE CRUMPLED BALL ICON (Background Layer)
            // ==========================================
            if (showCircle && sceneState != SceneState.summaryView && !showReceipt)
              Positioned.fill(
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
            // LAYER 2: THE UNFOLDED RECEIPT SHEET (Middle Background Layer)
            // ==========================================
            if (showReceipt && sceneState != SceneState.summaryView)
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
                                  onTap: _executeSettlementMathematics,
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

            // ==========================================
            // LAYER 3: THE RABBIT WORKSPACE (Foreground Layer)
            // ==========================================
            if (showCircle && sceneState != SceneState.summaryView)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: isSelectiveModeActive ? false : !showReceipt,
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
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        if (showReceipt && isSelectiveModeActive) {
                                          _openRabbitCustomLedgerForm(currentRabbitName);
                                        } else if (!showReceipt) {
                                          toggleMember(currentRabbitName);
                                        }
                                      },
                                      child: const SizedBox.expand(
                                        child: ColoredBox(color: Colors.transparent),
                                      ),
                                    ),
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
                                              Icon(Icons.pets, color: Colors.white, size: 14)
                                            ],
                                          ),
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
              ),

            // ==========================================
            // LAYER 4: THE ROYAL SUMMARY VIEW STORYBOOK CANVAS
            // ==========================================
            if (sceneState == SceneState.summaryView)
              AnimatedBuilder(
                animation: _bookFlipAnimation,
                builder: (context, child) {
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY((1.0 - _bookFlipAnimation.value) * pi * 0.5),
                    child: Opacity(
                      opacity: _bookFlipAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: min(MediaQuery.of(context).size.width * 0.92, 850),
                  height: MediaQuery.of(context).size.height * 0.78,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBF7F0),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 30, offset: Offset(0, 15))],
                    border: Border.all(color: const Color(0xFFE2D4C1), width: 6),
                  ),
                  child: Row(
                    children: [
                      // 📖 LEFT PAGE DIARY SHEET: LEDGER CALCULATOR STACKS
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Color(0xFFEADCC9), width: 2)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("📖 Royal Treasury Ledger", style: TextStyle(fontFamily: "Caveat", fontSize: 28, fontWeight: FontWeight.bold, color: Colors.brown)),
                              const SizedBox(height: 4),
                              const Text("The final coins matching pathways:", style: TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.black54)),
                              const Divider(height: 20, color: Color(0xFFEADCC9)),
                              Expanded(
                                child: isEntirelySettled 
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Lottie.asset("assets/rabbits/Rabbit Kick Scooter.json", width: 120, height: 120),
                                          const Text("[✓] All settled up!", style: TextStyle(fontFamily: "Caveat", fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                                          const Text("The forest balance is at peace 🍃", style: TextStyle(fontFamily: "Caveat", fontSize: 18, color: Colors.black54)),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: computedDebts.length,
                                      itemBuilder: (context, index) {
                                        final debt = computedDebts[index];
                                        return Card(
                                          color: const Color(0xFFF5EDE0),
                                          elevation: 0,
                                          margin: const EdgeInsets.symmetric(vertical: 6),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          child: ListTile(
                                            leading: const Icon(Icons.swap_horiz, color: Colors.brown),
                                            title: Text(
                                              "🐰 ${debt['from']} needs to give ${debt['amount'].toStringAsFixed(2)} coins to ${debt['to']} 🪙",
                                              style: const TextStyle(fontFamily: "Caveat", fontSize: 18, fontWeight: FontWeight.bold),
                                            ),
                                            trailing: TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  computedDebts.removeAt(index);
                                                  if (computedDebts.isEmpty) isEntirelySettled = true;
                                                });
                                              },
                                              child: const Text("Settle 🐾", style: TextStyle(fontFamily: "Caveat", fontSize: 16, color: Colors.purple, fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // 📊 RIGHT PAGE DIARY SHEET: SAFE GRAPH COMPONENT VERTICALS
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("📊 Magical Kingdom Analytics", style: TextStyle(fontFamily: "Caveat", fontSize: 26, fontWeight: FontWeight.bold, color: Colors.brown)),
                              const SizedBox(height: 14),
                              
                              const Text("Who Spent The Most Coins? (Contribution Pillars)", style: TextStyle(fontFamily: "Caveat", fontSize: 16, color: Colors.black54)),
                              const SizedBox(height: 8),
                              
                              // ==========================================
                              // 📊 FIXED CONTRIBUTION PILLARS
                              // ✅ RESOLVED: Increased layout frame container box height to 140
                              // and scaled maximum potential element bar limits cleanly to 70 max.
                              // ==========================================
                              Container(
                                height: 140, // 👈 Increased from 120
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(color: const Color(0xFFF3EDE2), borderRadius: BorderRadius.circular(14)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: widget.members.map((m) {
                                    double spent = totalSpendingPerRabbit[m] ?? 0.0;
                                    double maxSpent = totalSpendingPerRabbit.values.fold(1.0, (maxV, v) => max(maxV, v));
                                    // Math scaling safely capped at 70 to guarantee elements never break boundaries
                                    double scaleHeight = spent == 0 ? 8 : (spent / maxSpent) * 70;
                                    
                                    return Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text("${spent.toStringAsFixed(0)}🪙", style: const TextStyle(fontFamily: "Caveat", fontSize: 12)),
                                        ),
                                        const SizedBox(height: 2),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 800),
                                          width: 24,
                                          height: scaleHeight,
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.6),
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Flexible(
                                          child: Text(m, style: const TextStyle(fontFamily: "Caveat", fontSize: 13, fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              const Divider(color: Color(0xFFEADCC9)),
                              const SizedBox(height: 6),
                              
                              const Text("📜 Whispering Woods Awards", style: TextStyle(fontFamily: "Caveat", fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
                              const Text("Tap any companion avatar block to view diary logs:", style: TextStyle(fontFamily: "Caveat", fontSize: 15, color: Colors.black45)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: widget.members.map((m) {
                                  return InkWell(
                                    onTap: () => _showRabbitStorybookAwardDialog(m),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEADCC9).withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFEADCC9)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.auto_stories_outlined, size: 16, color: Colors.brown),
                                          const SizedBox(width: 6),
                                          Text(m, style: const TextStyle(fontFamily: "Caveat", fontSize: 16, fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}