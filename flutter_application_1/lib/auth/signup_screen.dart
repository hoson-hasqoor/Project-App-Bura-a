import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth_service.dart'; // 💡 الاستيراد الجديد
// يجب عليك التأكد من أن المسار صحيح (مثال: 'package:your_app_name/auth/auth_service.dart')
// import 'package:firebase_auth/firebase_auth.dart'; // لم نعد بحاجتها بشكل مباشر
// import 'package:firebase_core/firebase_core.dart'; // لم نعد بحاجتها بشكل مباشر
import 'login_screen.dart'; // تأكد من أن هذا الملف موجود

// 1. تحويل الشاشة إلى StatefulWidget (تم مسبقاً)
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 2. وحدات التحكم (Controllers) - (تم مسبقاً)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // 💡 إنشاء نسخة من خدمة المصادقة
  final AuthService _auth = AuthService();

  // تحديد الألوان المستخدمة في التصميم (تم مسبقاً)
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color lightGrey = Color(0xFFF4F4F4);
  static const Color labelColor = Color(0xFF1F2937);

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // التخلص من وحدات التحكم عند إغلاق الشاشة
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 3. دالة تسجيل المستخدم المحدثة (تستخدم AuthService)
  Future<void> _signupUser() async {
    // تحقق من تطابق كلمتي المرور
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'كلمتا المرور غير متطابقتين.';
      });
      return;
    }

    // التحقق من أن الحقول غير فارغة
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      setState(() {
        _errorMessage = 'الرجاء ملء جميع الحقول المطلوبة.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null; // مسح الأخطاء السابقة
    });

    // 💡 استخدام دالة registerWithEmailAndPassword من AuthService
    final user = await _auth.registerWithEmailAndPassword(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _phoneController.text.trim(),
    );

    // التحقق من نتيجة التسجيل
    if (user != null) {
      // 4. التنقل بعد التسجيل الناجح (تم التسجيل وحفظ البيانات في Firestore)
      if (mounted) {
        // إذا نجح التسجيل، ننتقل إلى شاشة تسجيل الدخول
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    } else {
      // 💡 عرض رسالة خطأ عامة في حال فشل التسجيل (الرسائل التفصيلية يتم التعامل معها داخل AuthService)
      setState(() {
        _errorMessage = 'فشل في إنشاء الحساب. تأكد من البيانات أو جرب لاحقاً.';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  // الكود التالي (Widget build... حتى نهاية الملف) يبقى كما هو تقريباً،
  // باستثناء استدعاء _signupUser في زر "إنشاء حساب"

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
                // (كود زر العودة والشعار... لم يتغير)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Image.asset(
                      'assets/images/back.png',
                      width: 28,
                      height: 28,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.arrow_forward_ios,
                        color: primaryBlue,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
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

                // حقل الاسم
                _buildLabeledTextField(
                  label: 'الاسم الكامل *',
                  hintText: 'يرجى إدخال الاسم الرباعي كما في الهوية',
                  keyboardType: TextInputType.name,
                  controller: _nameController,
                ),
                const SizedBox(height: 20),

                // حقل البريد الإلكتروني
                _buildLabeledTextField(
                  label: 'البريد الإلكتروني *',
                  hintText: 'يستخدم لتسجيل الدخول واستلام رمز التحقق',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 20),

                // حقل رقم الجوال
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
                  hintText: 'أدخل كلمة مرور قوية',
                  controller: _passwordController,
                ),
                const SizedBox(height: 20),

                // حقل تأكيد كلمة المرور
                _buildPasswordTextField(
                  label: 'تأكيد كلمة المرور *',
                  hintText: 'أعد إدخال كلمة المرور',
                  controller: _confirmPasswordController,
                ),
                const SizedBox(height: 40),

                // عرض رسالة الخطأ
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // زر إنشاء حساب
                SizedBox(
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : _signupUser, // 💡 استدعاء الدالة المحدثة
                    style: ElevatedButton.styleFrom(
                      backgroundColor: lightBlue,
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

                // (باقي الكود لفاصل جوجل والانتقال لصفحة الدخول... لم يتغير)
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

                // زر تسجيل الدخول عبر جوجل
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
                      'assets/images/google-logo.jpg',
                      height: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.public, color: primaryBlue),
                    ),
                    label: const Text(
                      'Google',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
                const SizedBox(height: 60),

                // هل تملك حساب؟ تسجيل دخول
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

  // 💡 الدوال المساعدة (_buildLabeledTextField و _buildPasswordTextField)
  // لا تحتاج لتغيير إلا أني وضعت الكود كاملاً لضمان سلامة التنفيذ.

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

  Widget _buildPasswordTextField({
    required String label,
    required String hintText,
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
        _PasswordTextField(
          lightGrey: lightGrey,
          primaryBlue: primaryBlue,
          hintText: hintText,
          controller: controller,
        ),
      ],
    );
  }
}

// فئة فرعية لإدارة حالة حقل كلمة المرور (بدون تغيير)
class _PasswordTextField extends StatefulWidget {
  final Color lightGrey;
  final Color primaryBlue;
  final String hintText;
  final TextEditingController controller;

  const _PasswordTextField({
    required this.lightGrey,
    required this.primaryBlue,
    required this.hintText,
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
