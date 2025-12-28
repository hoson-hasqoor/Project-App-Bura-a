import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

class EditBody extends StatefulWidget {
  const EditBody({super.key});

  @override
  State<EditBody> createState() => _EditBodyState();
}

class _EditBodyState extends State<EditBody> {
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController bloodTypeController = TextEditingController();
  final TextEditingController pressureController = TextEditingController();
  final TextEditingController heartController = TextEditingController();
  final TextEditingController sugarController = TextEditingController();

  String gender = "male";
  double bmi = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  Future<void> _loadExistingData() async {
    try {
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

      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        setState(() {
          heightController.text = (data['height']?.toString() ?? '0') == '0'
              ? ''
              : data['height'].toString();
          weightController.text = (data['weight']?.toString() ?? '0') == '0'
              ? ''
              : data['weight'].toString();
          ageController.text = (data['age']?.toString() ?? '0') == '0'
              ? ''
              : data['age'].toString();

          bloodTypeController.text = data['blood_type']?.toString() ?? '';
          pressureController.text = data['blood_pressure']?.toString() ?? '';
          heartController.text = data['heart_rate']?.toString() ?? '';
          sugarController.text = data['sugar_level']?.toString() ?? '';

          gender = data['gender']?.toString() ?? 'male';
          bmi = (data['bmi'] is num) ? (data['bmi'] as num).toDouble() : 0.0;

          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading health data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateBMI() {
    double h = double.tryParse(heightController.text) ?? 0;
    double w = double.tryParse(weightController.text) ?? 0;

    if (h > 0 && w > 0) {
      double heightInMeters = h / 100;
      setState(() {
        bmi = w / (heightInMeters * heightInMeters);
      });
    }
  }

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
          'تعديل البيانات الحيوية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
            height: 0.90,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HomeScreen.primaryBlue),
            )
          : Directionality(
              textDirection: TextDirection.rtl,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    _title("الجنس"),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _genderCard(Icons.male, "male", "ذكر"),
                        const SizedBox(width: 15),
                        _genderCard(Icons.female, "female", "أنثى"),
                      ],
                    ),
                    const SizedBox(height: 25),
                    _title("العمر"),
                    _inputField(ageController, "أدخل العمر"),
                    const SizedBox(height: 25),
                    _title("فصيلة الدم"),
                    _inputField(
                      bloodTypeController,
                      "مثال: A+",
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 25),
                    _title("الطول (سم)"),
                    _inputField(
                      heightController,
                      "مثال: 165",
                      onChanged: (_) => _calculateBMI(),
                    ),
                    const SizedBox(height: 25),
                    _title("الوزن (كجم)"),
                    _inputField(
                      weightController,
                      "مثال: 72",
                      onChanged: (_) => _calculateBMI(),
                    ),
                    const SizedBox(height: 20),
                    _bmiCard(),
                    const SizedBox(height: 25),
                    _title("ضغط الدم"),
                    _inputField(
                      pressureController,
                      "مثال: 120/80",
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 25),
                    _title("معدل النبض"),
                    _inputField(heartController, "مثال: 80"),
                    const SizedBox(height: 25),
                    _title("مستوى السكر"),
                    _inputField(sugarController, "مثال: 100"),
                    const SizedBox(height: 35),
                    Center(
                      child: ElevatedButton(
                        onPressed: _saveData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeScreen.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "حفظ البيانات",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _buildNavBar(context),
    );
  }

  Future<void> _saveData() async {
    try {
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
        'height': heightController.text,
        'weight': weightController.text,
        'bmi': bmi,
        'age': ageController.text,
        'blood_type': bloodTypeController.text,
        'blood_pressure': pressureController.text,
        'heart_rate': heartController.text,
        'sugar_level': sugarController.text,
        'gender': gender,
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("تم حفظ البيانات بنجاح")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ أثناء الحفظ: $e")));
    }
  }

  Widget _title(String text) => Text(
    text,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  );

  Widget _inputField(
    TextEditingController controller,
    String hint, {
    Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.number,
  }) => Container(
    margin: const EdgeInsets.only(top: 8),
    padding: const EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(border: InputBorder.none, hintText: hint),
    ),
  );

  Widget _genderCard(IconData icon, String value, String label) {
    bool selected = gender == value;
    return GestureDetector(
      onTap: () => setState(() => gender = value),
      child: Container(
        width: 80,
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: selected
              ? HomeScreen.primaryBlue.withOpacity(0.15)
              : Colors.white,
          border: Border.all(
            color: selected ? HomeScreen.primaryBlue : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 35,
              color: selected ? HomeScreen.primaryBlue : Colors.grey,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: selected ? HomeScreen.primaryBlue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bmiCard() => Center(
    child: Container(
      width: double.infinity,
      height: 80,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 6)],
      ),
      child: Center(
        child: Text(
          "BMI: ${bmi.toStringAsFixed(1)}",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
      ),
    ),
  );

  Widget _buildNavBar(BuildContext context) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: HomeScreen.veryLightBlue.withOpacity(0.5),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            );
          },
          icon: const Icon(
            Icons.notifications_none,
            size: 30,
            color: Colors.grey,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
            );
          },
          child: const CircleAvatar(
            radius: 30,
            backgroundColor: HomeScreen.primaryBlue,
            child: Icon(Icons.home_filled, color: Colors.white, size: 30),
          ),
        ),
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            onPressed: () => Scaffold.of(ctx).openEndDrawer(),
          ),
        ),
      ],
    ),
  );
}
