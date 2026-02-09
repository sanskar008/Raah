import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/enums/user_role.dart';

/// Auth ViewModel — manages login/signup state, user session, role.
/// Uses ChangeNotifier pattern (works with Provider for MVVM).
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  // ── State ──
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // ── Getters ──
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isInitialized => _isInitialized;
  UserRole? get userRole => _user?.role;

  // ── Initialize — check for persisted login ──
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _authRepository.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authRepository.getCurrentUser();
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  // ── Login ──
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Signup ──
  Future<bool> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.signup(
        name: name,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Update Profile ──
  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      await Future.delayed(const Duration(milliseconds: 600));

      _user = _user!.copyWith(
        name: name,
        email: email,
        phone: phone,
      );

      // Persist updated user locally
      await _authRepository.persistUser(_user!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Logout ──
  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    _error = null;
    notifyListeners();
  }

  // ── Clear error ──
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
