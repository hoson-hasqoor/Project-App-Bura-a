import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import '../home_screen/home_screen.dart';
import '../home_screen/notifications_screen.dart';
import '../home_screen/app_drawer.dart';

class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  final TextEditingController substanceController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  DateTime? _selectedDate; // Added for correct date storage
  final TextEditingController symptomsController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController otherController = TextEditingController();

  final List<String> allergyTypes = [
    'حساسية الأطعمة',
    'حساسية الأدوية',
    'حساسية البيئة والمواد',
    'أخرى',
  ];

  String? selectedAllergy; // اختيار واحد فقط
  bool isOtherSelected = false;
  String? severity;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      // locale: const Locale('ar', 'EG'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _saveAllergy() async {
    if (selectedAllergy == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار نوع الحساسية')));
      return;
    }

    String type = selectedAllergy!;
    if (type == 'أخرى') {
       if (otherController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة نوع الحساسية')));
          return;
       }
       type = otherController.text.trim();
    }

    if (substanceController.text.trim().isEmpty) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى كتابة المادة المسببة')));
       return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // CHECK WRITE PERMISSION
        final profileProvider = context.read<ProfileProvider>();
        if (!profileProvider.hasPermission('allergies', 'write')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('عذراً، ليس لديك صلاحية لإضافة حساسية'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
          }
          return;
        }

        // Use getFirestorePath to support shared profiles
        final collectionPath = profileProvider.getFirestorePath(user.uid, 'allergies');

        await FirebaseFirestore.instance.collection(collectionPath).add({
          'allergy_type': type,
          'allergen': substanceController.text.trim(),
          'date': _selectedDate,
          'severity': severity,
          'symptoms': symptomsController.text.trim(),
          'notes': notesController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ بيانات الحساسية بنجاح'), backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      }
    } catch(e) {
      if(mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 90,
      automaticallyImplyLeading: false,
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
        'الحساسية',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: HomeScreen.primaryBlue,
        ),
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
        color: HomeScreen.veryLightBlue.withOpacity(0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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

  Widget _buildAllergySelector() {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: Colors.white, // خلفية بيضاء
        title: const Text(
          'اختر نوع الحساسية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
        ),
        iconColor: HomeScreen.primaryBlue,
        collapsedIconColor: HomeScreen.primaryBlue,
        children: allergyTypes.map((type) {
          final isOther = type == 'أخرى';
          return Column(
            children: [
              Container(
                color: Colors.white, // خلفية اختيار أبيض
                child: RadioListTile<String>(
                  title: Text(
                    type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isOther ? FontWeight.bold : FontWeight.normal,
                      color: HomeScreen.primaryBlue,
                    ),
                  ),
                  value: type,
                  groupValue: selectedAllergy,
                  onChanged: (val) {
                    setState(() {
                      selectedAllergy = val;
                      isOtherSelected = val == 'أخرى';
                      if (!isOtherSelected) otherController.clear();
                    });
                  },
                  activeColor: HomeScreen.primaryBlue,
                ),
              ),
              if (isOtherSelected && isOther)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 8,
                  ),
                  child: TextField(
                    controller: otherController,
                    textDirection: TextDirection.rtl,
                    decoration: InputDecoration(
                      hintText: 'اكتب نوع الحساسية الأخرى',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade400),
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
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Icon(icon, color: HomeScreen.primaryBlue)
                : null,
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: HomeScreen.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'تاريخ ظهور الحساسية',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 5),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateController.text.isEmpty
                      ? 'اليوم / الشهر / السنة'
                      : dateController.text,
                  style: TextStyle(
                    fontSize: 16,
                    color: dateController.text.isEmpty
                        ? Colors.grey.shade600
                        : Colors.black,
                  ),
                ),
                const Icon(Icons.calendar_today, color: HomeScreen.primaryBlue),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityOptions() {
    final severities = ['خفيفة', 'متوسطة', 'شديدة'];
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.grey.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: severities.map((s) {
            final isSelected = severity == s;
            return InkWell(
              onTap: () => setState(() => severity = s),
              borderRadius: BorderRadius.circular(20),
              child: Row(
                children: [
                  // الدائرة الصغيرة فقط بدون خط
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? HomeScreen.primaryBlue
                          : Colors.grey.shade300,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    s,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const AppDrawer(),
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Selection Tabs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: SharedProfileTabs(showTitle: false),
              ),
              const SizedBox(height: 20),
              _buildAllergySelector(),
              const SizedBox(height: 20),
              _buildTextField(
                'اسم المادة المسببة للحساسية',
                'مثال: الفول السوداني أو البنسلين',
                substanceController,
                icon: Icons.medication_outlined,
              ),
              const SizedBox(height: 20),
              _buildDateField(),
              const SizedBox(height: 20),
              const Text(
                'شدة الحساسية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              _buildSeverityOptions(),
              const SizedBox(height: 20),
              _buildTextField(
                'الأعراض',
                'اكتب الأعراض التي تظهر',
                symptomsController,
              ),
              const SizedBox(height: 20),
              _buildTextField('ملاحظات', 'أي تفاصيل إضافية', notesController),
              const SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryBlue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isLoading ? null : _saveAllergy,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text(
                  'حفظ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
