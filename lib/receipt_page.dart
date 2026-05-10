import 'package:flutter/material.dart';

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
    with SingleTickerProviderStateMixin {
  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  String? selectedPayer;

  List<String> selectedMembers = [];

  late AnimationController _controller;

  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    animation = CurvedAnimation(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F8),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          "${widget.groupName} Receipt 🧾",
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      ),

      body: Center(
        child: ScaleTransition(
          scale: animation,

          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),

            decoration: BoxDecoration(
              color: Colors.white,
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  const Center(
                    child: Text(
                      "Expense Receipt ✨",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // 📝 DESCRIPTION
                  const Text(
                    "Expense Description",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: descriptionController,

                    decoration: InputDecoration(
                      hintText:
                          "Example: Korean BBQ Dinner 🍖",

                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 💰 AMOUNT
                  const Text(
                    "Amount",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: amountController,
                    keyboardType:
                        TextInputType.number,

                    decoration: InputDecoration(
                      hintText: "0.00",

                      filled: true,
                      fillColor: const Color(0xFFF4F4F4),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 👤 WHO PAID
                  const Text(
                    "Who Paid?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
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
                      fillColor: const Color(0xFFF4F4F4),

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(18),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 👥 SPLIT AMONG
                  const Text(
                    "Split Among",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Column(
                    children:
                        widget.members.map((member) {
                      return CheckboxListTile(
                        value:
                            selectedMembers.contains(
                                member),

                        title: Text(member),

                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selectedMembers
                                  .add(member);
                            } else {
                              selectedMembers
                                  .remove(member);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // 📸 RECEIPT IMAGE
                  Container(
                    height: 140,
                    width: double.infinity,

                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),

                      borderRadius:
                          BorderRadius.circular(24),

                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    child: const Center(
                      child: Text(
                        "📸 Upload Receipt Image",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // 🚀 SAVE BUTTON
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,

                        padding:
                            const EdgeInsets.symmetric(
                          vertical: 20,
                        ),

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                                  22),
                        ),
                      ),

                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Expense Saved ✨",
                            ),
                          ),
                        );
                      },

                      child: const Text(
                        "Save Expense",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
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
    );
  }
}