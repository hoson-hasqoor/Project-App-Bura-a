// lib/screens/add_dependent_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'request_record_screen.dart'; // استيراد صفحة طلب السجل

class AddDependentScreen extends StatefulWidget {
  const AddDependentScreen({super.key});

  @override
  State<AddDependentScreen> createState() => _AddDependentScreenState();
}

class _AddDependentScreenState extends State<AddDependentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== AppBar مع شعار 40x40 وزر الرجوع
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          'إضافة مرافق جديد',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ===== Body
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),

              // صورة توضيحية لشجرة العائلة/المرافقين
              Image.asset(
                'assets/images/family_tree_placeholder.png',
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 40),

              // شعار إضافي في الوسط
              Image.asset('assets/images/logo.png', height: 60),
              const SizedBox(height: 10),
              const Text(
                'إضافة مرافق جديد',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 30),

              // ===== زر إنشاء حساب جديد
              _buildActionButton(
                context,
                text: 'إنشاء حساب جديد للمرافق',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم اختيار: إنشاء حساب جديد للمرافق'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 15),

              // ===== زر طلب إدارة سجل موجود مسبقاً
              _buildActionButton(
                context,
                text: 'طلب إدارة سجل موجود مسبقاً',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RequestRecordScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ===== ويدجت موحد للأزرار الرئيسية
  Widget _buildActionButton(
    BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: HomeScreen.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
