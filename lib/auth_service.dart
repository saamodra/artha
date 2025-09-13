import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isAuthenticated = false;
  String? _currentUser;

  // Hardcoded credentials
  static const String _hardcodedUsername = 'admin';
  static const String _hardcodedPassword = 'password123';

  bool get isAuthenticated => _isAuthenticated;
  String? get currentUser => _currentUser;

  Future<bool> login(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    if (username == _hardcodedUsername && password == _hardcodedPassword) {
      _isAuthenticated = true;
      _currentUser = username;
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }

  // Get user profile data
  Map<String, String> getUserProfile() {
    return {
      'username': _currentUser ?? '',
      'email': 'admin@artha.com',
      'fullName': 'Administrator',
      'joinDate': 'January 2024',
    };
  }
}
