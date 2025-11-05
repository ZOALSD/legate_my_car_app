import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

      final endpoint = '/guest/info';
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

      final endpoint = '/guest/login';

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
      print('❌ Error during login: $e');
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
  static Future<bool> isAuthenticated() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    return await validateToken();
  }

  /// Logout user (clear token and user info)
  static Future<void> logout() async {
    try {
      // Sign out from Google Sign-In
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (_) {}

      // Clear stored tokens
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

  /// Sign in with Google
  static Future<bool> signInWithGoogle() async {
    try {
      // Check internet connection first
      final hasInternet = await ConnectionHelper.hasInternet();
      if (!hasInternet) {
        print('❌ No internet connection');
        return false;
      }

      // Initialize Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
      );

      // Sign out first to ensure clean state
      await googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        print('❌ User canceled Google Sign-In');
        return false;
      }

      // Get user email
      final email = googleUser.email;
      if (email.isEmpty) {
        print('❌ Failed to get email from Google account');
        await googleSignIn.signOut();
        return false;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final idToken = googleAuth.idToken;
      if (googleAuth.idToken == null) {
        print('❌ Failed to get Google ID token');
        await googleSignIn.signOut();
        return false;
      }

      // Send email and idToken to backend
      final endpoint = '/auth/login';
      final dio = DioService.instance;
      final response = await dio.post(
        endpoint,
        data: {'idToken': googleAuth.idToken},
      );

      if (response.statusCode == 200) {
        final responseData = response.data as Map<String, dynamic>;

        // Check if response is successful
        if (responseData['success'] == true) {
          // The data field contains the token as a string
          final token = responseData['data'] as String?;

          if (token != null && token.isNotEmpty) {
            // Store token
            await _setToken(token);

            // Store user info from Google account
            final userJson = jsonEncode({
              'id': 0, // Will be updated from backend if available
              'name': googleUser.displayName ?? '',
              'email': email,
              'is_guest': false,
            });
            await _storage.write(key: _userKey, value: userJson);

            print('✅ Google Sign-In successful');
            return true;
          }
        }
      }

      // If backend call fails, sign out from Google
      await googleSignIn.signOut();
      print('❌ Backend authentication failed');
      return false;
    } catch (e) {
      print('❌ Error during Google Sign-In: $e');
      // Ensure we sign out on error
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      } catch (_) {}
      return false;
    }
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
