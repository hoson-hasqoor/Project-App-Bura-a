import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/bottom_nav_bar.dart';
import 'package:flutter_application_1/home_screen/header_sliver.dart';
// استيراد جميع الأقسام الفرعية
import 'app_drawer.dart';
import 'metrics_section.dart';
import 'body_data_card.dart';
import 'quick_links_section.dart';
import 'radial_menu_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color veryLightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(0xFFF4F4F4);
  static const Color accentGreen = Color(0xFF38A169);
  static const Color accentRed = Color(0xFFD32F2F);
  static const Color accentOrange = Color(0xFFFBC02D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // الدرج الجانبي على اليمين (End Drawer) لزر القائمة
      endDrawer: const AppDrawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          const HeaderSliver(),

          // 2. محتوى الصفحة
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: const [
                  // قسم المقاييس الحيوية (المحدثة)
                  MetricsSection(),
                  SizedBox(height: 20),
                  // بطاقة بيانات الجسم (المحدثة)
                  BodyDataCard(),
                  SizedBox(height: 30),
                  // قسم الروابط السريعة
                  QuickLinksSection(),
                  SizedBox(height: 30),
                  // قسم القائمة الدائرية
                  RadialMenuSection(),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      // شريط التنقل السفلي المخصص
      bottomNavigationBar: const DetailedBottomNavBar(),
    );
  }
}
