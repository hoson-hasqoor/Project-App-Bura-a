import 'package:flutter/material.dart';
// يجب التأكد من وجود كلاس HomeScreen وتعريف primaryBlue فيه
import 'package:flutter_application_1/home_screen/home_screen.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  static const Color lightGrey = Color(0xFFF0F0F0);
  // استخدام اللون الأزرق الأساسي من HomeScreen
  static const Color buttonBlue = HomeScreen.primaryBlue;

  // ويدجت حقل الإدخال
  Widget _buildInputField({
    required String label,
    required String initialValue,
    required bool isReadOnly,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              // يحدد لون الخلفية والحدود بناءً على إمكانية التعديل
              color: isReadOnly ? lightGrey : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isReadOnly
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: const Color(0xFFCCCCCC), width: 1),
            ),
            child: TextFormField(
              initialValue: initialValue,
              readOnly: isReadOnly,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: isReadOnly ? Colors.grey.shade700 : Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0,
                ),
                border: InputBorder.none,
                // حدود زرقاء عند التركيز لتصميم شاشة التعديل
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: HomeScreen.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // لإزالة زر العودة الافتراضي
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
        centerTitle: true,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image,
                color: HomeScreen.primaryBlue,
                size: 40,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            // زر العودة: يغلق الشاشة الحالية للعودة للشاشة السابقة
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // صورة الملف الشخصي وزر الكاميرا
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: HomeScreen.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/profile.png',
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 60,
                        color: HomeScreen.primaryBlue,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: HomeScreen.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // حقول الإدخال القابلة للتعديل
            _buildInputField(
              label: 'الاسم الكامل',
              initialValue: 'محمد أحمد محمد السعيد',
              isReadOnly: false, // **للتعديل**
            ),
            _buildInputField(
              label: 'البريد الإلكتروني',
              initialValue: 'example@example.com',
              isReadOnly: false, // **للتعديل**
            ),
            _buildInputField(
              label: 'رقم الجوال',
              initialValue: '00970590000000',
              isReadOnly: false, // **للتعديل**
            ),
            const SizedBox(height: 20),

            // زر حفظ التغييرات
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // هذا هو المنطق الوحيد (عرض رسالة نجاح وهمية) لغرض التصميم
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم حفظ البيانات بنجاح! (UI فقط)',
                        textDirection: TextDirection.rtl,
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'حفظ التغييرات',
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
    );
  }
}
