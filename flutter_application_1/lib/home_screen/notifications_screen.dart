import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import '../home_screen/home_screen.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Listen to profile changes via Provider
  String? _lastProfileId;

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: _buildAppBar(context),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Column(
        children: [
           // Profile Tabs using shared widget
           const Padding(
             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
             child: SharedProfileTabs(showTitle: false),
           ),
           
           Expanded(
             child: _buildNotificationsList(),
           ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        leadingWidth: 70,
        title: const Text(
          'الإشعارات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(width: 40, height: 40, color: Colors.grey[200]),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('assets/images/back.png', width: 24, height: 24, errorBuilder: (c,e,s) => const Icon(Icons.arrow_forward)),
          ),
          const SizedBox(width: 8),
        ],
      );
  }

  Widget _buildNotificationsList() {
      final user = _auth.currentUser;
      if (user == null) return const Center(child: Text("يرجى تسجيل الدخول"));

      final profileProvider = context.watch<ProfileProvider>();
      final selectedProfileId = profileProvider.selectedProfileId;
      
      // Determine collection path
      Query query;
      if (selectedProfileId == null) {
          query = _firestore.collection('users').doc(user.uid).collection('notifications');
      } else {
          query = _firestore.collection('users').doc(user.uid)
                .collection('dependents').doc(selectedProfileId)
                .collection('notifications');
      }
      
      // Order by timestamp
      query = query.orderBy('created_at', descending: true);

      return StreamBuilder<QuerySnapshot>(
         stream: query.snapshots(),
         builder: (context, snapshot) {
            if (snapshot.hasError) {
               return Center(child: Text("حدث خطأ: ${snapshot.error}"));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator());
            }
            
            final docs = snapshot.data?.docs ?? [];
            if (docs.isEmpty) {
               return const Center(
                   child: Column(
                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                           Icon(Icons.notifications_off, size: 50, color: Colors.grey),
                           SizedBox(height: 10),
                           Text("لا توجد إشعارات حالياً", style: TextStyle(color: Colors.grey, fontSize: 16)),
                       ],
                   )
               );
            }
            
            return ListView.builder(
               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
               itemCount: docs.length,
               itemBuilder: (context, index) {
                   final data = docs[index].data() as Map<String, dynamic>;
                   final title = data['title'] ?? 'إشعار جديد';
                   final body = data['body'] ?? '';
                   final timestamp = data['created_at'] as Timestamp?;
                   
                   String dateStr = "";
                   if (timestamp != null) {
                       dateStr = DateFormat("d/M/yyyy h:mm a").format(timestamp.toDate());
                   }
                   
                   return _buildNotificationCard(context, title, body, dateStr);
               }
            );
         }
      );
  }

  Widget _buildNotificationCard(BuildContext context, String title, String body, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Text(
                      title,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          body,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                    if (date.isNotEmpty) ...[
                         const SizedBox(height: 8),
                         Text(
                          date,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                         )
                    ]
                ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: HomeScreen.veryLightBlue.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: HomeScreen.primaryBlue,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 ويدجت شريط التنقل السفلي (Bottom Navigation Bar)
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
          // 1. 🔔 زر الإشعارات (رمادي لأنه غير نشط الآن)
          IconButton(
            onPressed: () {
              // ننتقل إلى شاشة الإشعارات - already here
            },
            icon: const Icon(
              Icons.notifications,
              size: 30,
              color: HomeScreen.primaryBlue,
            ),
          ),

          // 2. 🏠 زر الصفحة الرئيسية (نشط الآن)
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
                color: HomeScreen.primaryBlue, // 🔵 أزرق لأنها نشطة
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),

          // 3. ☰ زر القائمة
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
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
