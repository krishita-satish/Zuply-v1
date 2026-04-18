import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';

/// Authentication state management via ChangeNotifier (Provider pattern).
///
/// Uses Supabase Auth for email/password login, signup, and session management.
class AuthService extends ChangeNotifier {
  ZuplyUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  ZuplyUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Supabase auth client shortcut.
  GoTrueClient get _auth => Supabase.instance.client.auth;

  /// Checks if there's an existing session and restores it.
  Future<void> tryAutoLogin() async {
    final session = _auth.currentSession;
    if (session != null) {
      _currentUser = _userFromSession(session);
      notifyListeners();
    }
  }

  /// Authenticates with email and password via Supabase Auth.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        _currentUser = _userFromSession(response.session!);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _error = 'Login failed. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registers a new account via Supabase Auth.
  ///
  /// Stores [name] and [role] in `user_metadata` so they persist
  /// alongside the auth record.
  Future<bool> signup(
    String email,
    String password,
    String name,
    String role,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'role': role},
      );

      if (response.session != null) {
        _currentUser = _userFromSession(response.session!);
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // Supabase may require email confirmation
      _error = 'Please check your email to confirm your account.';
      _isLoading = false;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error. Please check your network.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs out and clears the session.
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Clears any displayed error message.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Maps a Supabase session to our [ZuplyUser] model.
  ZuplyUser _userFromSession(Session session) {
    final user = session.user;
    final meta = user.userMetadata ?? {};
    return ZuplyUser(
      id: null,
      email: user.email ?? '',
      name: meta['name'] ?? user.email?.split('@').first ?? '',
      role: meta['role'] ?? 'donor',
      token: session.accessToken,
    );
  }
}
