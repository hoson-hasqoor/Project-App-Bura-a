import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // أضفنا هذا الاستيراد
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home_screen/profile_screen.dart';
import '../home_screen/home_screen.dart';
import '../providers/profile_provider.dart';

class HeaderSliver extends StatelessWidget {
  const HeaderSliver({super.key});

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () {
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

  Widget _buildProfileIndicatorBanner(
    BuildContext context,
    ProfileProvider profileProvider,
  ) {
    if (profileProvider.isMainUser) {
      return const SizedBox.shrink();
    }

    final bool isShared = profileProvider.isSharedProfile;
    final Color bgColor = isShared
        ? Colors.purple.shade50
        : HomeScreen.veryLightBlue;
    final Color borderColor = isShared ? Colors.purple : HomeScreen.primaryBlue;
    final Color textColor = isShared
        ? Colors.purple.shade700
        : HomeScreen.primaryBlue;
    final IconData icon = isShared
        ? Icons.share_outlined
        : Icons.person_outline;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isShared ? 'يتم عرض ملف مشارك' : 'يتم عرض ملف مرافق',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  profileProvider.selectedProfileName,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                profileProvider.selectMainUser(user.displayName ?? 'المستخدم');
              }
            },
            icon: const Icon(Icons.home, size: 16),
            label: const Text('الملف الرئيسي', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: borderColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        return SliverMainAxisGroup(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              pinned: true,
              elevation: 0.0,
              toolbarHeight: 90,
              leadingWidth: 80,
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 65,
                        height: 65,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // ✅ استخدام StreamBuilder لجلب الاسم وتحديثه لحظياً
                    Expanded(
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(user?.uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          String finalName = "زائر";

                          if (snapshot.hasData && snapshot.data!.exists) {
                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            // نأخذ الاسم من Firestore (تأكد من استخدام 'name' أو 'fullName' حسب قاعدة بياناتك)
                            String fullName =
                                data['name'] ??
                                data['fullName'] ??
                                user?.displayName ??
                                'زائر';
                            finalName = fullName.split(
                              ' ',
                            )[0]; // الاسم الأول فقط
                          }

                          return Text(
                            'مرحباً بك، يا $finalName 👋',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: HomeScreen.primaryBlue,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              centerTitle: false,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 24.0),
                  child: _buildProfileAvatar(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildProfileIndicatorBanner(context, profileProvider),
            ),
          ],
        );
      },
    );
  }
}
