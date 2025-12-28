import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class MetricsSection extends StatefulWidget {
  const MetricsSection({super.key});

  @override
  State<MetricsSection> createState() => _MetricsSectionState();
}

class _MetricsSectionState extends State<MetricsSection> {
  DocumentReference _getDocRef() {
    final user = FirebaseAuth.instance.currentUser!;
    final profileProvider = context.watch<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;
    final isSharedProfile = profileProvider.isSharedProfile;

    if (selectedProfileId == null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('health_profile')
          .doc('current');
    } else if (isSharedProfile) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(selectedProfileId)
          .collection('health_profile')
          .doc('current');
    } else {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId)
          .collection('health_profile')
          .doc('current');
    }
  }

  Future<void> _updateMetrics({
    required String height,
    required String weight,
    required String bloodPressure,
    required String heartRate,
    required String sugarLevel,
  }) async {
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

    double h = double.tryParse(height) ?? 0;
    double w = double.tryParse(weight) ?? 0;
    double bmi = (h > 0) ? w / ((h / 100) * (h / 100)) : 0;

    await docRef.set({
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'blood_pressure': bloodPressure,
      'heart_rate': heartRate,
      'sugar_level': sugarLevel,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Widget _buildMetricCard({
    required String imagePath,
    required IconData fallbackIcon,
    required Color bgColor,
    required String title,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: ClipOval(
              child: SizedBox(
                width: 45,
                height: 45,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(fallbackIcon, size: 30, color: valueColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      unit,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 13,
                        color: valueColor.withOpacity(.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: valueColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: _getDocRef().snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        final bp = data?['blood_pressure']?.toString() ?? '0/0';
        final hr = data?['heart_rate']?.toString() ?? '0';
        final sugar = data?['sugar_level']?.toString() ?? '0';

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'أحدث المقاييس الحيوية',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              _buildMetricCard(
                imagePath: "assets/images/blood_pressure.png",
                fallbackIcon: Icons.monitor_heart,
                bgColor: const Color(0xffE0F2E9),
                title: 'ضغط الدم',
                value: bp,
                unit: 'mmHg',
                valueColor: Colors.green,
              ),
              const SizedBox(height: 15),
              _buildMetricCard(
                imagePath: "assets/images/heart_rate.png",
                fallbackIcon: Icons.favorite,
                bgColor: const Color(0xffffe6e6),
                title: 'معدل النبض',
                value: hr,
                unit: 'نبضة/د',
                valueColor: Colors.red,
              ),
              const SizedBox(height: 15),
              _buildMetricCard(
                imagePath: "assets/images/sugar.png",
                fallbackIcon: Icons.bloodtype,
                bgColor: const Color(0xfffff3d9),
                title: 'مستوى السكر',
                value: sugar,
                unit: 'mg/dL',
                valueColor: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }
}
