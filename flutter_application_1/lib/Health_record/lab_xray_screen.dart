import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/health_record_screen.dart';
// تأكد من تحديث المسارات إذا لزم الأمر
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';

// ملاحظة: افترضنا أن فئة HomeScreen موجودة لتوفير الألوان

class AddLabXrayScreen extends StatefulWidget {
  const AddLabXrayScreen({super.key});

  @override
  State<AddLabXrayScreen> createState() => _AddLabXrayScreenState();
}

class _AddLabXrayScreenState extends State<AddLabXrayScreen> {
  // 1. تعريف قائمة التحاليل
  final List<String> labOptions = [
    'صورة الدم الكاملة (CBC)',
    'فيتامين د (Vitamin D)',
    'الغدة الدرقية (TSH)',
    'السكر التراكمي / HbA1c',
    'وظائف الكبد (LFTS)',
    'وظائف الكلى (Creatinine, BUN)',
    'الدهون',
    'تحليل البول الروتيني',
    'تحليل البروتين أو السكر في البول',
    'الحمل (HCG)',
    'هرمونات',
    'أخرى',
  ];

  // 2. متغيرات حالة الشاشة
  late Map<String, bool> selectedLabs;
  bool isOtherSelected = false;

  final TextEditingController _otherLabController = TextEditingController();

  DateTime? _selectedDate;
  final TextEditingController _notesController = TextEditingController();

  // ... (initState و dispose لا تغيير)

  @override
  void initState() {
    super.initState();
    selectedLabs = {for (var option in labOptions) option: false};
  }

  @override
  void dispose() {
    _otherLabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // 3. دالة اختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: HomeScreen.primaryBlue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // 4. بناء الشريط العلوي (AppBar)
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,

      leading: Padding(
        padding: const EdgeInsets.only(right: 10.0),
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

      title: const Text(
        'التحاليل الطبية أو الأشعة',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: HomeScreen.primaryBlue,
        ),
        textAlign: TextAlign.center,
      ),
      centerTitle: true,

      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HealthRecordScreen(),
              ),
              (route) => false,
            );
          },
          icon: Image.asset('assets/images/back.png', width: 24, height: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // 5. بناء شريط التنقل السفلي (BottomNavigationBar)
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

  // 6. بناء مربع اختيار التحاليل (Checkboxes) - باستخدام ExpansionTile
  Widget _buildLabOptionsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.only(right: 15, left: 15),
            title: const Text(
              'اختر التحاليل الطبية أو الأشعة',
              style: TextStyle(fontSize: 18, color: HomeScreen.primaryBlue),
            ),
            collapsedIconColor: HomeScreen.primaryBlue,
            iconColor: HomeScreen.primaryBlue,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: labOptions.map((option) {
                    final isOther = option == 'أخرى';
                    return Column(
                      children: [
                        RadioListTile<String>(
                          title: Text(
                            option,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: isOther
                                  ? HomeScreen.primaryBlue
                                  : Colors.black,
                              fontWeight: isOther
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          value: option,
                          groupValue: labOptions.firstWhere(
                            (key) => selectedLabs[key] == true,
                            orElse: () => '',
                          ),
                          onChanged: (val) {
                            setState(() {
                              // مسح كل الخيارات الأخرى
                              selectedLabs.updateAll((key, value) => false);
                              selectedLabs[val!] = true;
                              isOtherSelected = val == 'أخرى';
                              if (!isOtherSelected) _otherLabController.clear();
                            });
                          },
                          activeColor: HomeScreen.primaryBlue,
                          controlAffinity: ListTileControlAffinity.trailing,
                          contentPadding: EdgeInsets.zero,
                        ),
                        if (isOtherSelected && isOther)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 8.0,
                              right: 15,
                              left: 15,
                            ),
                            child: TextField(
                              controller: _otherLabController,
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                hintText: 'اكتب التحاليل الأخرى',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: HomeScreen.primaryBlue,
                                    width: 2,
                                  ),
                                ),
                                fillColor: Colors.grey.shade50,
                                filled: true,
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // 7. بناء حاوية رفع ملف / صورة (اختياري) - الأيقونة يمين والنص يبدأ بعدها
  Widget _buildUploadContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // الأيقونة أولاً
          const Icon(Icons.upload_file, size: 24, color: Colors.grey),
          const SizedBox(width: 10),
          // النص ثانياً
          const Text(
            'رفع ملف / صورة (اختياري)',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            // **لضمان أن النص يبدأ من اليمين**
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  // 8. دالة Build الرئيسية
  @override
  Widget build(BuildContext context) {
    String dateText = _selectedDate == null
        ? 'اليوم / الشهر / السنة'
        : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: _buildAppBar(context),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. خيارات التحاليل (قابلة للطي)
              _buildLabOptionsCard(),
              const SizedBox(height: 30),

              // 2. تاريخ التحليل/الأشعة
              const Text(
                'تاريخ الفحص',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // الأيقونة أولاً
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      // النص ثانياً
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                        // **لضمان أن النص يبدأ من اليمين**
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),

              // 3. رفع ملف / صورة (اختياري)
              const SizedBox(height: 30),
              const Text(
                'رفع ملف / صورة (اختياري)',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              // استخدام الحاوية المعدلة
              _buildUploadContainer(),

              // 4. الملاحظات
              const SizedBox(height: 30),
              const Text(
                'الملاحظات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                textDirection: TextDirection.rtl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'أضف أي ملاحظات إضافية هنا...',
                  hintTextDirection: TextDirection.rtl,
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              // 5. زر الحفظ
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم حفظ بيانات التحاليل/الأشعة بنجاح.',
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeScreen.primaryBlue,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'حفظ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
