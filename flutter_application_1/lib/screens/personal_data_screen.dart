import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
// يجب تعديل هذا المسار ليتناسب مع موقع ملفك home_screen.dart
import '../home_screen/home_screen.dart';
// هذا هو المسار المطلوب لشاشة الإشعارات
import '../home_screen/notifications_screen.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  String? _selectedEducationLevel = 'جامعي';
  String? _selectedSocialStatus = 'متزوج';
  String? _selectedJobType = 'موظف حكومي';

  // قائمة خيارات وهمية
  final List<String> _educationLevels = [
    'ابتدائي',
    'إعدادي',
    'ثانوي',
    'جامعي',
    'دراسات عليا',
  ];
  final List<String> _socialStatuses = ['أعزب', 'متزوج', 'مطلق', 'أرمل'];
  final List<String> _jobTypes = [
    'موظف حكومي',
    'قطاع خاص',
    'خاص/حر',
    'لا يعمل',
  ];

  // 🔹 دالة مساعدة لفتح منتقي التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: HomeScreen.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      debugPrint(
        'تاريخ الميلاد المختار: ${picked.toLocal().toString().split(' ')[0]}',
      );
      // يمكنك تحديث حالة المتغير الذي يحمل تاريخ الميلاد هنا إذا لزم الأمر
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ربط AppDrawer بالـ Scaffold
      endDrawer: const AppDrawer(),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,

        // زر الشعار (Logo) في اليمين (Leading)
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
          'البيانات الشخصية',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,

        // زر العودة (Back Button) في اليسار (Actions)
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

      // محتوى الصفحة
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // حقل الاسم الكامل (الآن قابل للتعديل)
                    _buildTextField(
                      label: 'الاسم الكامل',
                      initialValue: 'محمد أحمد محمد السعيد',
                    ),
                    // حقل البريد الإلكتروني (الآن قابل للتعديل)
                    _buildTextField(
                      label: 'البريد الإلكتروني',
                      initialValue: 'example@example.com',
                    ),
                    // حقل رقم الجوال (الآن قابل للتعديل)
                    _buildTextField(
                      label: 'رقم الجوال',
                      initialValue: '00970590000000',
                    ),

                    // حقل تاريخ الميلاد
                    _buildDateTextField(
                      label: 'تاريخ الميلاد',
                      hint: 'اليوم / التاريخ / السنة',
                    ),

                    const SizedBox(height: 20),

                    // حقل المستوى التعليمي (Dropdown) - ⭐️ الآن قابل للاختيار
                    _buildDropdownField(
                      label: 'المستوى التعليمي',
                      value: _selectedEducationLevel,
                      items: _educationLevels,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedEducationLevel = newValue;
                        });
                      },
                      // isReadOnly: false, // القيمة الافتراضية هي false في تعريف الدالة الآن
                    ),

                    // حقل الحالة الاجتماعية (Dropdown) - ⭐️ الآن قابل للاختيار
                    _buildDropdownField(
                      label: 'الحالة الاجتماعية',
                      value: _selectedSocialStatus,
                      items: _socialStatuses,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSocialStatus = newValue;
                        });
                      },
                      // isReadOnly: false,
                    ),

                    // حقل طبيعة العمل (Dropdown) - ⭐️ الآن قابل للاختيار
                    _buildDropdownField(
                      label: 'طبيعة العمل',
                      value: _selectedJobType,
                      items: _jobTypes,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedJobType = newValue;
                        });
                      },
                      // isReadOnly: false,
                    ),

                    const SizedBox(height: 30),

                    // زر حفظ
                    ElevatedButton(
                      onPressed: () {
                        // TODO: تنفيذ منطق الحفظ هنا
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('تم حفظ البيانات الشخصية!'),
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

            // شريط التنقل السفلي المحدث
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  // 🔹 ويدجت لحقل الإدخال العادي - readOnly: false افتراضياً (لتمكين التعديل)
  Widget _buildTextField({
    required String label,
    required String initialValue,
    bool readOnly = false, // ⬅️ تم التعديل
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: readOnly ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: TextField(
              controller: TextEditingController(text: initialValue),
              readOnly: readOnly,
              textAlign: TextAlign.right,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                fontSize: 15,
                color: readOnly ? Colors.black54 : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 ويدجت لحقل التاريخ (لم يتغير)
  Widget _buildDateTextField({required String label, required String hint}) {
    // ... (الكود السابق) ...
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
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
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.grey,
                    size: 20,
                  ),
                  Expanded(
                    child: Text(
                      hint,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 ويدجت لحقل الاختيار المنسدل (Dropdown) - isReadOnly: false افتراضياً (لتمكين الاختيار)
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isReadOnly = false, // ⬅️ تم التعديل
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration: BoxDecoration(
              // تم تعديل لون الخلفية ليتناسب مع isReadOnly
              color: isReadOnly ? Colors.white : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: HomeScreen.primaryBlue,
                  size: 28,
                ),
                hint: const Text(
                  'اختر',
                  textAlign: TextAlign.right,
                  style: TextStyle(color: Colors.grey),
                ),
                dropdownColor: Colors.white,
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  );
                }).toList(),
                // onChanged سيتم تنفيذه فقط إذا لم يكن isReadOnly صحيحًا
                onChanged: isReadOnly ? null : onChanged,
                style: const TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 ويدجت شريط التنقل السفلي (Bottom Navigation Bar)
  Widget _buildBottomNavigationBar() {
    // ... (الكود السابق) ...
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
