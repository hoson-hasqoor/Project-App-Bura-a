import 'package:flutter/material.dart';
import 'OtpVerificationScreen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color buttonBlue = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // 1. زر الرجوع (تم تعديله لتحديد الحجم بشكل أوضح وإزالة تلوين الصورة)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/back.png', // تأكد من وجود الصورة في هذا المسار
                    width: 28,
                    height: 28,

                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.arrow_forward,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),

              // 2. الشعار
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 3. العنوان الرئيسي
              const Text(
                'نسيت كلمة السر؟',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 5),

              // 4. رسالة ترحيب قصيرة
              const Text(
                'لا تقلق نحن هنا لمساعدتك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 40),

              // 5. الصورة التوضيحية
              Center(
                child: Image.asset(
                  'assets/images/forgot_password_illustration.png',
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Text(
                      'صورة توضيحية مفقودة',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 6. اختيار طريقة الاستعادة
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'رقم الهاتف المحمول؟',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryBlue,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(width: 40),
                  const Text(
                    'البريد الإلكتروني',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 7. حقل الإدخال
              _buildModernTextField(
                hintText: 'example@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),

              // 8. زر إرسال الرمز
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // الانتقال إلى صفحة OTP Verification
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OtpVerificationScreen(),
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
                    'ارسل الرمز',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة حقل الإدخال المستخدمة
  Widget _buildModernTextField({
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: lightGrey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        textAlign: TextAlign.right,
        keyboardType: keyboardType,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
