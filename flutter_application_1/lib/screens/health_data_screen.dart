import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';

// =========================================================================
// 1. الألوان والثوابت
// =========================================================================

class AppColors {
  static const Color primaryBlue = Color(0xFF1E88E5); // الأزرق الرئيسي
  static const Color lightBlueCard = Color(
    0xFFC5E0F4,
  ); // أزرق فاتح للبطاقات (عمليات، مزمنة)
  static const Color midBlueCard = Color(
    0xFF81A2BC,
  ); // أزرق متوسط/داكن (حساسية، دخول)
  static const Color lightOrangeCard = Color(
    0xFFFFE0B2,
  ); // برتقالي فاتح (تاريخ عائلي)
  static const Color lightRedCard = Color(0xFFFF9480); // أحمر فاتح (مطاعيم)
  static const Color darkBlueCard = Color(0xFF1E88E5); // أزرق داكن (دخول)
  static const Color lightGrey = Color(0xFFF5F5F5); // رمادي فاتح للخلفية
  static const Color veryLightBlue = Color(0xFFE3F2FD); // أزرق فاتح جداً
}

// =========================================================================
// 2. شاشة تفاصيل السجل الصحي الجديدة (HealthRecordDetailScreen)
// =========================================================================

class HealthRecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> record;

  const HealthRecordDetailScreen({super.key, required this.record});

  // ويدجت شريط التنقل السفلي (مُعاد استخدامه)
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
          // 1. زر الإشعارات
          Builder(
            builder: (context) => IconButton(
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
          ),

          // 2. زر الرئيسية
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
          // 3. زر القائمة الجانبية
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

  // ويدجت شريط التطبيق العلوي (AppBar) - تعديل ليتطابق مع صفحة HealthDataScreen
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,

      // شعار Logo على اليمين
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
      leadingWidth: 70,

      // العنوان في الوسط
      title: Text(
        record['title']!,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: HomeScreen.primaryBlue,
        ),
        textAlign: TextAlign.center,
      ),
      centerTitle: true,

      // زر الرجوع Back على اليسار
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pop(context); // للرجوع للشاشة السابقة
          },
          icon: Image.asset('assets/images/back.png', width: 24, height: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ويدجت لصف تفاصيل منظم
  Widget _buildDetailRow(String label, String value, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              value,
              // ***** الحل لمشكلة النقطتين: تطبيق اتجاه RTL على حقل القيمة *****
              textDirection: TextDirection.rtl,
              // ***************************************************************
              style: TextStyle(
                fontSize: 16,
                color: labelColor,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: labelColor.withOpacity(0.8)),
            textAlign: TextAlign.right,
          ),
          const Icon(Icons.circle, size: 8, color: Colors.white70),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = record['color']!;
    final Map<String, String> details = record['details']!;
    final bool isDark =
        cardColor == AppColors.darkBlueCard ||
        cardColor == AppColors.midBlueCard;
    final Color detailTextColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      endDrawer: const AppDrawer(),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة ملخص الحالة الرئيسية
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record['title']!,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: detailTextColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'الفئة: ${record['category']!}',
                    style: TextStyle(
                      fontSize: 18,
                      color: detailTextColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const Divider(color: Colors.white70, height: 20),
                  // ***** التعديل المطلوب: حذف النقطتين من تسمية الحقل *****
                  _buildDetailRow(
                    'تاريخ التشخيص', // تم حذف ":"
                    details['date']!,
                    detailTextColor,
                  ),
                  // ❌ تم حذف حقل "الحالة الحالية:"
                ],
              ),
            ),
            const SizedBox(height: 20),

            // التفاصيل الموسعة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // ***** التعديل المطلوب: استبدال العنوان الطويل بـ 'الملاحظات' *****
                  const Text(
                    'ملاحظات',
                    // *************************************************************
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const Divider(color: AppColors.lightGrey, height: 30),
                  Text(
                    details['description']!,
                    style: const TextStyle(fontSize: 16, height: 1.8),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'تم تحديث السجل بواسطة الطبيب محمد في 14/11/2025.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }
}
// =========================================================================
// 3. شاشة السجل الصحي الرئيسية (HealthDataScreen) - مُحدثة
// =========================================================================

class HealthDataScreen extends StatelessWidget {
  const HealthDataScreen({super.key});

  // تم تحديث قائمة السجلات لإزالة حقل 'status'
  final List<Map<String, dynamic>> _healthRecords = const [
    {
      'title': 'عملية الزائدة الدودية',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'العمليات الجراحية',
      'color': AppColors.lightBlueCard,
      'details': {
        'date': 'أُجريت العملية في 20 مارس 2018',
        'description':
            'عملية جراحية لإزالة الزائدة الدودية في مستشفى الملك فيصل التخصصي. فترة النقاهة كانت أسبوعين. لم تسجل أي مضاعفات بعد العملية.',
        // 'status': 'تم الشفاء بالكامل', // تم حذفه
      },
    },
    {
      'title': 'السكري',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'الأمراض المزمنة',
      'color': AppColors.lightBlueCard,
      'details': {
        'date': 'تم التشخيص في 15 أكتوبر 2020',
        'description':
            'مرض السكري من النوع الثاني. يتم التحكم فيه عن طريق النظام الغذائي والدواء (Metformin 500mg مرتين يوميًا). آخر قراءة A1C كانت 6.5%. المتابعة مع الدكتور أحمد علي كل 6 أشهر.',
        // 'status': 'مسيطر عليه', // تم حذفه
      },
    },
    {
      'title': 'السكري (الأب)',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'التاريخ العائلي',
      'color': AppColors.lightOrangeCard,
      'details': {
        'date': 'تشخيص الوالد في عام 2005',
        'description':
            'إصابة الوالد بمرض السكري من النوع الثاني، مما يزيد من احتمالية الإصابة. يجب المراقبة الدورية لسكر الدم.',
        // 'status': 'خطر عائلي', // تم حذفه
      },
    },
    {
      'title': 'غذاء الخس',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'الحساسية',
      'color': AppColors.midBlueCard,
      'details': {
        'date': 'اكتشفت في يناير 2023',
        'description':
            'حساسية خفيفة من الخس (تلامس الفم). تسبب حكة خفيفة في اللسان. يجب تجنبه.',
        // 'status': 'نشطة', // تم حذفه
      },
    },
    {
      'title': 'تطعيم الكزاز',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'المطاعيم',
      'color': AppColors.lightRedCard,
      'details': {
        'date': 'آخر جرعة: 01 مارس 2022',
        'description':
            'تطعيم الكزاز والتيتانوس (Tdap). صالح لمدة 10 سنوات. التذكير القادم في مارس 2032.',
        // 'status': 'صالح', // تم حذفه
      },
    },
    {
      'title': 'دخول بسبب سكر',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'الدخول للمستشفى',
      'color': AppColors.darkBlueCard,
      'details': {
        'date': 'تاريخ الدخول: 10/11/2024',
        'description':
            'دخول طارئ بسبب انخفاض حاد في سكر الدم (Hypoglycemia). تم تعديل جرعة الإنسولين والخروج في اليوم التالي.',
        // 'status': 'تم الخروج', // تم حذفه
      },
    },
    {
      'title': 'الإنفلونزا',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'المطاعيم',
      'color': AppColors.lightRedCard,
      'details': {
        'date': 'آخر جرعة: أكتوبر 2024',
        'description':
            'التطعيم السنوي ضد الإنفلونزا الموسمية. يجب أخذه سنوياً في بداية الخريف.',
        // 'status': 'ساري المفعول', // تم حذفه
      },
    },
    {
      'title': 'أمراض القلب (الجد)',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'التاريخ العائلي',
      'color': AppColors.lightOrangeCard,
      'details': {
        'date': 'تشخيص الجد في عام 1990',
        'description':
            'إصابة الجد بأمراض الشرايين التاجية. سجل عائلي لأمراض القلب، ينصح بفحص الدهون والضغط بشكل دوري.',
        // 'status': 'خطر عائلي', // تم حذفه
      },
    },
    {
      'title': 'حساسية البنسلين',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'الحساسية',
      'color': AppColors.midBlueCard,
      'details': {
        'date': 'اكتشفت في مرحلة الطفولة',
        'description':
            'حساسية شديدة من دواء البنسلين. يجب إبلاغ الطاقم الطبي في جميع المراجعات. يتم استخدام مضادات حيوية بديلة.',
        // 'status': 'نشطة (مفعلة)', // تم حذفه
      },
    },
    {
      'title': 'عملية المرارة',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'العمليات الجراحية',
      'color': AppColors.lightBlueCard,
      'details': {
        'date': 'أُجريت في 10 أبريل 2021',
        'description':
            'عملية استئصال المرارة بالمنظار. تعافى المريض بالكامل، لا يوجد نظام غذائي خاص مطلوب حالياً.',
        // 'status': 'تم الشفاء بالكامل', // تم حذفه
      },
    },
    {
      'title': 'ضغط الدم',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'الأمراض المزمنة',
      'color': AppColors.lightBlueCard,
      'details': {
        'date': 'تم التشخيص في 05 مارس 2023',
        'description':
            'ارتفاع ضغط الدم الخفيف (Hypertension). يتم التحكم فيه بواسطة دواء Lisinopril 10mg يوميًا. يُنصح بمتابعة الضغط يومياً.',
        // 'status': 'مسيطر عليه', // تم حذفه
      },
    },
    {
      'title': 'الضغط الدم (الأم)',
      'subtitle': 'انقر لقراءة المزيد',
      'category': 'التاريخ العائلي',
      'color': AppColors.lightOrangeCard,
      'details': {
        'date': 'تشخيص الوالدة في عام 2010',
        'description':
            'إصابة الوالدة بارتفاع ضغط الدم. سجل عائلي للضغط، ينصح بفحوصات منتظمة.',
        // 'status': 'خطر عائلي', // تم حذفه
      },
    },
  ];

  // ويدجت لعرض البطاقة الفردية - تم تحديث منطق onTap للربط بشاشة التفاصيل
  Widget _buildHealthRecordCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String category,
    required Color color,
    required Map<String, dynamic> recordData, // تم تغيير نوع البيانات
  }) {
    // تحديد لون النص الأساسي بناءً على لون الخلفية (إذا كانت غامقة، يكون النص أبيض)
    final bool isDark =
        color == AppColors.darkBlueCard || color == AppColors.midBlueCard;
    final Color titleColor = isDark ? Colors.white : Colors.black87;
    final Color subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return InkWell(
      onTap: () {
        // يتم التوجيه إلى شاشة التفاصيل الجديدة مع تمرير كامل بيانات السجل
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HealthRecordDetailScreen(record: recordData),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9), // لون الخلفية للبطاقة
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // العنوان الرئيسي
            Text(
              title,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
            ),

            // رابط القراءة
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12, color: subtitleColor),
            ),

            const SizedBox(height: 8),

            // الفئة
            Text(
              category,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت لأزرار التبويبات الثلاثة في أعلى الشاشة (حساب شخصي، محمد، أحمد)
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

  // زر تبويب فردي
  Widget _buildTabButton(String title, {bool isSelected = false}) {
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
              color: isSelected ? HomeScreen.primaryBlue : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? HomeScreen.primaryBlue : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // ويدجت شريط البحث
  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightGrey,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const TextField(
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن القسم الذي تريده',
            hintStyle: TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
            prefixIcon: Icon(Icons.search, color: HomeScreen.primaryBlue),
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            border: InputBorder.none,
            isDense: true,
          ),
          // ***** إضافة textDirection هنا (لمنع أي مشاكل محتملة في البحث) *****
          textDirection: TextDirection.rtl,
          // *****************************************************************
        ),
      ),
    );
  }

  // ويدجت شريط التنقل السفلي (كما كان)
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
          // 1. زر الإشعارات
          Builder(
            builder: (context) => IconButton(
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
          ),

          // 2. زر الرئيسية
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
          // 3. زر القائمة الجانبية
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
    // ملاحظة: تم استبدال استخدام Image.asset برموز Icons لأن الملفات الخارجية غير مدعومة مباشرة هنا.
    // يجب استبدال Icons.medical_services بالشعار الفعلي عند التشغيل.
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

        // العنوان في المنتصف
        title: const Text(
          'السجل الصحي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
        centerTitle: true,

        // زر الرجوع (سهم لليسار) - يرجع للصفحة الرئيسية
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

                  // 3. شبكة البطاقات
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _healthRecords.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 3 بطاقات في كل صف
                            childAspectRatio:
                                0.75, // نسبة العرض إلى الارتفاع للبطاقة
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final record = _healthRecords[index];
                        return _buildHealthRecordCard(
                          context: context,
                          title: record['title']!,
                          subtitle: record['subtitle']!,
                          category: record['category']!,
                          color: record['color']!,
                          recordData: record, // تمرير كامل بيانات السجل
                        );
                      },
                    ),
                  ),

                  // 4. أزرار التحاليل والأدوية في الأسفل (تم حذفها من هنا لتجنب التكرار في التصميم)
                  const SizedBox(height: 10), // مسافة قبل شريط التنقل السفلي
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

// يمكن استخدام هذا الكلاس كنقطة بداية للتطبيق
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HealthDataScreen(),
      locale: Locale('ar'),
      supportedLocales: [Locale('ar')],
      localizationsDelegates: [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
    );
  }
}
