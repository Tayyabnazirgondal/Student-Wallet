import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../budget_provider.dart';
import '../currency_provider.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Expense>('expenses');
    final budget = context.watch<BudgetProvider>().monthlyBudget;
    final symbol = context.watch<CurrencyProvider>().symbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Set budget',
            onPressed: () => _showSetBudgetDialog(context, budget),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Expense> box, _) {
          final now = DateTime.now();
          double spent = 0;
          for (final e in box.values) {
            if (!e.isIncome &&
                e.date.month == now.month &&
                e.date.year == now.year) {
              spent += e.amount;
            }
          }

          if (budget <= 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 70, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No monthly budget set',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Set Budget'),
                    onPressed: () => _showSetBudgetDialog(context, budget),
                  ),
                ],
              ),
            );
          }

          final remaining = budget - spent;
          final percent = (spent / budget).clamp(0.0, 1.0);
          final overBudget = spent > budget;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: overBudget ? Colors.red : Colors.teal,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('Monthly Budget',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 6),
                    Text(
                      '$symbol ${budget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: percent,
                  minHeight: 16,
                  backgroundColor: Colors.grey.shade300,
                  color: overBudget ? Colors.red : Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${(percent * 100).toStringAsFixed(0)}% used',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoBox(label: 'Spent', value: spent, color: Colors.red, symbol: symbol),
                  _InfoBox(
                    label: 'Remaining',
                    value: remaining,
                    color: overBudget ? Colors.red : Colors.green,
                    symbol: symbol,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (overBudget)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'You have exceeded your monthly budget!',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showSetBudgetDialog(BuildContext context, double current) {
    final controller = TextEditingController(
      text: current > 0 ? current.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Monthly Budget'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Budget amount',
            hintText: 'e.g. 10000',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              if (value != null && value > 0) {
                context.read<BudgetProvider>().setBudget(value);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String symbol;

  const _InfoBox({
    required this.label,
    required this.value,
    required this.color,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          '$symbol ${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}