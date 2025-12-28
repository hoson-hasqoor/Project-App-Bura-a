import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/SuccessfulScreen.dart';

// تعريف شاشة نقل السجل الصحي
class TransferMedicalRecordScreen extends StatefulWidget {
  const TransferMedicalRecordScreen({super.key});

  @override
  State<TransferMedicalRecordScreen> createState() =>
      _TransferMedicalRecordScreenState();
}

class _TransferMedicalRecordScreenState
    extends State<TransferMedicalRecordScreen> {
  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlue = Color(0xFF4C7FFF);
  static const Color textBodyColor = Color(0xFF6B7280);

  final TextEditingController _adminEmailController = TextEditingController();
  final TextEditingController _recordEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _adminEmailController.dispose();
    _recordEmailController.dispose();
    super.dispose();
  }

  void _submitTransferRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // هنا يمكن إضافة منطق إرسال الطلب إلى Firebase في المستقبل
      // حالياً سنحاكي تأخير بسيط ثم ننتقل للشاشة التالية
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SuccessfulScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'assets/images/back.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black,
                              size: 28,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                            width: 80,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.medical_services_outlined,
                                size: 80,
                                color: primaryBlue,
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'انقل سجلك الصحي',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'يمكنك ان تستورد سجلك الطبي من نظام آخر بسهولة',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: textBodyColor),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: Image.asset(
                        'assets/images/data_transfer_illustration.png',
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.analytics_outlined,
                                size: 100,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 60),

                    _buildTextField(
                      controller: _adminEmailController,
                      label: 'البريد الإلكتروني للمسؤول',
                      hint: 'البريد الإلكتروني للشخص الذي أنشأ الحساب',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'البريد الإلكتروني غير صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _recordEmailController,
                      label: 'البريد الإلكتروني المرتبط بالسجل',
                      hint: 'ادخل البريد الإلكتروني المرتبط بالسجل',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'البريد الإلكتروني غير صحيح';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 80),
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitTransferRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 5,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'إرسال طلب النقل',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(15),
          ),
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.right,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 14, color: textBodyColor),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
