import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:legate_my_car/config/app_flavor.dart';
import 'package:legate_my_car/models/user_model.dart';
import '../utils/connection_helper.dart';
import 'dio_service.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'auth_user';

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
        final responseData = response.data as Map<String, dynamic>;
        final token = responseData['data']['token'] as String?;
        final user = UserModel.fromJson(
          responseData['data']['user'] as Map<String, dynamic>,
        );
        if (token != null && token.isNotEmpty && user.id != 0) {
          // Store token
          await _setToken(token);
          // Store user info from Google account
          final userJson = jsonEncode(user.toJson());
          await _storage.write(key: _userKey, value: userJson as String?);
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

  /// Check if thier token is stored
  static Future<bool> hasValidTokenStored() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return false;
    }

    return true;
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

  /// Delete account remotely (if authenticated) and clear local session.
  ///
  /// Returns `true` when deletion succeeds or when no authenticated account
  /// exists (for example, guest users). Returns `false` when the deletion
  /// request fails.
  static Future<bool> deleteAccount() async {
    try {
      final user = await getCurrentUser();
      final token = await getToken();

      // Guests or anonymous sessions can be cleared locally.
      if (user == null || token == null || token.isEmpty || user.isGuest) {
        await logout();
        return true;
      }

      final hasInternet = await ConnectionHelper.hasInternet();
      if (!hasInternet) {
        throw Exception('NO_INTERNET_CONNECTION');
      }

      final dio = DioService.instance;
      final response = await dio.delete('/auth/account');

      final isSuccessStatus =
          response.statusCode == 200 || response.statusCode == 204;
      final data = response.data;
      final isSuccessResponse =
          data is Map<String, dynamic> && data['success'] == true;

      if (isSuccessStatus || isSuccessResponse) {
        await logout();
        return true;
      }

      return false;
    } catch (e) {
      return false;
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
      final endpoint = "/login";
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
          final token = responseData['data']['token'] as String?;
          final user = UserModel.fromJson(
            responseData['data']['user'] as Map<String, dynamic>,
          );
          if (token != null && token.isNotEmpty && user.id != 0) {
            // Store token
            await _setToken(token);

            // Store user info from Google account
            final userJson = jsonEncode(user.toJson());
            await _storage.write(key: _userKey, value: userJson as String?);

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
