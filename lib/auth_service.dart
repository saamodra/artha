import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'config/supabase_config.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _init();
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = true;

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  void _init() {
    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;

      _currentUser = session?.user;
      _isLoading = false;
      notifyListeners();
    });

    // Get initial session
    _getInitialSession();
  }

  Future<void> _getInitialSession() async {
    try {
      final session = _supabase.auth.currentSession;
      _currentUser = session?.user;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting initial session: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      if (kDebugMode) {
        print('🔐 Attempting login for: $email');
        print('🌐 Supabase URL: ${SupabaseConfig.supabaseUrl}');
      }

      // Check network connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (kDebugMode) {
        print('📡 Network status: $connectivityResult');
      }

      if (connectivityResult == ConnectivityResult.none) {
        throw Exception(
          'No internet connection. Please check your network settings.',
        );
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (kDebugMode) {
        print('✅ Login successful');
      }
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Login error: $e');
        print('Error type: ${e.runtimeType}');
      }
      rethrow;
    }
  }

  Future<AuthResponse> signUp(String email, String password) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      if (kDebugMode) {
        print('Reset password error: $e');
      }
      rethrow;
    }
  }

  // Get user profile data
  Map<String, String> getUserProfile() {
    if (_currentUser == null) {
      return {'username': '', 'email': '', 'fullName': '', 'joinDate': ''};
    }

    return {
      'username':
          _currentUser!.userMetadata?['username'] ??
          _currentUser!.email?.split('@').first ??
          '',
      'email': _currentUser!.email ?? '',
      'fullName':
          _currentUser!.userMetadata?['full_name'] ??
          _currentUser!.email?.split('@').first ??
          '',
      'joinDate': 'Member since ${DateTime.now().year}',
    };
  }
}
