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

class _GroupCreationPageState extends State<GroupCreationPage> {
  final TextEditingController groupController = TextEditingController();

  final TextEditingController memberController = TextEditingController();

  List<RabbitModel> members = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F1F8),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        title: Text(
          "${widget.worldTitle} Group 🐰",
          style: const TextStyle(color: Colors.black),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "${widget.selectedDay} May Timeline ✨",
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // 📖 GROUP NAME
            const Text(
              "Group / Trip Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: groupController,

              decoration: InputDecoration(
                hintText: "Example: Korea Food Trip 🍜",

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),

                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // 👥 MEMBER SECTION
            const Text(
              "Add Rabbit Friends 👥",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: memberController,

                    decoration: InputDecoration(
                      hintText: "Enter friend name",

                      filled: true,
                      fillColor: Colors.white,

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
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,

                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 18,
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

                  child: const Text("Add"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // 🐰 MEMBER LIST
            Expanded(
              child: ListView.builder(
                itemCount: members.length,

                itemBuilder: (context, index) {
                  return RabbitCard(
                    rabbitName: members[index].name,

                    rabbitAsset: members[index].rabbitAsset,
                  );
                },
              ),
            ),

            // 🚀 START STORY BUTTON
            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(vertical: 20),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),

                onPressed: () {
                  // 🔜 receipt system next phase
                  if (groupController.text.isEmpty || members.isEmpty) {
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptPage(
                        groupName: groupController.text,

                        // 🐰 convert RabbitModel list into String list
                        members: members.map((rabbit) => rabbit.name).toList(),
                      ),
                    ),
                  );
                },

                child: const Text(
                  "Start Expense Story ✨",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
