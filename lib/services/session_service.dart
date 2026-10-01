import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class SessionService {
  static const String _userKey = 'user_session';

  /// Save user session to persistent storage
  static Future<bool> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      return await prefs.setString(_userKey, userJson);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving user session: $e');
      }
      return false;
    }
  }

  /// Retrieve saved user session from persistent storage
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null && userJson.isNotEmpty) {
        final Map<String, dynamic> map = jsonDecode(userJson);
        return UserModel.fromJson(map);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error reading user session: $e');
      }
    }
    return null;
  }

  /// Clear saved user session (on Logout)
  static Future<bool> clearUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_userKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing user session: $e');
      }
      return false;
    }
  }

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }
}
