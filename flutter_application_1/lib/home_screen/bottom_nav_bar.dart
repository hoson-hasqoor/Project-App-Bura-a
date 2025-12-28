import 'package:flutter/material.dart';
// يجب التأكد من استيراد الشاشات المطلوبة لعملية التنقل
import '../home_screen/home_screen.dart';
import '../home_screen/notifications_screen.dart';

class DetailedBottomNavBar extends StatelessWidget {
  // لم يعد هناك حاجة لـ selectedIndex أو _buildNavItem في هذا التصميم الجديد.
  const DetailedBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    // هذا هو الكود الجديد الذي يمثل شريط الأدوات (منيو، رئيسية، إشعارات)
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: HomeScreen.veryLightBlue.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. زر الإشعارات (تم عكسه ليصبح العنصر الأول على اليسار في Row الموجهة من اليسار لليمين)
          IconButton(
            onPressed: () {
              // الانتقال إلى شاشة الإشعارات
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              size: 30,
              color: Colors.grey,
            ),
          ),

          // 2. زر الرئيسية الدائري
          InkWell(
            onTap: () {
              // الانتقال إلى الشاشة الرئيسية وإلغاء جميع المسارات السابقة
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: HomeScreen.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),

          // 3. زر المنيو لفتح الدرج الجانبي (تم عكسه ليصبح العنصر الثالث على اليمين)
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                // فتح الدرج الجانبي (End Drawer)
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
