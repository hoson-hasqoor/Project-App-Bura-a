import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/forgot_password_screen.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/auth/welcome_screen.dart';
import 'package:flutter_application_1/screens/setting/ContactUs_Screen.dart';
import 'package:flutter_application_1/auth/google_auth_service.dart';
import 'package:flutter_application_1/services/auth_service.dart';
import 'package:flutter_application_1/auth/login_child.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color buttonBlue = Color(0xFF3B82F6);

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //------------ Function ------------------//

  Future<void> loginUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('يرجى إدخال البريد الإلكتروني وكلمة المرور');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save login state
      await AuthService.saveLoginState(userCredential.user!.uid);

      if (!mounted) return;

      // Navigate to Home Screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Log error
      print("LOGIN ERROR: ${e.code} - ${e.message}");

      String message = 'فشل تسجيل الدخول';
      String details = 'كود الخطأ: ${e.code}';

      if (e.code == 'user-not-found') {
        message = 'المستخدم غير موجود.';
      } else if (e.code == 'wrong-password') {
        message = 'كلمة المرور خاطئة.';
      } else if (e.code == 'invalid-email') {
        message = 'البريد الإلكتروني غير صحيح.';
      } else if (e.code == 'user-disabled') {
        message = 'تم تعطيل هذا الحساب.';
      } else if (e.code == 'network-request-failed') {
        message = 'يرجى التأكد من الاتصال بالإنترنت.';
      } else if (e.code == 'invalid-credential') {
        message = 'بيانات الاعتماد غير صحيحة (خطأ في البريد أو كلمة المرور).';
      }
      _showErrorDialog(message, details: details);
    } catch (e) {
      print("GENERAL LOGIN ERROR: $e");
      _showErrorDialog('حدث خطأ غير متوقع', details: '$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Google Sign-In function
  Future<void> signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleAuthService googleAuthService = GoogleAuthService();
      final result = await googleAuthService.signInWithGoogle();

      if (!mounted) return;

      if (result['success'] == true) {
        // Save login state
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await AuthService.saveLoginState(user.uid);
        }

        // Navigate to Home Screen on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else {
        // Show error dialog
        _showErrorDialog(
          result['error'] ?? 'فشل تسجيل الدخول عبر Google',
          details: result['errorDetails'],
        );
      }
    } catch (e) {
      print('GOOGLE SIGN-IN ERROR: $e');
      if (!mounted) return;
      _showErrorDialog('حدث خطأ غير متوقع', details: '$e');
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message, {String? details}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('خطأ', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(message, textAlign: TextAlign.right),
            if (details != null) ...[
              const SizedBox(height: 10),
              Text(
                details,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  //------------ End of Function ------------------//

  @override
  Widget build(BuildContext context) {
    // 1. استخدام Scaffold بدون لون خلفية
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. طبقة الخلفية (ستغطي الشاشة بالكامل)
          Container(
            // لضمان أن الـ Container يأخذ كامل مساحة الشاشة المتاحة
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white, // اللون الأساسي للخلفية
              image: DecorationImage(
                image: AssetImage(
                  // **يرجى التأكد أن المسار والامتداد (background_logo.jpeg) صحيحان**
                  'assets/images/background_logo_1.jpeg',
                ),
                // تم التعديل هنا: BoxFit.contain لعرض الصورة بالكامل دون قص
                fit: BoxFit.contain,
                // تم تقليل الشفافية لجعلها باهتة جداً (علامة مائية حقيقية)
                opacity: 0.05,
              ),
            ),
          ),

          // 2. طبقة المحتوى (تكون فوق الخلفية)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. الشعار والترحيب
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png', // تأكد من وجود صورة الشعار هنا
                      height: 100,
                      width: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield_outlined,
                        size: 100,
                        color: primaryBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const Text(
                    'مرحباً بكم في برء',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 20),

                  // 2. عنوان تسجيل الدخول
                  const Text(
                    'تسجيل الدخول',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 30),

                  // 3. حقل البريد الإلكتروني / رقم الهاتف
                  _buildLabeledTextField(
                    label: 'البريد الإلكتروني / رقم الهاتف',
                    hintText: 'example@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  const SizedBox(height: 20),

                  // 4. حقل كلمة المرور
                  _buildLabeledPasswordTextField(
                    label: 'كلمة المرور',
                    controller: _passwordController,
                  ),
                  const SizedBox(height: 10),

                  // 5. زر هل نسيت كلمة المرور؟
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'هل نسيت كلمة المرور ؟',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 6. زر تسجيل الدخول
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'تسجيل الدخول',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 7. فاصل أو تسجيل الدخول عن طريق
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'أو تسجيل الدخول عن طريق',
                          style: TextStyle(color: Colors.grey),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey, thickness: 0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 8. زر الدخول عبر جوجل
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: _isGoogleLoading ? null : signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            color: Colors.grey,
                            width: 0.5,
                          ),
                        ),
                        elevation: 2,
                      ),
                      icon: _isGoogleLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryBlue,
                              ),
                            )
                          : Image.asset(
                              'assets/images/google-logo.jpg',
                              height: 24,
                              width: 24,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.public, color: primaryBlue),
                            ),
                      label: Text(
                        _isGoogleLoading ? 'جاري تسجيل الدخول...' : 'جوجل',
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // 9. جزئية الانتقال إلى شاشة إنشاء حساب
                  // 9. جزئية الانتقال إلى شاشة إنشاء حساب
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    textDirection: TextDirection.rtl,
                    children: <Widget>[
                      const Text(
                        'لا تمتلك حساب ؟',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                        textDirection: TextDirection.rtl,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),

                  // زر "اتصل بنا" تحت سطر إنشاء الحساب
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ContactUsScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'اتصل بنا',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                         TextButton(
                          onPressed: () {
                             // Import this at the top of the file: 
                             // import 'package:flutter_application_1/auth/login_child.dart';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TransferMedicalRecordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'نقل سجل صحي',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 1. دالة حقل الإدخال مع Label
  Widget _buildLabeledTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // النص الظاهر فوق الحقل (الـ Label)
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        // الحقل نفسه
        Container(
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: keyboardType,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              hintText: hintText, // مثال القيمة داخل الحقل
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 15.0,
                horizontal: 20.0,
              ),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: primaryBlue, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 2. دالة حقل كلمة المرور مع Label
  Widget _buildLabeledPasswordTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // النص الظاهر فوق الحقل (الـ Label)
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        // الحقل نفسه
        _PasswordTextFieldModern(
          lightGrey: lightGrey,
          primaryBlue: primaryBlue,
          hintText: '********',
          controller: controller,
        ),
      ],
    );
  }

  // 3. دالة إظهار الرسالة
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 🌟 ويدجت حقل كلمة المرور
class _PasswordTextFieldModern extends StatefulWidget {
  final Color lightGrey;
  final Color primaryBlue;
  final String hintText;
  final TextEditingController controller;

  const _PasswordTextFieldModern({
    required this.lightGrey,
    required this.primaryBlue,
    required this.hintText,
    required this.controller,
  });

  @override
  _PasswordTextFieldModernState createState() =>
      _PasswordTextFieldModernState();
}

class _PasswordTextFieldModernState extends State<_PasswordTextFieldModern> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // هنا لم نعد نحتاج للخلفية، فقط اللون الرمادي
      decoration: BoxDecoration(
        color: widget.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: widget.controller,
        textAlign: TextAlign.right,
        obscureText: _obscureText,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: widget.primaryBlue, width: 2),
          ),
          // الـ prefixIcon لأيقونة العين
          prefixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey[600],
            ),
            onPressed: _toggleVisibility,
          ),
        ),
      ),
    );
  }
}
