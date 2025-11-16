import 'package:flutter/material.dart';
import 'package:flutter_application_1/auth/SuccessfulScreen.dart';

// تعريف شاشة نقل السجل الصحي
class TransferMedicalRecordScreen extends StatelessWidget {
  const TransferMedicalRecordScreen({super.key});

  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(
    0xFF004AAD,
  ); // أزرق داكن (تقريبي للشعار والعنوان)
  static const Color lightBlue = Color(0xFF4C7FFF); // اللون الأزرق لزر النقل
  static const Color textBodyColor = Color(0xFF6B7280); // لون النص الرمادي

  @override
  Widget build(BuildContext context) {
    // تحديد اتجاه النص ليكون من اليمين إلى اليسار (RTL) بشكل افتراضي للشاشة
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
                      // **** التعديل هنا ليعكس أسلوب back.png ****
                      icon: Image.asset(
                        'assets/images/back.png', // استخدام صورة السهم back.png
                        width: 28,
                        height: 28,

                        errorBuilder: (context, error, stackTrace) {
                          // Placeholder في حال عدم العثور على الصورة
                          return const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black, // أو lightBlue
                            size: 28,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. الشعار والعنوان
                  Center(
                    child: Column(
                      children: [
                        // الشعار (استخدام assets/images/logo.png)
                        Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                          width: 80,
                          errorBuilder: (context, error, stackTrace) {
                            // Placeholder في حال عدم العثور على الصورة
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

                  // 3. الوصف
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'يمكنك ان تستورد سجلك الطبي من نظام آخر بسهولة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: textBodyColor),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 4. الرسم التوضيحي (باستخدام Image.asset)
                  Center(
                    child: Image.asset(
                      'assets/images/data_transfer_illustration.png',
                      height: 200,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // الحاوية البديلة للرسم التوضيحي
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

                  // 5. حقل الإدخال الأول: البريد الإلكتروني للمسؤول
                  _buildDisplayField(
                    label: 'البريد الإلكتروني للمسؤول',
                    hint: 'البريد الإلكتروني للشخص الذي أنشأ الحساب',
                  ),
                  const SizedBox(height: 20),

                  // 6. حقل الإدخال الثاني: البريد الإلكتروني المرتبط بالسجل
                  _buildDisplayField(
                    label: 'البريد الإلكتروني المرتبط بالسجل',
                    hint: 'ادخل البريد الإلكتروني المرتبط بالسجل',
                  ),
                  const SizedBox(height: 80),

                  // 7. زر إرسال طلب النقل
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SuccessfulScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
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
    );
  }

  // دالة مساعدة لبناء حقول الإدخال بشكلها في الصورة
  Widget _buildDisplayField({required String label, required String hint}) {
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
          height: 55,
          decoration: BoxDecoration(
            color: Colors.grey[100], // لون خلفية فاتح للحقل
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                hint,
                style: const TextStyle(fontSize: 14, color: textBodyColor),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
