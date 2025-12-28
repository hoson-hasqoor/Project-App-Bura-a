import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color buttonBlue = Color(0xFF3B82F6);

  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Send password reset email using Firebase Auth
  Future<void> sendPasswordResetEmail() async {
    final String email = _emailController.text.trim();

    // Validation
    if (email.isEmpty) {
      _showErrorDialog('يرجى إدخال البريد الإلكتروني');
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog('يرجى إدخال بريد إلكتروني صحيح');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Send password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      // Show success dialog
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      print('PASSWORD RESET ERROR: ${e.code} - ${e.message}');

      String errorMessage = 'فشل إرسال رابط إعادة تعيين كلمة المرور';
      String details = 'كود الخطأ: ${e.code}';

      if (e.code == 'user-not-found') {
        errorMessage = 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'صيغة البريد الإلكتروني غير صحيحة.';
      } else if (e.code == 'network-request-failed') {
        errorMessage = 'يرجى التأكد من الاتصال بالإنترنت.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'تم إرسال عدد كبير من الطلبات. يرجى المحاولة لاحقاً.';
      }

      if (!mounted) return;
      _showErrorDialog(errorMessage, details: details);
    } catch (e) {
      print('GENERAL ERROR: $e');
      if (!mounted) return;
      _showErrorDialog('حدث خطأ غير متوقع', details: '$e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Show error dialog with Arabic message
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
                style: const TextStyle(fontSize: 12, color: Colors.grey),
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

  /// Show success dialog with instructions
  void _showSuccessDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'تم إرسال الرابط بنجاح',
          textAlign: TextAlign.right,
          style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'تم إرسال رابط إعادة تعيين كلمة المرور إلى:\n${_emailController.text.trim()}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 15),
            const Text(
              'يرجى التحقق من صندوق البريد الوارد (وصندوق الرسائل غير المرغوبة) واتباع التعليمات لإعادة تعيين كلمة المرور.',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to login screen
            },
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

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
                    child: const Icon(
                      Icons.lock_reset,
                      size: 120,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // 6. تعليمات
              const Text(
                'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 20),

              // 7. حقل البريد الإلكتروني
              _buildLabeledTextField(
                label: 'البريد الإلكتروني',
                hintText: 'example@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 40),

              // 8. زر إرسال الرابط
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : sendPasswordResetEmail,
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
                          'إرسال رابط إعادة التعيين',
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

              // 9. رابط العودة لتسجيل الدخول
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'العودة إلى تسجيل الدخول',
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryBlue,
                      fontWeight: FontWeight.w600,
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

  /// Build labeled text field
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
            color: Colors.black87,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: lightGrey,
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextFormField(
            controller: controller,
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
        ),
      ],
    );
  }
}
