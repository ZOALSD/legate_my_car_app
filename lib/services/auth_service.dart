import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env_config.dart';
import '../utils/connection_helper.dart';
import '../models/login_model.dart';
import 'dio_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

  /// Validate existing token with the server
  static Future<bool> validateToken() async {
    try {
      final token = await getToken();

      if (token == null || token.isEmpty) {
        return false;
      }

      final hasInternet = await ConnectionHelper.hasInternet();
      if (!hasInternet) {
        return false;
      }

      final endpoint = '${EnvConfig.apiBaseUrl}/guest/info';
      final dio = DioService.instance;
      final response = await dio.get(endpoint);

      if (response.statusCode == 200) {
        final userInfoResponse = UserInfoResponseModel.fromJson(
          response.data as Map<String, dynamic>,
        );

        if (userInfoResponse.success) {
          final userJson = userInfoResponse.user.toJsonString();
          await _storage.write(key: _userKey, value: userJson);
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Login as guest user and store token
  static Future<bool> loginAsGuest() async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();
      if (!hasInternet) {
        return false;
      }

      final endpoint = '${EnvConfig.apiBaseUrl}/guest/login';

      final dio = DioService.instance;
      final response = await dio.post(endpoint);

      if (response.statusCode == 200) {
        // Parse response using the model
        final loginResponse = LoginResponseModel.fromJson(response.data);

        if (loginResponse.success && loginResponse.data.token.isNotEmpty) {
          // Store token
          await _setToken(loginResponse.data.token);
          return true;
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<void> _setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Get stored authentication token
  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Check if user is authenticated (with optional validation)
  static Future<bool> isAuthenticated({bool validate = false}) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    // If validation is requested, check with server
    if (validate) {
      return await validateToken();
    }

    return true;
  }

  /// Logout user (clear token and user info)
  static Future<void> logout() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _userKey);
      print('✅ Logged out successfully');
    } catch (e) {
      print('❌ Error during logout: $e');
    }
  }

  /// Get current user information
  static Future<UserModel?> getCurrentUser() async {
    try {
      final userJson = await _storage.read(key: _userKey);
      if (userJson != null && userJson.isNotEmpty) {
        // Parse the JSON string back to Map
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
    } catch (e) {
      print('❌ Error reading user info: $e');
    }
    return null;
  }

  /// Get headers with authentication
  static Future<Map<String, String>> getAuthHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
