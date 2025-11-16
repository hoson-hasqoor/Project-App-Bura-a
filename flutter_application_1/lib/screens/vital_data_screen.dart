import 'package:flutter/material.dart';
import '../home_screen/home_screen.dart';
// يجب التأكد من وجود ملفات AppDrawer و NotificationsScreen في المسار الصحيح
import '../home_screen/app_drawer.dart';
import '../home_screen/notifications_screen.dart';

class VitalDataScreen extends StatefulWidget {
  const VitalDataScreen({super.key});

  @override
  State<VitalDataScreen> createState() => _VitalDataScreenState();
}

class _VitalDataScreenState extends State<VitalDataScreen> {
  int _selectedUserIndex = 0;
  String _selectedGender = 'male'; // 'male' or 'female'

  final List<String> _users = [
    'حسابك الشخصي',
    'احمد سامي العلي',
    'محمد سامي العلي',
  ];

  // القيم الحالية المعروضة
  final double _height = 165;
  final double _weight = 72;
  final double _bmi = 26.5; // BMI = الوزن (كجم) / (الطول * الطول) (متر)

  // قيم الإدخال للسجلات الحيوية
  final TextEditingController _bloodPressureController = TextEditingController(
    text: '165/105',
  );
  final TextEditingController _heartRateController = TextEditingController(
    text: '105',
  );
  final TextEditingController _sugarLevelController = TextEditingController(
    text: '130',
  );

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
                      onPressed: () {
                        // TODO: تنفيذ منطق الحفظ هنا
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حفظ البيانات الحيوية!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HomeScreen.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'حفظ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
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

  // 🔹 ويدجت شريط تبديل المستخدمين (لم يتغير)
  Widget _buildUserSelectionTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true, // لتبدأ القائمة من اليمين
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: List.generate(_users.length, (index) {
          final isSelected = index == _selectedUserIndex;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedUserIndex = index;
                // TODO: جلب بيانات المستخدم الجديد
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
            _buildVitalStatCard(
              title: 'الطول',
              value: '${_height.toInt()}',
              unit: 'سم',
            ),
            _buildVitalStatCard(
              title: 'الوزن',
              value: '${_weight.toInt()}',
              unit: 'كجم',
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

  // 🔸 ويدجت بطاقة الإحصائية الحيوية (الطول/الوزن/BMI) - (لم يتغير)
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
