import 'package:flutter/material.dart';

// شاشة تعيين كلمة مرور جديدة
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(
    0xFF004AAD,
  ); // اللون الأزرق الداكن للشعار والعناوين
  static const Color buttonBlue = Color(
    0xFF3B82F6,
  ); // اللون الأزرق الفاتح للأزرار
  static const Color lightGrey = Color(0xFFF0F0F0); // لون خلفية حقول الإدخال

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  // متغيرات للتحكم برؤية كلمات المرور
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    // استخدم ارتفاع الشاشة لحساب ارتفاع الصورة بشكل مرن
    final double screenHeight = MediaQuery.of(context).size.height;
    final double illustrationHeight =
        screenHeight * 0.25; // مثلاً 25% من ارتفاع الشاشة

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
                    'assets/images/back.png', // الصورة المخصصة للرجوع
                    width: 28,
                    height: 28,
                    // استخدم errorBuilder كبديل في حال عدم وجود الصورة
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.arrow_forward, // بديل في حالة عدم العثور على الصورة
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // للرجوع إلى الشاشة السابقة
                  },
                ),
              ),
              const SizedBox(height: 10),

              // 2. الشعار
              Center(
                child: Image.asset(
                  'assets/images/logo.png', // مسار الشعار
                  height: 80,
                  width: 80,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield_outlined,
                    size: 80,
                    color: NewPasswordScreen.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. العنوان الرئيسي
              const Text(
                'تعيين كلمة مرور جديدة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: NewPasswordScreen.primaryBlue,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 5),

              // 4. رسالة قصيرة
              const Text(
                'انشئ كلمة مرور فريدة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 30),

              // 5. الصورة التوضيحية
              Center(
                child: Image.asset(
                  'assets/images/set_new_password_illustration.png', // افترض مسارًا جديدًا لهذه الصورة
                  height: illustrationHeight,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: illustrationHeight,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.vpn_key_outlined,
                      size: 150,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'تعيين كلمة مرور جديدة',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              _buildPasswordTextField(
                hintText: '***********',
                isVisible: _isNewPasswordVisible,
                onVisibilityToggle: (value) {
                  setState(() {
                    _isNewPasswordVisible = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // 7. حقل إعادة كتابة كلمة المرور الجديدة
              const Text(
                'إعادة كتابة كلمة المرور الجديدة',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 8),
              _buildPasswordTextField(
                hintText: '***********',
                isVisible: _isConfirmPasswordVisible,
                onVisibilityToggle: (value) {
                  setState(() {
                    _isConfirmPasswordVisible = value;
                  });
                },
              ),
              const SizedBox(height: 40),

              // 8. زر تعيين كلمة المرور
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    _showSnackBar(context, 'تم تعيين كلمة المرور بنجاح!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NewPasswordScreen.buttonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تعيين كلمة المرور',
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

  // دالة بناء حقل إدخال كلمة المرور
  Widget _buildPasswordTextField({
    required String hintText,
    required bool isVisible,
    required ValueChanged<bool> onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: NewPasswordScreen.lightGrey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        textAlign: TextAlign.right,
        obscureText: !isVisible, // إخفاء النص إذا لم يكن مرئياً
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
            borderSide: const BorderSide(
              color: NewPasswordScreen.primaryBlue,
              width: 2,
            ),
          ),
          prefixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: NewPasswordScreen.primaryBlue,
            ),
            onPressed: () => onVisibilityToggle(!isVisible),
          ),
        ),
      ),
    );
  }

  // دالة إظهار الرسالة (SnackBar)
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
