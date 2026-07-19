import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyProvider extends ChangeNotifier {
  String _symbol = '\$'; // default: US Dollar

  String get symbol => _symbol;

  // List of currencies to choose from
  static const Map<String, String> currencies = {
    '\$': 'US Dollar (\$)',
    '€': 'Euro (€)',
    '£': 'British Pound (£)',
    '₹': 'Indian Rupee (₹)',
    'Rs': 'Pakistani Rupee (Rs)',
    '₺': 'Turkish Lira (₺)',
    '¥': 'Yen / Yuan (¥)',
    '﷼': 'Riyal (﷼)',
  };

  CurrencyProvider() {
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    _symbol = prefs.getString('currency_symbol') ?? '\$';
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    _symbol = symbol;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency_symbol', symbol);
  }
}