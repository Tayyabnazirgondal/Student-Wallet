import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileProvider extends ChangeNotifier {
  String _name = '';
  String _dob = '';
  String _imagePath = ''; // saved photo file path

  String get name => _name;
  String get dob => _dob;
  String get imagePath => _imagePath;

  ProfileProvider() {
    _loadProfile();
  }

  // Load saved profile when app starts
  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('profile_name') ?? '';
    _dob = prefs.getString('profile_dob') ?? '';
    _imagePath = prefs.getString('profile_image') ?? '';
    notifyListeners();
  }

  // Save profile details
  Future<void> saveProfile({
    required String name,
    required String dob,
    String? imagePath,
  }) async {
    _name = name;
    _dob = dob;
    if (imagePath != null) _imagePath = imagePath;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', name);
    await prefs.setString('profile_dob', dob);
    if (imagePath != null) {
      await prefs.setString('profile_image', imagePath);
    }
  }
}