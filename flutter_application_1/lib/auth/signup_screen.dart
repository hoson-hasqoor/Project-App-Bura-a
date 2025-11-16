import 'package:flutter/material.dart';
import 'login_screen.dart'; // تأكد من أن هذا الملف موجود

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

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
                ),
                const SizedBox(height: 20),

                _buildLabeledTextField(
                  label: 'البريد الإلكتروني *',
                  hintText: 'يستخدم لتسجيل الدخول واستلام رمز التحقق',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                _buildLabeledTextField(
                  label: 'رقم الجوال *',
                  hintText: 'أدخل رقمك بصيغة دولية',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 20),

                // حقل كلمة المرور
                _buildPasswordTextField(label: 'كلمة المرور *'),
                const SizedBox(height: 20),

                // حقل تأكيد كلمة المرور الجديد
                _buildPasswordTextField(label: 'تأكيد كلمة المرور *'),
                const SizedBox(height: 40),

                // 4. زر إنشاء حساب
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue, // استخدام الثابت lightBlue
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
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
                    onPressed: () {
                      // TODO: تنفيذ تسجيل الدخول عبر جوجل
                    },
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
                    icon: Image.asset(
                      'assets/images/google-logo.jpg', // يرجى التأكد من مسار شعار جوجل
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.public, color: primaryBlue),
                    ),
                    label: const Text(
                      'Google',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
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
  Widget _buildPasswordTextField({required String label}) {
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
        const _PasswordTextField(
          lightGrey: lightGrey,
          primaryBlue: primaryBlue,
        ),
      ],
    );
  }
}

// فئة فرعية لإدارة حالة حقل كلمة المرور (إظهار/إخفاء النص)
class _PasswordTextField extends StatefulWidget {
  final Color lightGrey;
  final Color primaryBlue;

  const _PasswordTextField({
    required this.lightGrey,
    required this.primaryBlue,
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
