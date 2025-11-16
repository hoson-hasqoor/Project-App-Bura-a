// lib/screens/dependents_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:flutter_application_1/screens/add_dependent_screen.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/app_drawer.dart';

class DependentsManagementScreen extends StatelessWidget {
  const DependentsManagementScreen({super.key});

  // ===== بيانات وهمية للمرافقين (يمكن استبدالها ببيانات حقيقية لاحقاً)
  final List<Map<String, dynamic>> _mockDependents = const [
    {'name': 'سارة محمد العلي', 'relation': 'زوجة', 'gender': 'female'},
    {'name': 'خالد محمد العلي', 'relation': 'ابن', 'gender': 'male'},
    {'name': 'ليلى محمد العلي', 'relation': 'ابنة', 'gender': 'female'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),

      // ===== AppBar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(right: 10.0),
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
          const SizedBox(width: 8),
        ],
        title: const Text(
          'ادارة المرافقين',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
        centerTitle: true,
      ),

      // ===== Body
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // أزرار الملفات الشخصية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildProfileSelectors(),
            ),
            const SizedBox(height: 10),

            // قائمة المرافقين (الجديدة)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: _mockDependents.length,
                itemBuilder: (context, index) {
                  return _buildDependentCard(context, _mockDependents[index]);
                },
              ),
            ),

            // زر إضافة موعد جديد
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20,
              ),
              child: _buildAddAppointmentButton(context),
            ),

            // شريط التنقل السفلي
            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  // ===== تصميم بطاقة المرافق الجديد (Card Design)
  Widget _buildDependentCard(
    BuildContext context,
    Map<String, dynamic> dependent,
  ) {
    final isFemale = dependent['gender'] == 'female';
    final avatarColor = isFemale ? Colors.pink.shade100 : Colors.blue.shade100;
    final iconColor = isFemale ? Colors.pink.shade700 : Colors.blue.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // الصورة الرمزية (Avatar)
            CircleAvatar(
              radius: 25,
              backgroundColor: avatarColor,
              child: Icon(
                isFemale ? Icons.face_5_outlined : Icons.face_6_outlined,
                color: iconColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 15),

            // الاسم والعلاقة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dependent['name']!,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'العلاقة: ${dependent['relation']!}',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            // زر الإجراء السريع (عرض الملف)
            TextButton.icon(
              onPressed: () {
                // TODO: التنقل إلى شاشة ملف المرافق
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('عرض ملف: ${dependent['name']}')),
                );
              },
              icon: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: HomeScreen.primaryBlue,
              ),
              label: const Text(
                'عرض الملف',
                style: TextStyle(
                  color: HomeScreen.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerRight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== أزرار الملفات الشخصية
  Widget _buildProfileSelectors() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildProfileButton(
            'حسابك الشخصي',
            Colors.grey.shade300,
            Colors.black87,
          ),
          const SizedBox(width: 8),
          _buildProfileButton(
            'احمد سامي العلي',
            Colors.grey.shade300,
            Colors.black87,
          ),
          const SizedBox(width: 8),
          _buildProfileButton(
            'محمد سامي العلي',
            HomeScreen.primaryBlue,
            Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(
    String text,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: backgroundColor == HomeScreen.primaryBlue
              ? HomeScreen.primaryBlue
              : Colors.grey.shade300,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ===== زر إضافة موعد جديد
  Widget _buildAddAppointmentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddDependentScreen()),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF003366),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
        elevation: 5,
      ),
      child: const Text(
        'إضافة مرفق جديد',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ===== شريط التنقل السفلي
  Widget _buildBottomNavigationBar(BuildContext context) {
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
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
          InkWell(
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            ),
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
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            icon: const Icon(
              Icons.notifications_none,
              size: 30,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
