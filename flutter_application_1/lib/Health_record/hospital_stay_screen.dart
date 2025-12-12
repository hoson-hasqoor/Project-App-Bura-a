import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/app_drawer.dart';

class HospitalAdmissionScreen extends StatefulWidget {
  const HospitalAdmissionScreen({super.key});

  @override
  State<HospitalAdmissionScreen> createState() =>
      _HospitalAdmissionScreenState();
}

class _HospitalAdmissionScreenState extends State<HospitalAdmissionScreen> {
  final List<String> _admissionReasons = [
    'طوارئ / إسعاف',
    'عملية جراحية',
    'متابعة دورية / فحوصات',
    'علاج طويل المدى',
    'ولادة طبيعية أو قيصرية',
    'إقامة لمضاعفات مرض مزمن',
    'علاج مكثف / جلسات علاجية',
    'نقل دم أو علاج دموي',
    'فحوصات مختبرية أو تصوير',
    'بروتوكولات وقائية',
    'أخرى',
  ];

  String? _selectedReason;
  final TextEditingController _otherReasonController = TextEditingController();
  bool _isExpanded = false;

  DateTime? _selectedAdmissionDate;
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedAdmissionDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ar', 'EG'),
    );
    if (picked != null && picked != _selectedAdmissionDate) {
      setState(() {
        _selectedAdmissionDate = picked;
      });
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
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
        'دخول الى المستشفى',
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
          onPressed: () => Navigator.of(context).pop(),
          icon: Image.asset('assets/images/back.png', width: 24, height: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

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
                MaterialPageRoute(builder: (context) => HomeScreen()),
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
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionReasonCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 15),
            title: const Text(
              'اسباب الدخول الى المستشفى',
              style: TextStyle(fontSize: 18, color: HomeScreen.primaryBlue),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: HomeScreen.primaryBlue,
              size: 28,
            ),
            onExpansionChanged: (bool expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            children: _admissionReasons.map((reason) {
              final isOther = reason == 'أخرى';
              return Column(
                children: [
                  RadioListTile<String>(
                    title: Text(reason, textDirection: TextDirection.rtl),
                    value: reason,
                    groupValue: _selectedReason,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedReason = value;
                      });
                    },
                    activeColor: HomeScreen.primaryBlue,
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (isOther && _selectedReason == 'أخرى')
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      child: TextField(
                        controller: _otherReasonController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'اكتب الأسباب الأخرى',
                          fillColor: Colors.grey.shade50,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateText = _selectedAdmissionDate == null
        ? 'اليوم / الشهر / السنة'
        : '${_selectedAdmissionDate!.day.toString().padLeft(2, '0')}/${_selectedAdmissionDate!.month.toString().padLeft(2, '0')}/${_selectedAdmissionDate!.year}';

    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: _buildAppBar(context),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAdmissionReasonCard(),
              const SizedBox(height: 30),
              const Text(
                'تاريخ الدخول الى المستشفى',
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
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedAdmissionDate == null
                              ? Colors.grey.shade600
                              : Colors.black,
                        ),
                      ),
                      const Icon(Icons.calendar_today, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'مدة الإقامة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _durationController,
                textDirection: TextDirection.rtl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'حدد المدة التي اقمت بها في المستشفى',
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
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
                  fillColor: Colors.grey.shade100,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'تم حفظ بيانات الدخول إلى المستشفى بنجاح.',
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
