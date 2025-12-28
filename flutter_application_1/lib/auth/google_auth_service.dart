import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service to handle Google Sign-In authentication
/// 
/// This service provides methods to sign in with Google and manage
/// user data in Cloud Firestore. It handles errors and edge cases
/// such as user cancellation and network errors.
class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Sign in with Google
  /// 
  /// Returns a map with the following keys:
  /// - 'success': bool - whether the sign-in was successful
  /// - 'user': User? - the Firebase user object if successful
  /// - 'error': String? - error message in Arabic if failed
  /// - 'errorDetails': String? - technical error details for debugging
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // If user cancels the sign-in
      if (googleUser == null) {
        return {
          'success': false,
          'error': 'تم إلغاء تسجيل الدخول',
          'user': null,
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Save or update user data in Firestore
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return {
        'success': true,
        'user': userCredential.user,
        'error': null,
      };
    } on FirebaseAuthException catch (e) {
      print('GOOGLE SIGN-IN FIREBASE ERROR: ${e.code} - ${e.message}');
      
      String errorMessage = 'فشل تسجيل الدخول عبر Google';
      
      if (e.code == 'account-exists-with-different-credential') {
        errorMessage = 'يوجد حساب بنفس البريد الإلكتروني باستخدام طريقة تسجيل دخول مختلفة.';
      } else if (e.code == 'invalid-credential') {
        errorMessage = 'بيانات الاعتماد غير صالحة.';
      } else if (e.code == 'operation-not-allowed') {
        errorMessage = 'تسجيل الدخول عبر Google غير مفعل.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'تم تعطيل هذا الحساب.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'لم يتم العثور على المستخدم.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'يرجى التأكد من الاتصال بالإنترنت.';
      }

      return {
        'success': false,
        'error': errorMessage,
        'errorDetails': 'كود الخطأ: ${e.code}',
        'user': null,
      };
    } catch (e) {
      print('GOOGLE SIGN-IN GENERAL ERROR: $e');
      
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع أثناء تسجيل الدخول',
        'errorDetails': '$e',
        'user': null,
      };
    }
  }

  /// Save or update user data in Firestore
  Future<void> _saveUserToFirestore(User user) async {
    try {
      // Check if user document already exists
      final docSnapshot = await _firestore.collection('users').doc(user.uid).get();

      if (docSnapshot.exists) {
        // Update existing user data
        await _firestore.collection('users').doc(user.uid).update({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print('FIRESTORE: Updated existing user data');
      } else {
        // Create new user document
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'phone': user.phoneNumber ?? '', // Usually null for Google Sign-In
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print('FIRESTORE: Created new user document');
      }
    } catch (e) {
      print('FIRESTORE ERROR: Failed to save user data - $e');
      // Don't throw error here, as authentication was successful
      // Just log the error for debugging
    }
  }

  /// Sign out from Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('User signed out successfully');
    } catch (e) {
      print('SIGN OUT ERROR: $e');
    }
  }

  /// Check if user is currently signed in
  User? get currentUser => _auth.currentUser;

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await _googleSignIn.isSignedIn();
  }
}
