import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  static const String aboutAppText =
      'بِـرء هو تطبيق صحي مبتكر صُمم ليكون مرجعك الأول لإدارة صحتك وصحة عائلتك بكل سهولة وأمان. يجمع كل المعلومات الصحية في مكان واحد من التحاليل والفحوصات إلى الأدوية والمطاعيم والحساسية والأمراض المزمنة. يتيح لك متابعة الحالة الصحية لكل فرد من أفراد الأسرة مع التحكم الكامل بصلاحيات الوصول، وتوفير تنبيهات ذكية لتذكيرك بالمواعيد الطبية والأدوية والفحوصات. هدفنا هو تمكين الأسر من إدارة صحتهم بشكل منظم، آمن، وفعّال، ودعم الوقاية والوعي الصحي بأسلوب رقمي سلس ومريح.';

  @override
  Widget build(BuildContext context) {
    const Color textContainerColor = Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        title: const Text(
          'حول التطبيق',
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
              width: 40, // ✅ حجم الشعار 40x40
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: textContainerColor,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: const Text(
              AboutAppScreen.aboutAppText,
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Color(0xFF212121),
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );
  }
}
