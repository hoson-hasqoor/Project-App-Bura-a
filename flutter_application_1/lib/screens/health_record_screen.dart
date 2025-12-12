import 'package:flutter/material.dart';
import 'package:flutter_application_1/Health_record/lab_xray_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import '../home_screen/home_screen.dart'; // مسار افتراضي
import '../Health_record/family_history_screen.dart'; // مسار افتراضي
import '../Health_record/medicines_screen.dart'; // مسار افتراضي
import '../home_screen/app_drawer.dart'; // مسار افتراضي
import '../Health_record/chronic_diseases_screen.dart'; // مسار افتراضي

// استيراد الشاشات التي سيتم فصلها:
import '../Health_record/hospital_stay_screen.dart';
import '../Health_record/surgeries_screen.dart';
import '../Health_record/vaccines_screen.dart';
import '../Health_record/allergies_screen.dart';

class HealthRecordScreen extends StatefulWidget {
  const HealthRecordScreen({super.key});

  @override
  State<HealthRecordScreen> createState() => _HealthRecordScreenState();
}

class _HealthRecordScreenState extends State<HealthRecordScreen> {
  int _selectedUserIndex = 0;

  final List<String> _users = [
    'حسابك الشخصي',
    'احمد سامي العلي',
    'محمد سامي العلي',
  ];

  // قائمة العناصر الصحية (تم الآن ربطها بالشاشات المنفصلة)
  final List<Map<String, dynamic>> _healthItems = [
    {
      'title': 'الأمراض المزمنة',
      'icon': Icons.favorite_border,
      'imageAsset': 'assets/images/chronic_diseases.png',
      'target': const ChronicDiseasesScreen(),
    },
    {
      'title': 'التاريخ العائلي',
      'icon': Icons.people_outline,
      'imageAsset': 'assets/images/family_history.png',
      'target': const FamilyHistoryScreen(),
    },
    {
      'title': 'الدخول للمستشفى',
      'icon': Icons.local_hospital_outlined,
      'imageAsset': 'assets/images/hospital_stay.png',
      'target': const HospitalAdmissionScreen(),
    },
    {
      'title': 'العمليات الجراحية',
      'icon': Icons.medical_services_outlined,
      'imageAsset': 'assets/images/surgeries.png',
      'target': const SurgeriesScreen(),
    },
    {
      'title': 'المطاعيم',
      'icon': Icons.vaccines_outlined,
      'imageAsset': 'assets/images/vaccines.png',
      'target': const VaccinesScreen(),
    },
    {
      'title': 'الحساسية',
      'icon': Icons.warning_amber_outlined,
      'imageAsset': 'assets/images/allergies.png',
      'target': const AllergiesScreen(),
    },
    {
      'title': 'التحاليل والفحوصات',
      'icon': Icons.science_outlined,
      'imageAsset': 'assets/images/lab_xray.png',
      'target': const AddLabXrayScreen(),
    },
    {
      'title': 'الأدوية',
      'icon': Icons.medication_liquid_outlined,
      'imageAsset': 'assets/images/medicines.png',
      'target': const MedicinesScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,

        // زر الشعار (Logo) في اليمين (Leading)
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

        title: const Text(
          'البيانات الصحية ',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,

        // زر العودة (Back Button) في اليسار (Actions)
        actions: [
          IconButton(
            onPressed: () {
              // التوجه إلى شاشة HomeScreen وإزالة الشاشات السابقة
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false, // يحذف كل الشاشات السابقة من الstack
              );
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildUserSelectionTabs(),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: _healthItems.length,
                  itemBuilder: (context, index) {
                    final item = _healthItems[index];
                    return _buildHealthItemCard(
                      title: item['title'] as String,
                      icon: item['icon'] as IconData,
                      imageAsset: item['imageAsset'] as String,
                      targetScreen: item['target'] as Widget?,
                    );
                  },
                ),
              ),
            ),

            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSelectionTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(_users.length, (index) {
          final isSelected = index == _selectedUserIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedUserIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: index == 0 ? 0 : 8),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? HomeScreen.veryLightBlue.withOpacity(0.5)
                    : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? HomeScreen.primaryBlue
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                _users[index],
                style: TextStyle(
                  color: isSelected ? HomeScreen.primaryBlue : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHealthItemCard({
    required String title,
    required IconData icon,
    required String imageAsset,
    Widget? targetScreen,
  }) {
    final Widget iconOrImage = Image.asset(
      imageAsset,
      width: 100,
      height: 100,
      errorBuilder: (context, error, stackTrace) {
        return Icon(icon, size: 100, color: HomeScreen.primaryBlue);
      },
    );

    return GestureDetector(
      onTap: () {
        if (targetScreen != null) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => targetScreen));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title - لم يتم تصميم الشاشة بعد.')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconOrImage,
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),

          InkWell(
            onTap: () {
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

          IconButton(
            onPressed: () {
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
        ],
      ),
    );
  }
}
