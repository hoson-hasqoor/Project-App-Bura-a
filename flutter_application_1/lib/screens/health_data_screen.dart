import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
// For date formatting

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
        record['title'] ?? '',
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
    final Color cardColor = record['color'] ?? AppColors.lightBlueCard;
    final Map<String, dynamic> details = record['details'];
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
                    record['title'] ?? '',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: detailTextColor,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'الفئة: ${record['category'] ?? ''}',
                    style: TextStyle(
                      fontSize: 18,
                      color: detailTextColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const Divider(color: Colors.white70, height: 20),
                  // ***** التعديل المطلوب: حذف النقطتين من تسمية الحقل *****
                  _buildDetailRow(
                    'التاريخ', // تم حذف ":"
                    details['date'] ?? 'غير محدد',
                    detailTextColor,
                  ),
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
                    details['description'] ?? 'لا توجد تفاصيل إضافية',
                    style: const TextStyle(fontSize: 16, height: 1.8),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 10),
                  // const Text(
                  //   'تم تحديث السجل بواسطة الطبيب محمد في 14/11/2025.',
                  //   style: TextStyle(fontSize: 12, color: Colors.grey),
                  //   textAlign: TextAlign.right,
                  // ),
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
// 3. شاشة السجل الصحي الرئيسية (HealthDataScreen) - محدثة ببيانات حقيقية
// =========================================================================

class HealthDataScreen extends StatefulWidget {
  const HealthDataScreen({super.key});

  @override
  State<HealthDataScreen> createState() => _HealthDataScreenState();
}

class _HealthDataScreenState extends State<HealthDataScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = true;
  List<Map<String, dynamic>> _healthRecords = [];
  List<Map<String, dynamic>> _filteredRecords = [];
  String? _lastProfileId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    super.initState();
    _fetchHealthData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = List.from(_healthRecords);
      } else {
        _filteredRecords = _healthRecords.where((record) {
          final title = (record['title'] as String? ?? '').toLowerCase();
          final category = (record['category'] as String? ?? '').toLowerCase();
          return title.contains(query) || category.contains(query);
        }).toList();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for profile changes and refetch data
    final currentProfileId = context.watch<ProfileProvider>().selectedProfileId;
    if (currentProfileId != _lastProfileId) {
      _lastProfileId = currentProfileId;
      _fetchHealthData();
    }
  }

  Future<void> _fetchHealthData() async {
    setState(() => _isLoading = true);
    final user = _auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    // Get the selected profile from ProfileProvider
    final profileProvider = context.read<ProfileProvider>();
    final selectedProfileId = profileProvider.selectedProfileId;

    List<Map<String, dynamic>> loadedRecords = [];

    // Determine base path for queries
    DocumentReference baseRef;
    if (selectedProfileId == null) {
      // Main user
      baseRef = _firestore.collection('users').doc(user.uid);
    } else {
      // Dependent
      baseRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dependents')
          .doc(selectedProfileId);
    }

    try {
      // 1. Chronic Diseases
      final chronicSnapshot = await baseRef
          .collection('chronic_diseases')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in chronicSnapshot.docs) {
        final data = doc.data();
        loadedRecords.add({
          'title': data['disease_name'] ?? 'مرض مزمن',
          'subtitle': 'انقر للتفاصيل',
          'category': 'الأمراض المزمنة',
          'color': AppColors.lightBlueCard,
          'details': {
            'date': _formatDate(data['diagnosis_date']),
            'description': data['notes'] ?? '',
          },
          'timestamp': data['created_at'], // For sorting
        });
      }

      // 2. Allergies
      final allergiesSnapshot = await baseRef
          .collection('allergies')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in allergiesSnapshot.docs) {
        final data = doc.data();
        String desc = 'المادة المسببة: ${data['allergen'] ?? ''}\n';
        desc += 'الشدة: ${data['severity'] ?? ''}\n';
        desc += 'الأعراض: ${data['symptoms'] ?? ''}\n';
        desc += 'ملاحظات: ${data['notes'] ?? ''}';

        loadedRecords.add({
          'title': data['allergy_type'] ?? 'حساسية',
          'subtitle': 'انقر للتفاصيل',
          'category': 'الحساسية',
          'color': AppColors.midBlueCard,
          'details': {'date': _formatDate(data['date']), 'description': desc},
          'timestamp': data['created_at'],
        });
      }

      // 3. Family History
      final familySnapshot = await baseRef
          .collection('family_history')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in familySnapshot.docs) {
        final data = doc.data();
        loadedRecords.add({
          'title': 'تاريخ عائلي (${data['relative'] ?? ''})',
          'subtitle': 'انقر للتفاصيل',
          'category': 'التاريخ العائلي',
          'color': AppColors.lightOrangeCard,
          'details': {
            'date': _formatDate(data['diagnosis_date']),
            'description': data['notes'] ?? '',
          },
          'timestamp': data['created_at'],
        });
      }

      // 4. Surgeries
      final surgeriesSnapshot = await baseRef
          .collection('surgeries')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in surgeriesSnapshot.docs) {
        final data = doc.data();
        loadedRecords.add({
          'title': data['surgery_name'] ?? 'عملية جراحية',
          'subtitle': 'انقر للتفاصيل',
          'category': 'العمليات الجراحية',
          'color': AppColors.lightBlueCard,
          'details': {
            'date': _formatDate(data['surgery_date']),
            'description': data['notes'] ?? '',
          },
          'timestamp': data['created_at'],
        });
      }

      // 5. Hospital Stays
      final hospitalSnapshot = await baseRef
          .collection('hospital_stays')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in hospitalSnapshot.docs) {
        final data = doc.data();
        String desc = 'المدة: ${data['duration'] ?? ''}\n';
        desc += 'ملاحظات: ${data['notes'] ?? ''}';

        loadedRecords.add({
          'title': data['admission_reason'] ?? 'دخول مستشفى',
          'subtitle': 'انقر للتفاصيل',
          'category': 'الدخول للمستشفى',
          'color': AppColors.darkBlueCard,
          'details': {
            'date': _formatDate(data['admission_date']),
            'description': desc,
          },
          'timestamp': data['created_at'],
        });
      }

      // 6. Vaccines
      final vaccinesSnapshot = await baseRef
          .collection('vaccines')
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in vaccinesSnapshot.docs) {
        final data = doc.data();
        loadedRecords.add({
          'title': data['vaccine_name'] ?? 'تطعيم',
          'subtitle': 'انقر للتفاصيل',
          'category': 'المطاعيم',
          'color': AppColors.lightRedCard,
          'details': {
            'date': _formatDate(data['date']),
            'description': data['notes'] ?? '',
          },
          'timestamp': data['created_at'],
        });
      }

      // 7. Lab & X-ray - NOT IMPLEMENTED FULLY IN ORIGINAL SAVING (Was "lab_xray")
      final labSnapshot = await baseRef
          .collection('lab_xray') // Check collection name from step 208
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in labSnapshot.docs) {
        final data = doc.data();
        // lab_names is a list
        List<dynamic> labs = data['lab_names'] ?? [];
        String title = labs.isNotEmpty ? labs.join(', ') : 'تحاليل وأشعة';

        loadedRecords.add({
          'title': title,
          'subtitle': 'انقر للتفاصيل',
          'category': 'التحاليل والأشعة',
          'color': AppColors.midBlueCard,
          'details': {
            'date': _formatDate(data['date']),
            'description': data['notes'] ?? '',
          },
          'timestamp': data['created_at'],
        });
      }

      // 8. Medicines
      final medicinesSnapshot = await baseRef
          .collection('medicines')
          //.orderBy('created_at', descending: true) // Ensure indexes or remove order
          .get();

      for (var doc in medicinesSnapshot.docs) {
        final data = doc.data();
        String desc = 'الجرعة: ${data['dosage'] ?? ''}\n';
        desc += 'الغرض: ${data['purpose'] ?? ''}\n';
        desc += 'التكرار: ${data['frequency'] ?? ''}\n';
        desc += 'تاريخ البدء: ${_formatDate(data['start_date'])}\n';
        desc += 'تاريخ الانتهاء: ${_formatDate(data['end_date'])}\n';
        desc += 'ملاحظات: ${data['notes'] ?? ''}';

        loadedRecords.add({
          'title': data['medicine_name'] ?? 'دواء',
          'subtitle': 'انقر للتفاصيل',
          'category': 'الأدوية',
          'color': AppColors.lightBlueCard,
          'details': {
            'date': _formatDate(
              data['start_date'],
            ), // Display start date generally
            'description': desc,
          },
          // 'timestamp': data['created_at'], // Sometimes missing in fetch loops if not careful, assume it exists
        });
      }

      // Sort all records by date (if available) implies manual sort if timestamp mixed
      // loadedRecords.sort((a, b) {
      // dynamic tA = a['timestamp'];
      // dynamic tB = b['timestamp'];
      // if (tA is Timestamp && tB is Timestamp) {
      //   return tB.compareTo(tA);
      // }
      // return 0;
      // });
    } catch (e) {
      debugPrint("Error fetching health records: $e");
    } finally {
      if (mounted) {
        setState(() {
          _healthRecords = loadedRecords;
          _filteredRecords = loadedRecords; // Initialize filtered list
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(dynamic dateField) {
    if (dateField == null) return 'غير محدد';
    if (dateField is Timestamp) {
      DateTime date = dateField.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }
    return dateField.toString();
  }

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

  // Profile tabs - now using SharedProfileTabs widget
  Widget _buildAccountTabs() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: SharedProfileTabs(showTitle: false),
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
        child: TextField(
          controller: _searchController,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: 'ابحث عن القسم الذي تريده',
            hintStyle: TextStyle(color: Color.fromARGB(255, 158, 158, 158)),
            prefixIcon: Icon(Icons.search, color: HomeScreen.primaryBlue),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      _searchController.clear();
                      // trigger listener automatically
                    },
                  )
                : null,
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
                  // 3. شبكة البطاقات
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredRecords.isEmpty
                        ? const Center(
                            child: Text(
                              "لا توجد سجلات",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.85,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                ),
                            itemCount: _filteredRecords.length,
                            itemBuilder: (context, index) {
                              final record = _filteredRecords[index];
                              return _buildHealthRecordCard(
                                context: context,
                                title: record['title'] ?? '',
                                subtitle: record['subtitle'] ?? '',
                                category: record['category'] ?? '',
                                color:
                                    record['color'] ?? AppColors.lightBlueCard,
                                recordData: record,
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
        ],
      ),
      // bottomNavigationBar: _buildBottomNavigationBar(context), // Removing reusing bottom nav explicitly in main screen as it might not be needed or already handled by HomeScreen navigation flow, but keeping consistent with original if needed. Original code didn't use it in build? Wait, line 307 in original used it in DetailScreen, HealthDataScreen lines 700+ did not.
    );
  }
}
