import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../currency_provider.dart';
import 'add_expense_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Expense>('expenses');
    final symbol = context.watch<CurrencyProvider>().symbol;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Expense> box, _) {
          final expenses = box.values.toList().reversed.toList();

          double income = 0;
          double expense = 0;
          for (final e in box.values) {
            if (e.isIncome) {
              income += e.amount;
            } else {
              expense += e.amount;
            }
          }
          final balance = income - expense;

          return Column(
            children: [
              _BalanceCard(
                balance: balance,
                income: income,
                expense: expense,
                symbol: symbol,
              ),
              Expanded(
                child: expenses.isEmpty
                    ? const Center(
                  child: Text(
                    'No transactions yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
                    : ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final e = expenses[index];
                    return _TransactionTile(expense: e, symbol: symbol);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance;
  final double income;
  final double expense;
  final String symbol;

  const _BalanceCard({
    required this.balance,
    required this.income,
    required this.expense,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.teal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            '$symbol ${balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(label: 'Income', value: income, color: Colors.greenAccent, symbol: symbol),
              _MiniStat(label: 'Expense', value: expense, color: Colors.redAccent, symbol: symbol),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String symbol;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          '$symbol ${value.toStringAsFixed(2)}',
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Expense expense;
  final String symbol;

  const _TransactionTile({required this.expense, required this.symbol});

  @override
  Widget build(BuildContext context) {
    final isIncome = expense.isIncome;
    final dateStr = DateFormat('dd MMM, hh:mm a').format(expense.date);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
        child: Icon(
          isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          color: isIncome ? Colors.green : Colors.red,
        ),
      ),
      title: Text(expense.title),
      subtitle: Text('${expense.category}  •  $dateStr'),
      trailing: Text(
        '${isIncome ? '+' : '-'}$symbol ${expense.amount.toStringAsFixed(2)}',
        style: TextStyle(
          color: isIncome ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Do you want to delete this transaction?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  expense.delete();
                  Navigator.pop(ctx);
                },
                child: const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}