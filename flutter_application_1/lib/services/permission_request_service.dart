import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// Service for handling permission requests between users
class PermissionRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Find a user by their email address
  /// Returns the user document if found, null otherwise
  Future<DocumentSnapshot?> findUserByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No user found with email: $email');
        return null;
      }

      return querySnapshot.docs.first;
    } catch (e) {
      debugPrint('Error finding user by email: $e');
      return null;
    }
  }

  /// Create a permission request in the recipient's Firestore
  /// targetUserId: The user who will receive the request
  /// requesterName: Name of the user making the request
  /// requesterEmail: Email of the user making the request
  Future<bool> createPermissionRequest({
    required String targetUserId,
    required String requesterId,
    required String requesterName,
    required String requesterEmail,
    String? targetProfileId, // null for main profile, or dependent ID
  }) async {
    try {
      // Build reference to the target user or dependent
      DocumentReference baseRef;
      if (targetProfileId == null) {
        // Main user
        baseRef = _firestore.collection('users').doc(targetUserId);
      } else {
        // Dependent profile
        baseRef = _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('dependents')
            .doc(targetProfileId);
      }

      // Default permissions structure (all denied initially)
      Map<String, Map<String, bool>> defaultPermissions = {
        'vital_signs': {'can_read': false, 'can_write': false},
        'medications': {'can_read': false, 'can_write': false},
        'medical_tests': {'can_read': false, 'can_write': false},
        'chronic_diseases': {'can_read': false, 'can_write': false},
        'allergies': {'can_read': false, 'can_write': false},
        'appointments': {'can_read': false, 'can_write': false},
        'surgeries': {'can_read': false, 'can_write': false},
        'hospital_stays': {'can_read': false, 'can_write': false},
        'vaccines': {'can_read': false, 'can_write': false},
        'family_history': {'can_read': false, 'can_write': false},
      };

      // Create the permission request
      await baseRef.collection('permissions').add({
        'requester_id': requesterId,
        'requester_name': requesterName,
        'requester_email': requesterEmail,
        'is_access_granted': false,
        'permissions': defaultPermissions,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      debugPrint('Permission request created successfully');
      return true;
    } catch (e) {
      debugPrint('Error creating permission request: $e');
      return false;
    }
  }

  /// Get current user's information
  Future<Map<String, String>?> getCurrentUserInfo() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) return null;

      final data = userDoc.data();
      return {
        'id': user.uid,
        'name': data?['name'] ?? 'مستخدم',
        'email': user.email ?? data?['email'] ?? '',
      };
    } catch (e) {
      debugPrint('Error getting current user info: $e');
      return null;
    }
  }

  /// Check if a permission request already exists
  Future<bool> requestExists({
    required String targetUserId,
    required String requesterId,
    String? targetProfileId,
  }) async {
    try {
      DocumentReference baseRef;
      if (targetProfileId == null) {
        baseRef = _firestore.collection('users').doc(targetUserId);
      } else {
        baseRef = _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('dependents')
            .doc(targetProfileId);
      }

      final querySnapshot = await baseRef
          .collection('permissions')
          .where('requester_id', isEqualTo: requesterId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking if request exists: $e');
      return false;
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }
}
