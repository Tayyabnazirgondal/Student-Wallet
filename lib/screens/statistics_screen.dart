import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  // Fixed colors for categories
  static const List<Color> _colors = [
    Colors.teal,
    Colors.orange,
    Colors.purple,
    Colors.blue,
    Colors.pink,
    Colors.brown,
  ];

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Expense>('expenses');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Expense> box, _) {
          // Sum expenses per category (income ignored)
          final Map<String, double> categoryTotals = {};
          double totalExpense = 0;

          for (final e in box.values) {
            if (!e.isIncome) {
              categoryTotals[e.category] =
                  (categoryTotals[e.category] ?? 0) + e.amount;
              totalExpense += e.amount;
            }
          }

          if (categoryTotals.isEmpty) {
            return const Center(
              child: Text(
                'No expenses to show yet.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final categories = categoryTotals.keys.toList();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Total Spent: ${totalExpense.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Pie chart
                SizedBox(
                  height: 240,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: List.generate(categories.length, (i) {
                        final cat = categories[i];
                        final value = categoryTotals[cat]!;
                        final percent = (value / totalExpense) * 100;
                        return PieChartSectionData(
                          color: _colors[i % _colors.length],
                          value: value,
                          title: '${percent.toStringAsFixed(0)}%',
                          radius: 70,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Legend / list below chart
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, i) {
                      final cat = categories[i];
                      final value = categoryTotals[cat]!;
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 10,
                          backgroundColor: _colors[i % _colors.length],
                        ),
                        title: Text(cat),
                        trailing: Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      );
                    },
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