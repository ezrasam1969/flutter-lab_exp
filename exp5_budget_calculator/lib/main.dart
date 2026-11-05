// pubspec.yaml -> dependencies:  provider: ^6.1.2
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BudgetModel(),
      child: const BudgetApp(),
    ),
  );
}

class Expense {
  final String title;
  final double amount;
  Expense(this.title, this.amount);
}

// App state: income, expenses and derived values
class BudgetModel extends ChangeNotifier {
  double _income = 0;
  final List<Expense> _expenses = [];

  double get income => _income;
  List<Expense> get expenses => List.unmodifiable(_expenses);
  double get totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get balance => _income - totalExpenses;
  double get spentRatio =>
      _income == 0 ? 0 : (totalExpenses / _income).clamp(0, 1).toDouble();

  String get status {
    if (_income == 0) return 'Enter your income';
    if (balance < 0) return 'Over Budget';
    if (balance < _income * 0.2) return 'Low Savings';
    return 'Healthy Budget';
  }

  void setIncome(double value) {
    _income = value;
    notifyListeners();
  }

  void addExpense(String title, double amount) {
    _expenses.add(Expense(title, amount));
    notifyListeners();
  }

  void removeExpense(int index) {
    _expenses.removeAt(index);
    notifyListeners();
  }
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Budget Calculator',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const BudgetPage(),
    );
  }
}

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  final _incomeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();

  void _showMessage(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  void _saveIncome() {
    final value = double.tryParse(_incomeCtrl.text);
    if (value == null || value <= 0) return _showMessage('Enter a valid income');
    context.read<BudgetModel>().setIncome(value);
    FocusScope.of(context).unfocus();
  }

  void _addExpense() {
    final amount = double.tryParse(_amountCtrl.text);
    if (_titleCtrl.text.trim().isEmpty || amount == null || amount <= 0) {
      return _showMessage('Enter expense name and a valid amount');
    }
    context.read<BudgetModel>().addExpense(_titleCtrl.text.trim(), amount);
    _titleCtrl.clear();
    _amountCtrl.clear();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Healthy Budget':
        return Colors.green;
      case 'Low Savings':
        return Colors.orange;
      case 'Over Budget':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final budget = context.watch<BudgetModel>(); // rebuilds on change
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Budget Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Income (₹)',
                    prefixIcon: Icon(Icons.account_balance_wallet),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _saveIncome, child: const Text('Set')),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _summary('Income', budget.income, Colors.blue),
                      _summary('Expenses', budget.totalExpenses, Colors.red),
                      _summary('Balance', budget.balance, Colors.green),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: budget.spentRatio,
                    minHeight: 8,
                    color: _statusColor(budget.status),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    avatar: Icon(Icons.insights,
                        color: _statusColor(budget.status)),
                    label: Text(budget.status,
                        style: TextStyle(
                            color: _statusColor(budget.status),
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Expense', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Amount', border: OutlineInputBorder()),
                ),
              ),
              IconButton.filled(
                  onPressed: _addExpense, icon: const Icon(Icons.add)),
            ],
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < budget.expenses.length; i++)
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text(budget.expenses[i].title),
              subtitle: Text('₹${budget.expenses[i].amount.toStringAsFixed(0)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => budget.removeExpense(i),
              ),
            ),
        ],
      ),
    );
  }

  Widget _summary(String label, double value, Color color) => Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text('₹${value.toStringAsFixed(0)}',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        ],
      );
}
