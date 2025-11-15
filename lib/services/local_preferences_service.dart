import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

/// Centralized helper for values stored in [SharedPreferences].
class LocalPreferencesService {
  LocalPreferencesService._();

  static const String _userKey = 'auth_user';
  static const String _launcherKey = 'has_seen_launcher';

  static Future<SharedPreferences> _prefs() async {
    return SharedPreferences.getInstance();
  }

  /// Save the serialized [UserModel] locally.
  static Future<void> saveUser(UserModel user) async {
    final prefs = await _prefs();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  /// Retrieve the stored [UserModel], if any.
  static Future<UserModel?> getUser() async {
    final prefs = await _prefs();
    final userJson = prefs.getString(_userKey);
    if (userJson == null || userJson.isEmpty) {
      return null;
    }
    final map = jsonDecode(userJson) as Map<String, dynamic>;
    return UserModel.fromJson(map);
  }

  /// Remove any stored user data.
  static Future<void> clearUser() async {
    final prefs = await _prefs();
    await prefs.remove(_userKey);
  }

  /// Returns whether the launcher/onboarding has been completed.
  static Future<bool> hasSeenLauncher() async {
    final prefs = await _prefs();
    return prefs.getBool(_launcherKey) ?? false;
  }

  /// Persist launcher/onboarding completion state.
  static Future<void> setHasSeenLauncher(bool value) async {
    final prefs = await _prefs();
    await prefs.setBool(_launcherKey, value);
  }
}
