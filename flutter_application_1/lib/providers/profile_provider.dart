import 'package:flutter/foundation.dart';

/// ProfileProvider manages the currently selected profile across the entire app.
/// 
/// - `null` selectedProfileId means the main user is selected
/// - Non-null selectedProfileId means a dependent profile is selected
class ProfileProvider with ChangeNotifier {
  String? _selectedProfileId; // null = main user, otherwise = dependent ID
  String _selectedProfileName = '';
  
  // New: Shared Profile Support
  bool _isSharedProfile = false;
  Map<String, dynamic> _permissions = {};

  /// The ID of the currently selected profile
  String? get selectedProfileId => _selectedProfileId;

  /// The name of the currently selected profile
  String get selectedProfileName => _selectedProfileName;

  /// Whether the main user is currently selected
  bool get isMainUser => _selectedProfileId == null;

  /// Whether a dependent (or shared profile) is selected
  bool get isDependent => _selectedProfileId != null;
  
  /// Whether the selected profile is a shared one (reverse linked)
  bool get isSharedProfile => _isSharedProfile;

  /// Select a specific profile (dependent or shared)
  void selectProfile(String? profileId, String profileName, 
      {bool isShared = false, Map<String, dynamic>? permissions}) {
    _selectedProfileId = profileId;
    _selectedProfileName = profileName;
    _isSharedProfile = isShared;
    _permissions = permissions ?? {};
    notifyListeners();
  }

  /// Select the main user profile
  void selectMainUser(String userName) {
    _selectedProfileId = null;
    _selectedProfileName = userName;
    _isSharedProfile = false;
    _permissions = {};
    notifyListeners();
  }

  /// Reset to main user (useful on app startup)
  void reset() {
    _selectedProfileId = null;
    _selectedProfileName = '';
    _isSharedProfile = false;
    _permissions = {};
    notifyListeners();
  }
  
  /// Check if current profile has permission for a category
  /// Usage: hasPermission('health_records', 'read')
  bool hasPermission(String category, String type) {
    // 1. Main user always has full access
    if (isMainUser) return true;
    
    // 2. Regular dependents (children) usually implied full access 
    //    (or you can default to true for non-shared)
    if (!_isSharedProfile) return true;

    // 3. Shared profiles must check the map
    // Structure in Firestore: permissions: { 'medications': { 'can_read': true, 'can_write': false } }
    // Map 'read' -> 'can_read' and 'write' -> 'can_write'
    final firestoreKey = 'can_$type'; // 'read' -> 'can_read', 'write' -> 'can_write'
    
    final categoryPerms = _permissions[category];
    if (categoryPerms is Map) {
      return categoryPerms[firestoreKey] == true;
    }
    
    return false; // Default to blocked if not found
  }

  /// Get the Firestore collection path for the selected profile
  String getFirestorePath(String userId, String subcollection) {
    if (_selectedProfileId == null) {
      // Main user path
      return 'users/$userId/$subcollection';
    } else if (_isSharedProfile) {
      // Shared Profile: Access target user's data DIRECTLY
      // The profileId here IS the target user's UID
      return 'users/$_selectedProfileId/$subcollection';
    } else {
      // Regular Dependent: Nested in requester's subcollection
      return 'users/$userId/dependents/$_selectedProfileId/$subcollection';
    }
  }
}
