import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service to manage authentication state persistence using SharedPreferences
class AuthService {
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';

  /// Save login state after successful authentication
  static Future<void> saveLoginState(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, userId);
    } catch (e) {
      debugPrint('Error saving login state: $e');
    }
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyIsLoggedIn) ?? false;
    } catch (e) {
      debugPrint('Error checking login state: $e');
      return false;
    }
  }

  /// Get saved user ID
  static Future<String?> getSavedUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyUserId);
    } catch (e) {
      debugPrint('Error getting saved user ID: $e');
      return null;
    }
  }

  /// Clear login state on logout
  static Future<void> clearLoginState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
    } catch (e) {
      debugPrint('Error clearing login state: $e');
    }
  }

  /// Check if current Firebase user matches saved user
  static Future<bool> isValidSession() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return false;

      final savedUserId = await getSavedUserId();
      return savedUserId == currentUser.uid;
    } catch (e) {
      debugPrint('Error validating session: $e');
      return false;
    }
  }
}
