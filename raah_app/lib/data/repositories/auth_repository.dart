import 'dart:convert';
import '../../core/constants/app_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../domain/enums/user_role.dart';
import '../models/user_model.dart';

/// Auth repository — handles login, signup, token persistence, logout.
class AuthRepository {
  final ApiService _apiService;
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
    final response = await _apiService.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
      auth: false,
    );

    // Response format: { user: {...}, token: "..." }
    final userData = response['user'] ?? response;
    final token = response['token'] ?? '';

    final user = UserModel.fromJson(userData);

    // Persist auth data
    await _storage.write(AppConstants.tokenKey, token);
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
    final response = await _apiService.post(
      ApiEndpoints.signup,
      body: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role.value,
      },
      auth: false,
    );

    // Response format: { user: {...}, token: "..." }
    final userData = response['user'] ?? response;
    final token = response['token'] ?? '';

    final user = UserModel.fromJson(userData);

    await _storage.write(AppConstants.tokenKey, token);
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
    await _storage.write(AppConstants.roleKey, user.role.value);

    return user;
  }

  // ── Get current user from API ──
  Future<UserModel> getMe() async {
    final response = await _apiService.get(ApiEndpoints.getMe);
    
    // Response format: { user: {...} }
    final userData = response['user'] ?? response;
    final user = UserModel.fromJson(userData);
    
    // Update local storage
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

  // ── Persist updated user data locally ──
  Future<void> persistUser(UserModel user) async {
    await _storage.write(AppConstants.userKey, jsonEncode(user.toJson()));
  }

  // ── Logout ──
  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
