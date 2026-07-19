import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BudgetProvider extends ChangeNotifier {
  double _monthlyBudget = 0;

  double get monthlyBudget => _monthlyBudget;

  BudgetProvider() {
    _loadBudget();
  }

  // Load saved budget when app starts
  Future<void> _loadBudget() async {
    final prefs = await SharedPreferences.getInstance();
    _monthlyBudget = prefs.getDouble('monthly_budget') ?? 0;
    notifyListeners();
  }

  // Save the budget
  Future<void> setBudget(double amount) async {
    _monthlyBudget = amount;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('monthly_budget', amount);
  }
}