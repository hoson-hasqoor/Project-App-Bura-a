import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart'; // تأكد من أن هذا الملف موجود
import 'package:flutter_application_1/auth/google_auth_service.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(0xFF004AAD); // أزرق داكن
  static const Color lightBlue = Color(
    0xFF3B82F6,
  ); // أزرق للأزرار (قيمة ARGB: 255, 59, 130, 246)
  static const Color lightGrey = Color(
    0xFFF4F4F4,
  ); // لون خلفية حقول الإدخال (تم تصحيح القيمة)
  static const Color labelColor = Color(
    0xFF1F2937,
  ); // لون عناوين الحقول (رمادي داكن)

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //------------ Function ------------------//

  Future<void> registerNewUser() async {
    print(
      "STARTING REGISTRATION FUNCTION",
    ); // Explicit print to confirm execution
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String phone = _phoneController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showErrorDialog('يرجى ملء جميع الحقول');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('كلمة المرور غير متطابقة');
      return;
    }

    if (password.length < 6) {
      _showErrorDialog('كلمة المرور يجب أن تكون 6 أحرف على الأقل');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(name);
        await userCredential.user!.reload();

        // -------------------------------------------------------------
        // Save user data to Cloud Firestore
        // -------------------------------------------------------------
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
              'uid': userCredential.user!.uid,
              'name': name,
              'email': email,
              'phone': phone,
              'createdAt': FieldValue.serverTimestamp(),
            });
        print("USER DATA SAVED TO FIRESTORE");
      }

      if (!mounted) return;

      // Navigate to Home Screen on success
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      // ---------------------------------------------------------
      // Log the error to the console so we can see it in the terminal
      print("FIREBASE AUTH ERROR: ${e.code} - ${e.message}");
      // ---------------------------------------------------------

      String message = 'فشل التسجيل: ${e.message}'; // Show raw message
      String details = 'كود الخطأ: ${e.code}'; // Show code

      if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جداً.';
      } else if (e.code == 'email-already-in-use') {
        message = 'البريد الإلكتروني مستخدم بالفعل.';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صحيحة.';
      } else if (e.code == 'operation-not-allowed') {
        message =
            'يرجى تفعيل تسجيل الدخول بالبريد وكلمة المرور في إعدادات Firebase.';
      } else if (e.code == 'network-request-failed') {
        message = 'يرجى التأكد من الاتصال بالإنترنت.';
      }
      _showErrorDialog(message, details: details);
    } catch (e) {
      print("GENERAL ERROR: $e");
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
  Future<void> signUpWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleAuthService googleAuthService = GoogleAuthService();
      final result = await googleAuthService.signInWithGoogle();

      if (!mounted) return;

      if (result['success'] == true) {
        // Navigate to Home Screen on success
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      } else {
        // Show error dialog
        _showErrorDialog(
          result['error'] ?? 'فشل التسجيل عبر Google',
          details: result['errorDetails'],
        );
      }
    } catch (e) {
      print('GOOGLE SIGN-UP ERROR: $e');
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
    // تحديد اتجاه النص ليكون من اليمين إلى اليسار (RTL) بشكل افتراضي للشاشة
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 1. زر العودة (السهم المتجه لليمين)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Image.asset(
                      'assets/images/back.png', // استخدام back.png
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) {
                        // رمز بديل في حالة عدم وجود الصورة
                        return const Icon(
                          Icons.arrow_forward_ios,
                          color: primaryBlue,
                          size: 28,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // 2. الشعار والعنوان الرئيسي
                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png', // مسار الشعار
                        height: 80,
                        width: 80,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                              Icons.shield_outlined,
                              size: 80,
                              color: primaryBlue,
                            ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'إنشاء حساب جديد',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 3. حقول الإدخال
                _buildLabeledTextField(
                  label: 'الاسم الكامل *',
                  hintText: 'يرجى إدخال الاسم الرباعي كما في الهوية',
                  keyboardType: TextInputType.name,
                  controller: _nameController,
                ),
                const SizedBox(height: 20),

                _buildLabeledTextField(
                  label: 'البريد الإلكتروني *',
                  hintText: 'يستخدم لتسجيل الدخول واستلام رمز التحقق',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),

                _buildLabeledTextField(
                  label: 'رقم الجوال *',
                  hintText: 'أدخل رقمك بصيغة دولية',
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور
                _buildPasswordTextField(
                  label: 'كلمة المرور *',
                  controller: _passwordController,
                ),
                const SizedBox(height: 20),

                // حقل تأكيد كلمة المرور الجديد
                _buildPasswordTextField(
                  label: 'تأكيد كلمة المرور *',
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 40),

                // 4. زر إنشاء حساب
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : registerNewUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue, // استخدام الثابت lightBlue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),

                // 5. فاصل "أو تسجيل الدخول عن طريق"
                const Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.grey, thickness: 0.5),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'او تسجيل الدخول عن طريق',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.grey, thickness: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 6. زر تسجيل الدخول عبر جوجل
                SizedBox(
                  height: 55,
                  child: OutlinedButton.icon(
                    onPressed: _isGoogleLoading ? null : signUpWithGoogle,
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      side: const BorderSide(
                        color: Color(0xFFE5E7EB),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                            'assets/images/google-logo.jpg', // يرجى التأكد من مسار شعار جوجل
                            height: 24,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.public, color: primaryBlue),
                          ),
                    label: Text(
                      _isGoogleLoading ? 'جاري التسجيل...' : 'Google',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textDirection:
                          TextDirection.ltr, // لغة جوجل عادةً ما تكون LTR
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // 7. هل تملك حساب؟ تسجيل دخول
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'هل تمتلك حساب؟',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      TextButton(
                        onPressed: () {
                          // الانتقال إلى شاشة تسجيل الدخول
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'تسجيل دخول',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لبناء حقول الإدخال النصية العادية
  Widget _buildLabeledTextField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hintText,
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
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  // دالة مساعدة لبناء حقول كلمة المرور
  Widget _buildPasswordTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 8),
        // تم استخدام فئة فرعية مخصصة لإدارة حالة إظهار/إخفاء كلمة المرور
        _PasswordTextField(
          lightGrey: lightGrey,
          primaryBlue: primaryBlue,
          controller: controller,
        ),
      ],
    );
  }
}

// فئة فرعية لإدارة حالة حقل كلمة المرور (إظهار/إخفاء النص)
class _PasswordTextField extends StatefulWidget {
  final Color lightGrey;
  final Color primaryBlue;
  final TextEditingController controller;

  const _PasswordTextField({
    required this.lightGrey,
    required this.primaryBlue,
    required this.controller,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<_PasswordTextField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: widget.controller,
        textAlign: TextAlign.right,
        obscureText: _obscureText,
        decoration: InputDecoration(
          hintText: '********',
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
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
              color: widget.primaryBlue,
            ),
            onPressed: _toggleVisibility,
          ),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }
}
