import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        centerTitle: true,
        title: const Text(
          'اتصل بنا',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
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
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context); // العودة للشاشة السابقة
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // هنا نصنع الاتجاه من اليمين لليسار
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'للتواصل معنا، يمكنك استخدام المعلومات التالية:',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Icon(Icons.phone, color: HomeScreen.primaryBlue),
                  SizedBox(width: 10),
                  Text('+970 123 456 789', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: const [
                  Icon(Icons.email, color: HomeScreen.primaryBlue),
                  SizedBox(width: 10),
                  Text('burr@gmail.com', style: TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // مثال: يمكن فتح البريد الإلكتروني أو تطبيق الاتصال
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'أرسل رسالة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
