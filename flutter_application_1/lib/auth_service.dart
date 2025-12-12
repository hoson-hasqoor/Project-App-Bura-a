// auth/auth_service.dart

// ignore: depend_on_referenced_packages
import 'package:firebase_auth/firebase_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:cloud_firestore/cloud_firestore.dart';
// ❌ تم حذف السطر الخاطئ التالي:
// import 'package:flutter_application_1/auth_service.dart' as _auth;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. دالة تسجيل الدخول (سنحتاجها لاحقًا)
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      // يمكنك تعديل طريقة معالجة الأخطاء هنا
      print(e);
      return null;
    }
  }

  // 2. دالة إنشاء حساب وحفظ البيانات في قاعدة البيانات
  Future<User?> registerWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    String phone,
  ) async {
    try {
      // الخطوة أ: إنشاء المستخدم في Firebase Authentication
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;

      if (user != null) {
        // الخطوة ب: حفظ بيانات المستخدم الإضافية في Firestore
        await DatabaseService(
          uid: user.uid,
        ).savingUserData(fullName, email, phone);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  // 3. دالة تسجيل الخروج (سنحتاجها لاحقًا)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ✅ التعديل الرئيسي: نقل دالة استعادة كلمة المرور لداخل الفئة
  // 4. دالة إرسال رابط إعادة تعيين كلمة المرور
  Future<String?> sendPasswordResetEmail(String email) async {
    try {
      // استخدام _auth للوصول إلى مثيل FirebaseAuth
      await _auth.sendPasswordResetEmail(email: email);
      return 'Success'; // إشارة إلى نجاح الإرسال
    } on FirebaseAuthException catch (e) {
      // التعامل مع أخطاء Firebase المحددة
      if (e.code == 'user-not-found') {
        return 'لم يتم العثور على مستخدم مسجل بهذا البريد الإلكتروني.';
      } else if (e.code == 'invalid-email') {
        return 'صيغة البريد الإلكتروني غير صحيحة.';
      }
      return e.message; // رسالة الخطأ العامة
    } catch (e) {
      return 'حدث خطأ غير متوقع: ${e.toString()}';
    }
  }
}

// -----------------------------------------------------------

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // مرجع لمجموعة المستخدمين
  final CollectionReference userCollection = FirebaseFirestore.instance
      .collection("users");

  // حفظ بيانات المستخدم في Firestore
  Future savingUserData(String fullName, String email, String phone) async {
    if (uid == null) return;

    return await userCollection.doc(uid).set({
      "fullName": fullName,
      "email": email,
      "phone": phone,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }
}
