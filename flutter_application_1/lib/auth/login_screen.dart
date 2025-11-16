import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/forgot_password_screen.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/auth/welcome_screen.dart';
import 'package:flutter_application_1/screens/setting/ContactUs_Screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color buttonBlue = Color(0xFF3B82F6);

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
                  ),
                  const SizedBox(height: 20),

                  // 4. حقل كلمة المرور
                  _buildLabeledPasswordTextField(label: 'كلمة المرور'),
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
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
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

  // 1. دالة حقل الإدخال مع Label
  Widget _buildLabeledTextField({
    required String label,
    required String hintText,
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
  Widget _buildLabeledPasswordTextField({required String label}) {
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
        const _PasswordTextFieldModern(
          lightGrey: lightGrey,
          primaryBlue: primaryBlue,
          hintText: '********',
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

  const _PasswordTextFieldModern({
    required this.lightGrey,
    required this.primaryBlue,
    required this.hintText,
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
