import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/setting/ContactUs_Screen.dart';
import 'package:flutter_application_1/screens/setting/Edit_Profile_Screen.dart';
import '../home_screen/home_screen.dart';
import 'package:flutter_application_1/auth/login_screen.dart';

// استيراد الصفحات لكل عنصر
import 'setting/change_password_screen.dart';
import 'setting/help_center_screen.dart';
import 'setting/about_app_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
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
            ),
          ),
        ),
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
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('الحساب'),
            _buildSettingItem(Icons.person_outline, 'تعديل الملف الشخصي', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            }),
            _buildSettingItem(Icons.lock_outline, 'تغيير كلمة المرور', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            }),
            const Divider(),
            _buildSectionTitle('الدعم'),
            _buildSettingItem(Icons.help_outline, 'مركز المساعدة', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            }),
            _buildSettingItem(Icons.info_outline, 'حول التطبيق', () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutAppScreen()),
              );
            }),
            _buildSettingItem(Icons.phone_outlined, 'اتصل بنا', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ContactUsScreen(),
                ),
              );
            }),
            const Divider(),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryBlue,
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: HomeScreen.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: HomeScreen.veryLightBlue.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: HomeScreen.primaryBlue, size: 22),
      ),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios, // ✅ السهم نحو اليمين في RTL
        size: 18,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
