import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import '../providers/profile_provider.dart';

class QuickLinksSection extends StatelessWidget {
  const QuickLinksSection({super.key});

  Widget _buildTab({
    required String text,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? HomeScreen.lightBlue : HomeScreen.lightGrey,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? HomeScreen.lightBlue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: HomeScreen.lightBlue.withOpacity(0.3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _selectProfile(
    BuildContext context,
    String? profileId,
    String profileName, {
    bool isShared = false,
    Map<String, dynamic>? permissions,
  }) {
    // Update global profile state
    context.read<ProfileProvider>().selectProfile(
      profileId,
      profileName,
      isShared: isShared,
      permissions: permissions,
    );

    // Show confirmation snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isShared
              ? 'تم اختيار الملف المشارك: $profileName'
              : 'تم اختيار: $profileName',
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: isShared ? Colors.purple : HomeScreen.primaryBlue,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, userSnapshot) {
        String userName = 'حسابك الشخصي';
        if (userSnapshot.hasData && userSnapshot.data?.exists == true) {
          final data = userSnapshot.data!.data() as Map<String, dynamic>;
          userName = data['name'] ?? 'حسابك الشخصي';
        }

        // Watch the global profile state
        final selectedProfileId = context
            .watch<ProfileProvider>()
            .selectedProfileId;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 24, bottom: 12),
              child: Text(
                'حسابات إضافية وسجلات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Main user profile
                  _buildTab(
                    text: userName,
                    isSelected: selectedProfileId == null,
                    onTap: () => _selectProfile(context, null, userName),
                  ),

                  // Dependents profiles
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('dependents')
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, depSnapshot) {
                      if (!depSnapshot.hasData) return const SizedBox.shrink();

                      return Row(
                        children: depSnapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final profileName = data['name'] ?? 'مرافق';
                          final profileId = doc.id;

                          return _buildTab(
                            text: profileName,
                            isSelected: selectedProfileId == profileId,
                            onTap: () =>
                                _selectProfile(context, profileId, profileName),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  // Shared profiles
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .collection('shared_profiles')
                        .snapshots(),
                    builder: (context, sharedSnapshot) {
                      if (!sharedSnapshot.hasData)
                        return const SizedBox.shrink();

                      return Row(
                        children: sharedSnapshot.data!.docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final profileName =
                              data['target_user_name'] ?? 'ملف مشارك';
                          final profileId = data['target_user_id'];
                          final permissions =
                              data['permissions'] as Map<String, dynamic>? ??
                              {};

                          return _buildTab(
                            text: profileName,
                            isSelected: selectedProfileId == profileId,
                            onTap: () => _selectProfile(
                              context,
                              profileId,
                              profileName,
                              isShared: true,
                              permissions: permissions,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
