import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'features/world/world_home.dart';
import 'package:lottie/lottie.dart';

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Accommodation',
  'Others',
];

class Group {
  String name;
  List<String> members;
  List<Expense> expenses;

  Group(this.name, this.members, this.expenses);

  Map<String, dynamic> toJson() => {
    'name': name,
    'members': members,
    'expenses': expenses.map((e) => e.toJson()).toList(),
  };

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    json['name'] as String,
    List<String>.from(json['members'] as List<dynamic>),
    (json['expenses'] as List<dynamic>)
        .map((e) => Expense.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class Expense {
  String description;
  double amount;
  String paidBy;
  List<String> splitAmong;
  String category;
  DateTime date;
  String? imageBase64;

  Expense(
    this.description,
    this.amount,
    this.paidBy,
    this.splitAmong,
    this.category,
    this.date, [
    this.imageBase64,
  ]);

  Map<String, dynamic> toJson() => {
    'description': description,
    'amount': amount,
    'paidBy': paidBy,
    'splitAmong': splitAmong,
    'category': category,
    'date': date.toIso8601String(),
    'imageBase64': imageBase64,
  };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
    json['description'] as String,
    (json['amount'] as num).toDouble(),
    json['paidBy'] as String,
    List<String>.from(json['splitAmong'] as List<dynamic>),
    json['category'] as String? ?? 'Other',
    DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
    json['imageBase64'] as String?,
  );

  String get formattedDate {
    final local = date.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _groupsKey = 'saved_groups';

  List<Group> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_groupsKey);
    if (saved != null) {
      final decoded = jsonDecode(saved) as List<dynamic>;
      setState(() {
        groups = decoded
            .map((e) => Group.fromJson(e as Map<String, dynamic>))
            .toList();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveGroups() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(groups.map((g) => g.toJson()).toList());
    await prefs.setString(_groupsKey, encoded);
  }

  void addGroup(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      groups.add(Group(trimmed, [], []));
    });
    _saveGroups();
  }

  void deleteGroup(int index) {
    setState(() {
      groups.removeAt(index);
    });
    _saveGroups();
  }

  void updateGroup(int index, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      groups[index].name = trimmed;
    });
    _saveGroups();
  }

  void showEditGroupDialog(BuildContext dialogContext, int index) {
    final controller = TextEditingController(text: groups[index].name);
    showDialog(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canSave = controller.text.trim().isNotEmpty;
            return AlertDialog(
              title: const Text('Edit Group'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter group name'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (canSave) {
                    updateGroup(index, controller.text);
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canSave
                      ? () {
                          updateGroup(index, controller.text);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void showAddGroupDialog(BuildContext dialogContext) {
    final controller = TextEditingController();
    showDialog(
      context: dialogContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canAdd = controller.text.trim().isNotEmpty;
            return AlertDialog(
              title: const Text('Create Group'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Enter group name'),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (canAdd) {
                    addGroup(controller.text);
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canAdd
                      ? () {
                          addGroup(controller.text);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('en', 'US')],
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Expense Splitter 💰'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.pets),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorldHome(),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '💰 Expense Splitter',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => showAddGroupDialog(context),
                        child: const Text('➕ Create Group'),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Your Groups',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : groups.isEmpty
                            ? const Center(
                                child: Text(
                                  'No groups yet. Tap Create Group to add one.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ListView.builder(
                                itemCount: groups.length,
                                itemBuilder: (context, index) {
                                  final group = groups[index];
                                  return Dismissible(
                                    key: Key('group-$index'),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(
                                        right: 16.0,
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) => deleteGroup(index),
                                    child: ListTile(
                                      title: Text(group.name),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GroupDetailPage(
                                                  group: group,
                                                  onRename: (newName) =>
                                                      updateGroup(
                                                        index,
                                                        newName,
                                                      ),
                                                  onUpdate: _saveGroups,
                                                ),
                                          ),
                                        );
                                      },
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () =>
                                                showEditGroupDialog(
                                                  context,
                                                  index,
                                                ),
                                            tooltip: 'Edit group',
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => deleteGroup(index),
                                            tooltip: 'Delete group',
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: 20,
                  right: 20,
                  child: SizedBox(
                    width: 120,
                    child: Lottie.asset("assets/rabbits/bunny_hop.json"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class GroupDetailPage extends StatefulWidget {
  final Group group;
  final ValueChanged<String> onRename;
  final VoidCallback onUpdate;

  const GroupDetailPage({
    super.key,
    required this.group,
    required this.onRename,
    required this.onUpdate,
  });

  @override
  State<GroupDetailPage> createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  String expenseSearchQuery = '';
  String selectedExpenseCategory = 'All';
  String selectedDateFilter = 'All';

  List<String> get _expenseCategoryFilters => ['All', ...expenseCategories];
  List<String> get _dateFilters => [
    'All',
    'Last 7 days',
    'Last 30 days',
    'This year',
  ];

  void _addMember(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      widget.group.members.add(trimmed);
    });
    widget.onUpdate();
  }

  void _removeMember(int index) {
    setState(() {
      widget.group.members.removeAt(index);
    });
    widget.onUpdate();
  }

  void _addExpense(
    String description,
    double amount,
    String paidBy,
    List<String> splitAmong,
    String category,
    DateTime date, [
    String? imageBase64,
  ]) {
    if (description.trim().isEmpty || amount <= 0 || splitAmong.isEmpty) {
      return;
    }
    setState(() {
      widget.group.expenses.add(
        Expense(
          description.trim(),
          amount,
          paidBy,
          splitAmong,
          category,
          date,
          imageBase64,
        ),
      );
    });
    widget.onUpdate();
  }

  void _removeExpense(int index) {
    setState(() {
      widget.group.expenses.removeAt(index);
    });
    widget.onUpdate();
  }

  Map<String, double> _categoryTotals() {
    final totals = <String, double>{};
    for (final expense in widget.group.expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0) + expense.amount;
    }
    return totals;
  }

  List<Expense> _filteredExpenses() {
    final now = DateTime.now();
    return widget.group.expenses.where((expense) {
      final matchesSearch =
          expense.description.toLowerCase().contains(
            expenseSearchQuery.toLowerCase(),
          ) ||
          expense.paidBy.toLowerCase().contains(
            expenseSearchQuery.toLowerCase(),
          );
      final matchesCategory =
          selectedExpenseCategory == 'All' ||
          expense.category == selectedExpenseCategory;
      final daysAgo = now.difference(expense.date).inDays;
      final matchesDate = switch (selectedDateFilter) {
        'Last 7 days' => daysAgo <= 7,
        'Last 30 days' => daysAgo <= 30,
        'This year' => expense.date.year == now.year,
        _ => true,
      };
      return matchesSearch && matchesCategory && matchesDate;
    }).toList();
  }

  Map<String, double> _calculateBalances() {
    final balances = <String, double>{};
    for (final expense in widget.group.expenses) {
      balances[expense.paidBy] =
          (balances[expense.paidBy] ?? 0) + expense.amount;
      final splitAmount = expense.amount / expense.splitAmong.length;
      for (final member in expense.splitAmong) {
        balances[member] = (balances[member] ?? 0) - splitAmount;
      }
    }
    return balances;
  }

  List<Map<String, dynamic>> _calculateSettlements() {
    final balances = _calculateBalances();
    final settlements = <Map<String, dynamic>>[];
    final creditors = <Map<String, double>>[];
    final debtors = <Map<String, double>>[];

    for (final entry in balances.entries) {
      if (entry.value > 0.01) {
        creditors.add({entry.key: entry.value});
      } else if (entry.value < -0.01) {
        debtors.add({entry.key: -entry.value});
      }
    }

    creditors.sort((a, b) => b.values.first.compareTo(a.values.first));
    debtors.sort((a, b) => b.values.first.compareTo(a.values.first));

    var i = 0;
    var j = 0;
    while (i < creditors.length && j < debtors.length) {
      final creditor = creditors[i];
      final debtor = debtors[j];
      final creditorName = creditor.keys.first;
      final debtorName = debtor.keys.first;
      final creditorAmount = creditor.values.first;
      final debtorAmount = debtor.values.first;
      final settleAmount = creditorAmount < debtorAmount
          ? creditorAmount
          : debtorAmount;

      if (settleAmount > 0.01) {
        settlements.add({
          'from': debtorName,
          'to': creditorName,
          'amount': settleAmount,
        });
      }

      creditors[i] = {creditorName: creditorAmount - settleAmount};
      debtors[j] = {debtorName: debtorAmount - settleAmount};

      if (creditors[i].values.first < 0.01) i++;
      if (debtors[j].values.first < 0.01) j++;
    }

    return settlements;
  }

  void _showSettleUpDialog(BuildContext context) {
    final settlements = _calculateSettlements();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Settle Up 💰'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (settlements.isEmpty)
                  const Text('All balances are settled! 🎉')
                else ...[
                  const Text(
                    'Here is the minimum number of payments to settle all balances:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  ...settlements.map((settlement) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.swap_horiz,
                          color: Colors.green,
                        ),
                        title: Text(
                          '${settlement['from']} pays ${settlement['to']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '\$${(settlement['amount'] as double).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Text(
                    '💡 Tip: Mark these payments as settled in your preferred payment app.',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.purple;
      case 'Accommodation':
        return Colors.green;
      case 'Others':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Map<String, double> _memberSpending() {
    final spending = <String, double>{};
    for (final member in widget.group.members) {
      spending[member] = 0.0;
    }
    for (final expense in widget.group.expenses) {
      spending[expense.paidBy] =
          (spending[expense.paidBy] ?? 0) + expense.amount;
    }
    return spending;
  }

  void _showAnalyticsDialog(BuildContext context) {
    final categoryTotals = _categoryTotals();
    final memberSpending = _memberSpending();
    final hasData = categoryTotals.isNotEmpty || memberSpending.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Spending Analytics 📊',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (!hasData)
                      const Text('No expenses yet. Add some to see analytics!')
                    else ...[
                      const Text(
                        'Category Breakdown',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (categoryTotals.isNotEmpty)
                        SizedBox(
                          height: 220,
                          child: PieChart(
                            PieChartData(
                              sections: categoryTotals.entries.map((entry) {
                                final total = categoryTotals.values
                                    .fold<double>(
                                      0,
                                      (sum, value) => sum + value,
                                    );
                                final percentage = total > 0
                                    ? (entry.value / total) * 100
                                    : 0.0;
                                return PieChartSectionData(
                                  value: entry.value,
                                  title:
                                      '${entry.key}\n${percentage.toStringAsFixed(1)}%',
                                  color: _getCategoryColor(entry.key),
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                      const Text(
                        'Member Spending',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (memberSpending.isNotEmpty)
                        SizedBox(
                          height: 240,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: memberSpending.values.isNotEmpty
                                  ? (memberSpending.values.reduce(
                                              (a, b) => a > b ? a : b,
                                            ) *
                                            1.2)
                                        .clamp(10.0, double.infinity)
                                  : 100,
                              barTouchData: BarTouchData(enabled: true),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index >= 0 &&
                                          index < memberSpending.keys.length) {
                                        return Text(
                                          memberSpending.keys.elementAt(index),
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text('\$${value.toInt()}');
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              barGroups: memberSpending.entries.map((entry) {
                                final index = memberSpending.keys
                                    .toList()
                                    .indexOf(entry.key);
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: entry.value,
                                      width: 20,
                                      color: Colors.blue,
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      ...memberSpending.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    String? selectedPayer;
    String selectedCategory = expenseCategories.first;
    DateTime selectedDate = DateTime.now();
    final selectedSplitAmong = <String>[...widget.group.members];
    String? selectedImageBase64;

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        selectedImageBase64 = base64Encode(bytes);
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canAdd =
                descriptionController.text.trim().isNotEmpty &&
                amountController.text.trim().isNotEmpty &&
                selectedPayer != null &&
                double.tryParse(amountController.text) != null &&
                selectedSplitAmong.isNotEmpty;

            return AlertDialog(
              title: const Text('Add Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: descriptionController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Expense description',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(hintText: 'Amount'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPayer,
                      decoration: const InputDecoration(labelText: 'Who paid?'),
                      items: widget.group.members.map((member) {
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
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: expenseCategories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        'Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Receipt Photo (Optional)'),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            await pickImage();
                            setState(() {});
                          },
                          icon: const Icon(Icons.photo),
                          label: const Text('Pick Image'),
                        ),
                      ],
                    ),
                    if (selectedImageBase64 != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        height: 100,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Image.memory(
                          base64Decode(selectedImageBase64!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    const Text(
                      'Split Among',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    ...widget.group.members.map((member) {
                      return CheckboxListTile(
                        title: Text(member),
                        value: selectedSplitAmong.contains(member),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedSplitAmong.add(member);
                            } else {
                              selectedSplitAmong.remove(member);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canAdd
                      ? () {
                          final amount = double.parse(amountController.text);
                          _addExpense(
                            descriptionController.text,
                            amount,
                            selectedPayer!,
                            selectedSplitAmong,
                            selectedCategory,
                            selectedDate,
                            selectedImageBase64,
                          );
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.group.name);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canSave = controller.text.trim().isNotEmpty;
            return AlertDialog(
              title: const Text('Rename Group'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter new group name',
                ),
                onChanged: (_) => setState(() {}),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canSave
                      ? () {
                          widget.onRename(controller.text);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final canAdd = controller.text.trim().isNotEmpty;
            return AlertDialog(
              title: const Text('Add Member'),
              content: TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter member name',
                ),
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) {
                  if (canAdd) {
                    _addMember(controller.text);
                    Navigator.pop(context);
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: canAdd
                      ? () {
                          _addMember(controller.text);
                          Navigator.pop(context);
                        }
                      : null,
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final balances = _calculateBalances();
    final totalSpent = widget.group.expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    final expenseCount = widget.group.expenses.length;
    final averagePerPerson = widget.group.members.isEmpty
        ? 0.0
        : totalSpent / widget.group.members.length;
    final categoryTotals = _categoryTotals();
    final filteredExpenses = _filteredExpenses();

    return Scaffold(
      appBar: AppBar(title: const Text('Group Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.group.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _showRenameDialog(context),
                  child: const Text('Rename'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total spent',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '\$${totalSpent.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Expenses',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '$expenseCount',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Avg/person',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        Text(
                          '\$${averagePerPerson.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (categoryTotals.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryTotals.entries.map((entry) {
                  return Chip(
                    label: Text(
                      '${entry.key}: \$${entry.value.toStringAsFixed(2)}',
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    'Members',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showAddMemberDialog(context),
                    child: const Text('Add Member'),
                  ),
                  const SizedBox(height: 10),
                  if (widget.group.members.isEmpty)
                    const Text('No members yet. Add some!')
                  else
                    Card(
                      elevation: 1,
                      child: Column(
                        children: widget.group.members.asMap().entries.map((
                          entry,
                        ) {
                          final member = entry.value;
                          final balance = balances[member] ?? 0;
                          return ListTile(
                            title: Text(member),
                            subtitle: Text(
                              balance >= 0
                                  ? 'Owed: \$${balance.toStringAsFixed(2)}'
                                  : 'Owes: \$${(-balance).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: balance >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeMember(entry.key),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ElevatedButton(
                            onPressed: widget.group.members.isNotEmpty
                                ? () => _showSettleUpDialog(context)
                                : null,
                            child: const Text('Settle Up'),
                          ),
                          ElevatedButton(
                            onPressed: () => _showAnalyticsDialog(context),
                            child: const Text('Analytics'),
                          ),
                          ElevatedButton(
                            onPressed: widget.group.members.isNotEmpty
                                ? () => _showAddExpenseDialog(context)
                                : null,
                            child: const Text('Add Expense'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search expenses or payer',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() {
                        expenseSearchQuery = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedExpenseCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category filter',
                          ),
                          items: _expenseCategoryFilters.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedExpenseCategory = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedDateFilter,
                          decoration: const InputDecoration(
                            labelText: 'Date filter',
                          ),
                          items: _dateFilters.map((filter) {
                            return DropdownMenuItem(
                              value: filter,
                              child: Text(filter),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              selectedDateFilter = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...filteredExpenses.map((expense) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(expense.description),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Paid by: ${expense.paidBy}'),
                            Text('Category: ${expense.category}'),
                            Text(
                              'Split among: ${expense.splitAmong.join(', ')}',
                            ),
                            Text('Date: ${expense.formattedDate}'),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 70,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${expense.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  final index = widget.group.expenses.indexOf(
                                    expense,
                                  );
                                  if (index >= 0) {
                                    _removeExpense(index);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
