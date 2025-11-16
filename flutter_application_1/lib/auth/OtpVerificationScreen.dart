import 'package:flutter/material.dart';
import 'NewPasswordScreen.dart'; // استيراد شاشة NewPasswordScreen

// شاشة إدخال رمز التحقق
class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color buttonBlue = Color(0xFF3B82F6);
  static const Color lightGrey = Color(0xFFF0F0F0);

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
              // 1. زر الرجوع
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Image.asset(
                    'assets/images/back.png',
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
              const SizedBox(height: 10),

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
              const SizedBox(height: 20),

              // 3. العنوان الرئيسي
              const Text(
                'تم إرسال الرمز',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 5),

              // 4. رسالة قصيرة
              const Text(
                'ادخل الرمز للاستمرار',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 30),

              // 5. الصورة التوضيحية
              Center(
                child: Image.asset(
                  'assets/images/verification_illustration.png',
                  height: 200,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.mail_lock_outlined,
                      size: 150,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 6. رسالة البريد الإلكتروني
              const Text(
                'أرسلنا رمز التحقق إلى بريدك الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 5),
              const Text(
                'your@email.com',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 30),

              // 7. حقول إدخال رمز OTP
              _buildOtpFields(),
              const SizedBox(height: 40),

              // 8. زر التأكيد
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // الانتقال إلى شاشة NewPasswordScreen عند الضغط
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NewPasswordScreen(),
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
                    'تأكيد',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 9. خيار إعادة الإرسال
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'لم تحصل على رمز التحقق؟',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                    textDirection: TextDirection.rtl,
                  ),
                  TextButton(
                    onPressed: () {
                      _showSnackBar(context, 'تمت إعادة إرسال الرمز');
                    },
                    child: const Text(
                      'إعادة ارسال',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: buttonBlue,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 60,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              color: lightGrey,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextFormField(
              onChanged: (value) {},
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLength: 1,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
            ),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
