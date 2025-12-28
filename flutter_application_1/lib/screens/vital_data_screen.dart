import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/app_drawer.dart';
import '../home_screen/notifications_screen.dart';

class VitalDataScreen extends StatefulWidget {
  const VitalDataScreen({super.key});

  @override
  State<VitalDataScreen> createState() => _VitalDataScreenState();
}

class _VitalDataScreenState extends State<VitalDataScreen> {
  String _selectedGender = 'male'; // 'male' or 'female'

  // القيم الحالية المعروضة
  double _height = 170;
  double _weight = 70;
  double _bmi = 0.0;

  bool _isLoading = true;
  User? _currentUser;
  String? _lastProfileId;

  // قيم الإدخال للسجلات الحيوية
  final TextEditingController _bloodPressureController =
      TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _sugarLevelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _calculateBMI();
    _fetchVitalData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for profile changes and refetch data
    final currentProfileId = context.watch<ProfileProvider>().selectedProfileId;
    if (currentProfileId != _lastProfileId) {
      _lastProfileId = currentProfileId;
      _fetchVitalData();
    }
  }

  Future<void> _fetchVitalData() async {
    try {
      _currentUser = FirebaseAuth.instance.currentUser;
      if (_currentUser == null) return;

      final profileProvider = context.read<ProfileProvider>();
      final selectedProfileId = profileProvider.selectedProfileId;
      final isSharedProfile = profileProvider.isSharedProfile;

      DocumentReference docRef;

      if (selectedProfileId == null) {
        docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
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
            .doc(_currentUser!.uid)
            .collection('dependents')
            .doc(selectedProfileId)
            .collection('health_profile')
            .doc('current');
      }

      final doc = await docRef.get();

      if (!doc.exists) {
        setState(() => _isLoading = false);
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        _selectedGender = data['gender'] ?? 'male';
        _height = double.tryParse(data['height']?.toString() ?? '') ?? 0;
        _weight = double.tryParse(data['weight']?.toString() ?? '') ?? 0;

        _bloodPressureController.text =
            data['blood_pressure']?.toString() ?? '';
        _heartRateController.text = data['heart_rate']?.toString() ?? '';
        _sugarLevelController.text = data['sugar_level']?.toString() ?? '';

        _calculateBMI();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching vitals: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطأ في تحميل البيانات: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _calculateBMI() {
    if (_height > 0) {
      double heightInMeters = _height / 100;
      setState(() {
        _bmi = _weight / (heightInMeters * heightInMeters);
      });
    }
  }

  Future<void> _saveVitalData() async {
    if (_currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      final profileProvider = context.read<ProfileProvider>();
      final selectedProfileId = profileProvider.selectedProfileId;
      final isSharedProfile = profileProvider.isSharedProfile;

      if (!profileProvider.hasPermission('vital_signs', 'write')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('عذراً، ليس لديك صلاحية لتعديل العلامات الحيوية'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      /// 🔹 نفس المرجع المستخدم في القراءة
      DocumentReference docRef;

      if (selectedProfileId == null) {
        // المستخدم الأساسي
        docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('health_profile')
            .doc('current');
      } else if (isSharedProfile) {
        // حساب مشترك
        docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(selectedProfileId)
            .collection('health_profile')
            .doc('current');
      } else {
        // مرافق
        docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('dependents')
            .doc(selectedProfileId)
            .collection('health_profile')
            .doc('current');
      }

      await docRef.set({
        'gender': _selectedGender,
        'height': _height,
        'weight': _weight,
        'bmi': double.parse(_bmi.toStringAsFixed(1)),
        'blood_pressure': _bloodPressureController.text.trim(),
        'heart_rate': _heartRateController.text.trim(),
        'sugar_level': _sugarLevelController.text.trim(),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ البيانات الحيوية بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Save error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ أثناء الحفظ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  //
  void _showEditDialog(
    String title,
    double currentValue,
    String unit,
    Function(double) onSave,
  ) {
    TextEditingController controller = TextEditingController(
      text: currentValue.toInt().toString(),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل $title', textAlign: TextAlign.right),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.right,
            decoration: InputDecoration(suffixText: unit),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                double? newValue = double.tryParse(controller.text);
                if (newValue != null && newValue > 0) {
                  onSave(newValue);
                  Navigator.pop(context);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _sugarLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ⭐️ إضافة القائمة الجانبية (endDrawer)
      endDrawer: const AppDrawer(),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,

        // ⭐️ زر الشعار (Logo) في اليمين (Leading)
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: GestureDetector(
            onTap: () {
              // الانتقال إلى الشاشة الرئيسية عند الضغط على الشعار
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png', // تأكد من وجود صورة الشعار في هذا المسار
                width: 40,
                height: 40,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        title: const Text(
          'البيانات الحيوية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,

        // ⭐️ زر العودة (Back Button) في اليسار (Actions)
        actions: [
          IconButton(
            onPressed: () {
              // العودة إلى الشاشة السابقة أو الرئيسية
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Image.asset(
              'assets/images/back.png', // افترض وجود هذه الصورة لزر العودة
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      // محتوى الصفحة
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // 1. شريط تبديل المستخدمين (المرافقين)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildUserSelectionTabs(),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isLoading)
                      const Center(child: LinearProgressIndicator())
                    else ...[
                      // 2. الجنس والطول والوزن ومؤشر كتلة الجسم
                      _buildTopVitalsGrid(),
                      const SizedBox(height: 30),

                      // 3. ضغط الدم
                      _buildVitalInputField(
                        label: 'ضغط الدم',
                        controller: _bloodPressureController,
                        keyboardType: TextInputType.text,
                        hint: 'مثال: 120/80',
                      ),
                      const SizedBox(height: 20),

                      // 4. معدل النبض
                      _buildVitalInputField(
                        label: 'معدل النبض',
                        controller: _heartRateController,
                        keyboardType: TextInputType.number,
                        hint: 'مثال: 75',
                      ),
                      const SizedBox(height: 20),

                      // 5. مستوى السكر
                      _buildVitalInputField(
                        label: 'مستوى السكر',
                        controller: _sugarLevelController,
                        keyboardType: TextInputType.number,
                        hint: 'مثال: 100',
                      ),
                      const SizedBox(height: 50),

                      // 6. زر حفظ
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveVitalData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: HomeScreen.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'حفظ',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(height: 20),
                    ], // End of else block
                  ],
                ),
              ),
            ),

            // 7. شريط التنقل السفلي
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // Profile tabs - now using SharedProfileTabs widget
  Widget _buildUserSelectionTabs() {
    return const SharedProfileTabs(showTitle: false);
  }

  // 🔹 ويدجت القسم العلوي (الجنس، الطول، الوزن، BMI) - ⭐️ تم التعديل هنا
  Widget _buildTopVitalsGrid() {
    // جلب اسم المستخدم الحالي (لم يعد يُستخدم في الـ Row الأول)
    // final String currentUserName = _users[_selectedUserIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          // ⭐️ تم تغيير المحاذاة إلى توسيط (center)
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // ⭐️ تم حذف عرض اسم المستخدم (Text(currentUserName, ...))

            // اختيار الجنس للذكر
            _buildGenderIcon(icon: Icons.male, gender: 'male'),
            const SizedBox(width: 10),

            // اختيار الجنس للأنثى
            _buildGenderIcon(icon: Icons.female, gender: 'female'),
          ],
        ),
        const SizedBox(height: 15),
        // الطول، الوزن، BMI
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                _showEditDialog('الطول', _height, 'سم', (newValue) {
                  setState(() {
                    _height = newValue;
                    _calculateBMI();
                  });
                });
              },
              child: _buildVitalStatCard(
                title: 'الطول',
                value: '${_height.toInt()}',
                unit: 'سم',
              ),
            ),
            GestureDetector(
              onTap: () {
                _showEditDialog('الوزن', _weight, 'كجم', (newValue) {
                  setState(() {
                    _weight = newValue;
                    _calculateBMI();
                  });
                });
              },
              child: _buildVitalStatCard(
                title: 'الوزن',
                value: '${_weight.toInt()}',
                unit: 'كجم',
              ),
            ),
            _buildVitalStatCard(
              title: 'BMI',
              value: _bmi.toStringAsFixed(1),
              unit: '',
            ),
          ],
        ),
      ],
    );
  }

  // 🔸 ويدجت أيقونة اختيار الجنس - (لم يتغير)
  Widget _buildGenderIcon({required IconData icon, required String gender}) {
    final isSelected = _selectedGender == gender;
    final String label = gender == 'male' ? 'ذكر' : 'أنثى';

    // ⭐️ تعريف الألوان بناءً على الجنس
    final Color selectedColor = gender == 'male'
        ? HomeScreen
              .primaryBlue // أزرق للذكر
        : Colors.pink.shade300; // زهري/وردي للأنثى

    final Color selectedBackgroundColor = selectedColor.withOpacity(0.1);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = gender;
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              // استخدام اللون الخاص بالجنس كخلفية عند الاختيار
              color: isSelected ? selectedBackgroundColor : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                // استخدام اللون الخاص بالجنس كحدود عند الاختيار
                color: isSelected ? selectedColor : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 40,
              // استخدام اللون الخاص بالجنس كأيقونة عند الاختيار
              color: isSelected ? selectedColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? selectedColor : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // 🔸 ويدجت بطاقة الإحصائية الحيوية (الطول/الوزن/BMI)
  Widget _buildVitalStatCard({
    required String title,
    required String value,
    required String unit,
  }) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 5),
            Text.rich(
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: HomeScreen.primaryBlue,
                ),
                children: [
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: ' $unit',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 ويدجت حقل إدخال القيمة الحيوية - (لم يتغير)
  Widget _buildVitalInputField({
    required String label,
    required TextEditingController controller,
    required TextInputType keyboardType,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: HomeScreen.primaryBlue,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 🔹 ويدجت شريط التنقل السفلي (Bottom Navigation Bar) - (لم يتغير)
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
          // 1. القائمة الجانبية (غير نشطة) - (اليمين)
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                // فتح القائمة الجانبية المربوطة بـ endDrawer
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
          // 2. الصفحة الرئيسية (نشطة - مختارة) - (الوسط)
          InkWell(
            onTap: () {
              // الانتقال إلى شاشة HomeScreen وإزالة الشاشات السابقة
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
                color: HomeScreen.primaryBlue, // اللون الأزرق يعني أنه نشط
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          // 3. الإشعارات (غير نشطة) - (اليسار)
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
