import 'package:shared_preferences/shared_preferences.dart';

/// Utility class for managing local storage operations
class StorageUtils {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  static const String _keyComId = 'com_id';
  static const String _keyToken = 'auth_token';

  /// Save login state
  static Future<void> saveLoginState({
    required bool isLoggedIn,
    String? username,
    int? comId,
    String? token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
    if (username != null) {
      await prefs.setString(_keyUsername, username);
    }
    if (comId != null) {
      await prefs.setInt(_keyComId, comId);
    }
    if (token != null) {
      await prefs.setString(_keyToken, token);
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get saved username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  /// Get saved company ID
  static Future<int?> getComId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyComId);
  }

  /// Get saved auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  /// Clear all stored data (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
