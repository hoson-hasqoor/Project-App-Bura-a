import 'package:flutter/material.dart';

import '../home_screen/home_screen.dart'; // لـ HomeScreen والألوان
import '../home_screen/app_drawer.dart'; // لـ AppDrawer
import '../home_screen/notifications_screen.dart'; // لـ NotificationsScreen

class AppColors {
  static const Color primaryBlue = Color(0xFF004AAD); // الأزرق الرئيسي
  static const Color lightBlueCard = Color(0xFFC5E0F4); // أزرق فاتح للبطاقات
  static const Color midBlueCard = Color(0xFF81A2BC); // أزرق متوسط/داكن
  static const Color lightOrangeCard = Color(0xFFFFE0B2); // برتقالي فاتح
  static const Color lightRedCard = Color(0xFFFF9480); // أحمر فاتح
  static const Color veryLightBlue = Color(0xFFE3F2FD);
  static const Color lightGrey = Color(
    0xFFF5F5F5,
  ); // لون إضافي للخلفية/شريط التنقل السفلي
}

class MedicationRecord extends StatelessWidget {
  const MedicationRecord({super.key});

  // قائمة وهمية للأدوية (للمحاكاة)
  final List<Map<String, dynamic>> _medicationsList = const [
    {
      'name': 'Metformin',
      'purpose': 'دواء السكري',
      'color': AppColors.lightBlueCard,
    },
    {
      'name': 'Amlodipine',
      'purpose': 'دواء لارتفاع ضغط الدم',
      'color': AppColors.midBlueCard,
    },
    {
      'name': 'Paracetamol',
      'purpose': 'دواء الصداع',
      'color': AppColors.lightOrangeCard,
    },
    {
      'name': 'Ibuprofen',
      'purpose': 'دواء المفاصل',
      'color': AppColors.lightRedCard,
    },
    {
      'name': 'Amoxicillin',
      'purpose': 'دواء التهاب الحلق',
      'color': AppColors.lightBlueCard,
    },
    {
      'name': 'Atorvastatin',
      'purpose': 'ارتفاع الكولسترول',
      'color': AppColors.midBlueCard,
    },
  ];

  // ويدجت لعرض زر تبويب الحسابات
  Widget _buildTabButton(String title, {bool isSelected = false}) {
    final Color primaryColor = AppColors.primaryBlue;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () {
          // منطق تغيير الحساب
        },
        style: TextButton.styleFrom(
          backgroundColor: isSelected
              ? AppColors.lightBlueCard.withOpacity(0.5)
              : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? primaryColor : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? primaryColor : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ويدجت لأزرار التبويبات في أعلى الشاشة
  Widget _buildAccountTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true, // للبدء من اليمين
        child: Row(
          children: [
            _buildTabButton('حسابك الشخصي', isSelected: true),
            _buildTabButton('احمد سامي العلي'),
            _buildTabButton('محمد سامي العلي'),
          ],
        ),
      ),
    );
  }

  // ويدجت شريط البحث
  Widget _buildSearchBar(BuildContext context) {
    // نفترض أن HomeScreen.primaryBlue هو نفس AppColors.primaryBlue
    final Color primaryColor = AppColors.primaryBlue;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن الأدوية التي تريدها',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: primaryColor),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ),
    );
  }

  // ويدجت لبلاطة الدواء الفردية (كما في الصورة)
  Widget _buildMedicationTile({
    required String name,
    required String purpose,
    required Color color,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // منطق عرض تفاصيل الدواء
        },
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            textDirection: TextDirection.rtl, // لضبط الترتيب من اليمين لليسار
            children: [
              // أيقونة الوثيقة/المرفق على اليسار
              Icon(Icons.attachment, color: color, size: 24),
              const SizedBox(width: 10),

              // النص الرئيسي للدواء
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // اسم الدواء (باللاتيني/الإنجليزي)
                    Text(
                      name,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // لون أسود واضح
                      ),
                    ),
                    const SizedBox(height: 4),
                    // الغرض من الدواء (بالعربية)
                    Text(
                      purpose,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت شريط التنقل السفلي (كما كان)
  Widget _buildBottomNavigationBar(BuildContext context) {
    // نفترض أن HomeScreen.primaryBlue و HomeScreen.veryLightBlue هما AppColors.primaryBlue و AppColors.veryLightBlue
    final Color primaryColor = AppColors.primaryBlue;
    final Color veryLightBlue = AppColors.veryLightBlue;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: veryLightBlue.withOpacity(0.5),
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
          // 1. زر الإشعارات
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

          // 2. زر الرئيسية (Home)
          InkWell(
            onTap: () {
              // يفترض أن HomeScreen موجود في مسار home_screen.dart
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
                color: primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.home_filled,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          // 3. زر القائمة (Menu)
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // نفترض أن HomeScreen.primaryBlue هو نفس AppColors.primaryBlue
    final Color primaryColor = AppColors.primaryBlue;

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(), // يفترض استيراد AppDrawer من مساره
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,

        // العنوان في المنتصف
        title: Text(
          'سجل الأدوية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        centerTitle: true,
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
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: HomeScreen.veryLightBlue,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: HomeScreen.primaryBlue, width: 1),
                  ),
                  child: const Text(
                    'Logo',
                    style: TextStyle(
                      fontSize: 10,
                      color: HomeScreen.primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // الأيقونات اليسرى: زر الإضافة
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

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. أزرار تبويبات الحسابات
                  _buildAccountTabs(),

                  // 2. شريط البحث
                  _buildSearchBar(context),

                  // 3. قسم الأدوية المسجلة ورابط عرض الكل
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      textDirection:
                          TextDirection.rtl, // لضبط الترتيب من اليمين لليسار
                      children: [
                        const Text(
                          'الأدوية المسجلة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // منطق عرض كل الأدوية
                          },
                          child: Text(
                            'عرض الكل',
                            style: TextStyle(
                              fontSize: 14,
                              color: primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. قائمة الأدوية
                  ..._medicationsList.map(
                    (medication) => _buildMedicationTile(
                      name: medication['name']!,
                      purpose: medication['purpose']!,
                      color: medication['color']!,
                      context: context,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          // شريط التنقل السفلي
          _buildBottomNavigationBar(context),
        ],
      ),
    );
  }
}
