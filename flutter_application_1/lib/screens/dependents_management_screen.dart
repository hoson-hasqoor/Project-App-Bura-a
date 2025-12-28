// lib/screens/dependents_management_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:flutter_application_1/screens/add_dependent_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/app_drawer.dart';

class DependentsManagementScreen extends StatefulWidget {
  const DependentsManagementScreen({super.key});

  @override
  State<DependentsManagementScreen> createState() =>
      _DependentsManagementScreenState();
}

class _DependentsManagementScreenState
    extends State<DependentsManagementScreen> {
  // ---------------------------
  // المتغيرات
  // ---------------------------
  bool _isLoading = true;
  List<Map<String, dynamic>> _dependentsList = [];

  @override
  void initState() {
    super.initState();
    _fetchDependents();
  }

  // ---------------------------
  // جلب البيانات من Firestore
  // ---------------------------
  Future<void> _fetchDependents() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Fetch Dependents
      final dependentsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .get();

      final List<Map<String, dynamic>> combinedList = [];

      for (var doc in dependentsSnapshot.docs) {
        var map = doc.data();
        map['id'] = doc.id;
        map['is_shared'] = false; // Mark as own dependent
        combinedList.add(map);
      }

      // 2. Fetch Shared Profiles (Reverse Linked)
      final sharedSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('shared_profiles')
          .get();

      for (var doc in sharedSnapshot.docs) {
        var data = doc.data();

        // Structure shared profile to look like dependent
        combinedList.add({
          'id': data['target_user_id'],
          'name': data['target_user_name'] ?? 'Shared User',
          'relationship': 'ملف مشترك', // Shared Profile
          'is_shared': true, // Mark as shared
          'permissions': data['permissions'] ?? {}, // Pass permissions map
        });
      }

      if (mounted) {
        setState(() {
          _dependentsList = combinedList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching dependents: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              // Check if we can pop, otherwise go to HomeScreen
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _dependentsList.isEmpty
                  ? const Center(child: Text("لا يوجد مرافقين مسجلين"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: _dependentsList.length,
                      itemBuilder: (context, index) {
                        return _buildDependentCard(
                          context,
                          _dependentsList[index],
                        );
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
    // Check if it's a shared profile
    final bool isShared = dependent['is_shared'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isShared ? Colors.purple.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isShared ? Colors.purple.shade200 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Switching Button
          TextButton.icon(
            onPressed: () {
              // 1. Update Global Profile
              // 1. Update Global Profile
              context.read<ProfileProvider>().selectProfile(
                dependent['id'],
                dependent['name'],
                isShared: isShared,
                permissions: dependent['permissions'],
              );

              // 2. Show Confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم التبديل إلى ملف: ${dependent['name']}',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );

              // 3. Navigate to Home
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Icon(
              Icons.remove_red_eye_outlined,
              size: 18,
              color: isShared ? Colors.purple : HomeScreen.primaryBlue,
            ),
            label: Text(
              "عرض الملف",
              style: TextStyle(
                color: isShared ? Colors.purple : HomeScreen.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: isShared
                  ? Colors.purple.withOpacity(0.1)
                  : HomeScreen.veryLightBlue.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          const Spacer(),

          // Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dependent['name'] ?? 'بدون اسم',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isShared)
                    const Text(
                      ' (ملف مشارك) ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  Text(
                    dependent['relationship'] ?? 'مرافق',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 15),

          // Avatar / Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isShared
                  ? Colors.purple.withOpacity(0.1)
                  : HomeScreen.veryLightBlue.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isShared ? Icons.share_outlined : Icons.person_outline,
              color: isShared ? Colors.purple : HomeScreen.primaryBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // Profile tabs - using SharedProfileTabs widget
  Widget _buildProfileSelectors() {
    return const SharedProfileTabs(showTitle: false);
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
