import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../currency_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Expense>('expenses');
    final symbol = context.watch<CurrencyProvider>().symbol;

    // Filter transactions by title or category
    final all = box.values.toList().reversed.toList();
    final results = _query.isEmpty
        ? <Expense>[]
        : all.where((e) {
      final q = _query.toLowerCase();
      return e.title.toLowerCase().contains(q) ||
          e.category.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          // Search field
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by title or category',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                )
                    : null,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),

          // Results
          Expanded(
            child: _query.isEmpty
                ? const Center(
              child: Text(
                'Type to search your transactions',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : results.isEmpty
                ? const Center(
              child: Text(
                'No matching transactions',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final e = results[index];
                final isIncome = e.isIncome;
                final dateStr =
                DateFormat('dd MMM, hh:mm a').format(e.date);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isIncome
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                    child: Icon(
                      isIncome
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      color: isIncome ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(e.title),
                  subtitle: Text('${e.category}  •  $dateStr'),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}$symbol ${e.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}