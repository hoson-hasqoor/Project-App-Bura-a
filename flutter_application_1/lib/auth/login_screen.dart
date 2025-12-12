import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/forgot_password_screen.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/auth/welcome_screen.dart';
import 'package:flutter_application_1/screens/setting/ContactUs_Screen.dart';
// 💡 استيراد خدمة المصادقة
import 'package:flutter_application_1/auth_service.dart';
// قد تحتاج لتعديل مسار الاستيراد أعلاه إذا كان مسار الملف مختلفًا

// 1. تحويل الشاشة إلى StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 💡 المتغيرات الجديدة
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _auth = AuthService(); // نسخة من خدمة المصادقة
  bool _isLoading = false; // حالة التحميل
  String? _errorMessage; // رسالة الخطأ

  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color buttonBlue = Color(0xFF3B82F6);

  // 🌟 دالة تسجيل الدخول
  Future<void> _handleLogin() async {
    // 1. التحقق من صحة البيانات (بسيط)
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء إدخال البريد الإلكتروني وكلمة المرور.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // مسح الأخطاء السابقة
    });

    // 2. محاولة تسجيل الدخول
    final user = await _auth.signInWithEmailAndPassword(
      _emailController.text.trim(),
      _passwordController.text,
    );

    // 3. معالجة النتيجة
    if (user != null) {
      // نجاح تسجيل الدخول: الانتقال إلى الشاشة الرئيسية
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // فشل تسجيل الدخول: عرض رسالة خطأ
      if (mounted) {
        setState(() {
          _errorMessage =
              'فشل تسجيل الدخول. تحقق من بريدك الإلكتروني وكلمة المرور.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // طبقة الخلفية (بدون تغيير)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              image: DecorationImage(
                image: AssetImage('assets/images/background_logo_1.jpeg'),
                fit: BoxFit.contain,
                opacity: 0.05,
              ),
            ),
          ),

          // طبقة المحتوى
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // الشعار والعنوان (بدون تغيير)
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
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

                  // 💡 حقل البريد الإلكتروني
                  _buildLabeledTextField(
                    label: 'البريد الإلكتروني / رقم الهاتف',
                    hintText: 'example@example.com',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController, // 💡 ربط الـ Controller
                  ),
                  const SizedBox(height: 20),

                  // 💡 حقل كلمة المرور
                  _buildLabeledPasswordTextField(
                    label: 'كلمة المرور',
                    controller: _passwordController, // 💡 ربط الـ Controller
                  ),
                  const SizedBox(height: 10),

                  // ⚠️ عرض رسالة الخطأ
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                      ),
                    ),

                  // زر هل نسيت كلمة المرور؟ (بدون تغيير)
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

                  // 💡 زر تسجيل الدخول
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      // 💡 استدعاء دالة تسجيل الدخول
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            ) // حالة التحميل
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

                  // باقي العناصر (بدون تغيير)
                  const SizedBox(height: 30),
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
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showSnackBar(context, 'جاري الدخول عبر Google...');
                      },
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
                      icon: Image.asset(
                        'assets/images/google-logo.jpg',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.public, color: primaryBlue),
                      ),
                      label: const Text(
                        'جوجل',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // جزئية إنشاء حساب
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

                  // زر "اتصل بنا"
                  Center(
                    child: TextButton(
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. دالة حقل الإدخال مع Label (تم تعديلها لقبول Controller)
  Widget _buildLabeledTextField({
    required String label,
    required String hintText,
    required TextEditingController controller, // 💡 تمت الإضافة
    TextInputType keyboardType = TextInputType.text,
  }) {
    // ... (باقي الكود)
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
            controller: controller, // 💡 ربط الـ Controller
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

  // 3. دالة حقل كلمة المرور مع Label (تم تعديلها لقبول Controller)
  Widget _buildLabeledPasswordTextField({
    required String label,
    required TextEditingController controller, // 💡 تمت الإضافة
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
          controller: controller, // 💡 تمرير الـ Controller
        ),
      ],
    );
  }

  // 4. دالة إظهار الرسالة (بدون تغيير)
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

// 🌟 ويدجت حقل كلمة المرور (تم تعديله لقبول Controller)
class _PasswordTextFieldModern extends StatefulWidget {
  final Color lightGrey;
  final Color primaryBlue;
  final String hintText;
  final TextEditingController controller; // 💡 تمت الإضافة

  const _PasswordTextFieldModern({
    required this.lightGrey,
    required this.primaryBlue,
    required this.hintText,
    required this.controller, // 💡 تمت الإضافة
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
      decoration: BoxDecoration(
        color: widget.lightGrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: widget.controller, // 💡 ربط الـ Controller
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
