import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  late final StreamSubscription<User?> _subscription;

  User? _user;
  bool _loading = false;
  String? _error;

  AuthProvider(this._service) {
    _user = _service.currentUser;
    _subscription = _service.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> signIn(String email, String password) async {
    _start();
    try {
      await _service.signIn(email: email, password: password);
      _error = null;
      return true;
    } catch (e) {
      _error = _service.messageForError(e);
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> signUp(String email, String password) async {
    _start();
    try {
      await _service.signUp(email: email, password: password);
      _error = null;
      return true;
    } catch (e) {
      _error = _service.messageForError(e);
      return false;
    } finally {
      _stop();
    }
  }

  Future<bool> signOut() async {
    _start();
    try {
      await _service.signOut();
      _error = null;
      return true;
    } catch (_) {
      _error = 'Unable to sign out. Please try again.';
      return false;
    } finally {
      _stop();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _start() {
    _loading = true;
    _error = null;
    notifyListeners();
  }

  void _stop() {
    _loading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
