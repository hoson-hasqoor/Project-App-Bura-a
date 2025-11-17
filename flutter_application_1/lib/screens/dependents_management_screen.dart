// lib/screens/dependents_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:flutter_application_1/screens/add_dependent_screen.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/app_drawer.dart';

class DependentsManagementScreen extends StatelessWidget {
  const DependentsManagementScreen({super.key});

  // بيانات تجريبية (يمكنك لاحقاً ربطها بقاعدة بيانات)
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

      // ===================== AppBar =====================
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 70,

        // Logo على اليمين حسب اتجاه RTL
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

        // زر الرجوع Back.png
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],

        // عنوان الشاشة
        title: const Text(
          'إدارة المرافقين',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
        centerTitle: true,
      ),

      // ===================== BODY =====================
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildProfileSelectors(),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(10.0),
                itemCount: _mockDependents.length,
                itemBuilder: (context, index) {
                  return _buildDependentCard(context, _mockDependents[index]);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20,
              ),
              child: _buildAddDependentButton(context),
            ),

            _buildBottomNavigationBar(context),
          ],
        ),
      ),
    );
  }

  // ===================== بطاقة المرافق =====================
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
          children: [
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

            TextButton.icon(
              onPressed: () {
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
            ),
          ],
        ),
      ),
    );
  }

  // ===================== أزرار الحسابات =====================
  Widget _buildProfileSelectors() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
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

  // ===================== زر إضافة مرافق =====================
  Widget _buildAddDependentButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddDependentScreen()),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: HomeScreen.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.8, 50),
      ),
      child: const Text(
        'إضافة فرد/مرافق جديد',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // ===================== Bottom Navigation =====================
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
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
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
