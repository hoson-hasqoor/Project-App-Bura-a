import 'package:flutter/material.dart';
import '../home_screen/profile_screen.dart';
import '../home_screen/home_screen.dart';

class HeaderSliver extends StatelessWidget {
  const HeaderSliver({super.key});

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة الملف الشخصي
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileScreen()),
        );
      },
      child: CircleAvatar(
        radius: 22,
        backgroundColor: HomeScreen.veryLightBlue.withOpacity(0.5),
        child: const Icon(
          Icons.person,
          color: HomeScreen.primaryBlue,
          size: 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      pinned: true,
      elevation: 0.0,
      toolbarHeight: 90,
      leadingWidth: 80, // 🔹 زيدنا العرض الخاص بالـ leading
      // ✅ اللوجو + النص الترحيبي
      title: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ✅ اللوجو (كبرنا الحجم)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 65, // ← 🔹 كبرنا العرض
                height: 65, // ← 🔹 كبرنا الارتفاع
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('❌ خطأ بتحميل الصورة: $error');
                  return const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // ✅ النص الترحيبي
            const Expanded(
              child: Text(
                'مرحباً بك مجدداً، يا سامي👋',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: HomeScreen.primaryBlue,
                ),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      // لا نريد توسيط العنوان
      centerTitle: false,

      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, left: 24.0),
          child: _buildProfileAvatar(context),
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
