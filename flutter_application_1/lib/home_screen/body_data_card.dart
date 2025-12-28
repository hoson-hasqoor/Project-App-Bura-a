import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import 'home_screen.dart';
import 'edit_body.dart';

class BodyDataCard extends StatefulWidget {
  const BodyDataCard({super.key});

  @override
  State<BodyDataCard> createState() => _BodyDataCardState();
}

class _BodyDataCardState extends State<BodyDataCard> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    final profileProvider = context.watch<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;
    final isSharedProfile = profileProvider.isSharedProfile;

    // Build the correct Firestore document reference to health_profile/current
    DocumentReference docRef;
    if (selectedProfileId == null) {
      // Main user
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_profile')
          .doc('current');
    } else if (isSharedProfile) {
      // Shared profile: access target user's health profile
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(selectedProfileId)
          .collection('health_profile')
          .doc('current');
    } else {
      // Regular dependent
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId)
          .collection('health_profile')
          .doc('current');
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        }

        String height = '0';
        String weight = '0';
        String sugar = '0';
        String heartRate = '0';
        String bloodPressure = '';
        double bmi = 0;

        String bmiStatus = 'غير محدد';
        Color bmiColor = Colors.grey;

        if (snapshot.hasData &&
            snapshot.data != null &&
            snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;

          height = data['height']?.toString() ?? '0';
          weight = data['weight']?.toString() ?? '0';
          bmi = (data['bmi'] is num) ? (data['bmi'] as num).toDouble() : 0.0;

          if (bmi > 0) {
            if (bmi < 18.5) {
              bmiStatus = 'نحافة';
              bmiColor = const Color(0xFF42A5F5); // Blue
            } else if (bmi < 25) {
              bmiStatus = 'وزن طبيعي';
              bmiColor = const Color(0xFF66BB6A); // Green
            } else if (bmi < 30) {
              bmiStatus = 'زيادة وزن';
              bmiColor = const Color(0xFFFF9800); // Orange
            } else {
              bmiStatus = 'سمنة';
              bmiColor = const Color(0xFFEF5350); // Red
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  HomeScreen.veryLightBlue.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Edit button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditBody(),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: HomeScreen.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          color: HomeScreen.primaryBlue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                // Delete button (Soft Delete)
                // Reset button (set values to zero)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _confirmReset(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.restart_alt,
                          color: Colors.orange,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Main data row
                      Row(
                        children: [
                          // Body illustration
                          Container(
                            width: 100,
                            height: 100,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: HomeScreen.primaryBlue.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              "assets/images/body.png",
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(width: 20),

                          // Stats
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatTile(
                                        icon: Icons.height_rounded,
                                        label: 'الطول',
                                        value: height,
                                        unit: 'سم',
                                        color: const Color(0xFF42A5F5),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatTile(
                                        icon: Icons.monitor_weight_outlined,
                                        label: 'الوزن',
                                        value: weight,
                                        unit: 'كجم',
                                        color: const Color(0xFF66BB6A),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // BMI Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'مؤشر كتلة الجسم',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Text(
                                          bmi > 0
                                              ? bmi.toStringAsFixed(1)
                                              : '-',
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontWeight: FontWeight.bold,
                                            color: bmiColor,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'BMI',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bmiColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: bmiColor.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    bmiStatus,
                                    style: TextStyle(
                                      color: bmiColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // BMI Indicator
                            _buildBMIIndicator(bmi),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatTile({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIIndicator(double bmi) {
    Color indicatorColor;
    double alignment;

    if (bmi < 18.5) {
      indicatorColor = const Color(0xFF42A5F5);
      alignment = -0.75;
    } else if (bmi < 25) {
      indicatorColor = const Color(0xFF66BB6A);
      alignment = -0.25;
    } else if (bmi < 30) {
      indicatorColor = const Color(0xFFFF9800);
      alignment = 0.25;
    } else {
      indicatorColor = const Color(0xFFEF5350);
      alignment = 0.75;
    }

    return Column(
      children: [
        // Gradient bar
        Stack(
          children: [
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF42A5F5), // Blue (Underweight)
                    Color(0xFF66BB6A), // Green (Normal)
                    Color(0xFFFF9800), // Orange (Overweight)
                    Color(0xFFEF5350), // Red (Obese)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            // Indicator marker
            if (bmi > 0)
              AnimatedAlign(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                alignment: Alignment(alignment, 0),
                child: Transform.translate(
                  offset: const Offset(0, -4),
                  child: Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: indicatorColor.withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 12),

        // Labels
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBMILabel('نحافة', const Color(0xFF42A5F5), 8),
            _buildBMILabel('طبيعي', const Color(0xFF66BB6A), 8),
            _buildBMILabel('زيادة', const Color(0xFFFF9800), 8),
            _buildBMILabel('سمنة', const Color(0xFFEF5350), 8),
          ],
        ),
      ],
    );
  }

  Widget _buildBMILabel(String text, Color color, double radius) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10, color: Colors.black54)),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: HomeScreen.primaryBlue),
        ),
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين البيانات'),
        content: const Text('هل تريد تصفير جميع القيم؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _resetValues(context);
            },
            child: const Text('تصفير', style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  Future<void> _resetValues(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;
    final isSharedProfile = profileProvider.isSharedProfile;

    DocumentReference docRef;
    if (selectedProfileId == null) {
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_profile')
          .doc('current');
    } else if (isSharedProfile) {
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(selectedProfileId)
          .collection('health_profile')
          .doc('current');
    } else {
      docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId)
          .collection('health_profile')
          .doc('current');
    }

    await docRef.set({
      'height': '0',
      'weight': '0',
      'age': '0',
      'bmi': 0,
      'blood_type': '',
      'blood_pressure': '',
      'heart_rate': '0',
      'sugar_level': '0',
      'gender': 'male',
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}

Widget _buildEmptyCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: Text(
          'لا توجد بيانات صحية',
          style: TextStyle(color: Colors.grey),
        ),
      ),
    ),
  );
}
