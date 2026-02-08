import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/enums/user_role.dart';
import '../models/user_model.dart';

/// Auth repository — handles login, signup, token persistence, logout.
/// Currently uses dummy data; swap with real API calls when backend is ready.
class AuthRepository {
  // ignore: unused_field — will be used when real API is connected
  final ApiService _apiService; // ignore: unused_field
  final SecureStorageService _storage;

  AuthRepository({
    required ApiService apiService,
    required SecureStorageService storage,
  })  : _apiService = apiService,
        _storage = storage;

  // ── Login ──
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with actual API call
    // final response = await _apiService.post(
    //   ApiEndpoints.login,
    //   body: {'email': email, 'password': password},
    //   auth: false,
    // );

    // Dummy response for development
    await Future.delayed(const Duration(seconds: 1));

    // Simulated: determine role from email for demo purposes
    UserRole role = UserRole.customer;
    if (email.contains('broker')) role = UserRole.broker;
    if (email.contains('owner')) role = UserRole.owner;

    final user = UserModel(
      id: '1',
      name: 'Demo User',
      email: email,
      phone: '9876543210',
      role: role,
      createdAt: DateTime.now(),
    );

    // Persist auth data
    await _storage.write(AppConstants.tokenKey, 'dummy_jwt_token');
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    await _storage.write(AppConstants.roleKey, user.role.value);

    return user;
  }

  // ── Signup ──
  Future<UserModel> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    // TODO: Replace with actual API call
    // final response = await _apiService.post(
    //   ApiEndpoints.signup,
    //   body: {
    //     'name': name,
    //     'email': email,
    //     'phone': phone,
    //     'password': password,
    //     'role': role.value,
    //   },
    //   auth: false,
    // );

    await Future.delayed(const Duration(seconds: 1));

    final user = UserModel(
      id: '1',
      name: name,
      email: email,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
    );

    await _storage.write(AppConstants.tokenKey, 'dummy_jwt_token');
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    await _storage.write(AppConstants.roleKey, user.role.value);

    return user;
  }

  // ── Check if user is logged in ──
  Future<UserModel?> getCurrentUser() async {
    final userData = await _storage.read(AppConstants.userKey);
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // ── Check if token exists ──
  Future<bool> isLoggedIn() async {
    return await _storage.containsKey(AppConstants.tokenKey);
  }

  // ── Logout ──
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
