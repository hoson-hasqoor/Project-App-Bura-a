import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import '../home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class MedicinesScreen extends StatefulWidget {
  const MedicinesScreen({super.key});
  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  String? _medicineType = 'مزمن';
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage;
  String? _imageName;

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        if (kIsWeb) {
          var f = await image.readAsBytes();
          setState(() {
            _webImage = f;
            _selectedImage = File('a');
            _imageName = image.name;
          });
        } else {
          setState(() {
            _selectedImage = File(image.path);
            _imageName = image.name;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _saveMedicine() async {
    if (_nameController.text.trim().isEmpty) return;

    final profileProvider = context.read<ProfileProvider>();
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final collectionPath = profileProvider.getFirestorePath(
          user.uid,
          'medicines',
        );

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection(collectionPath)
            .add({
              'medicine_name': _nameController.text.trim(),
              'dosage': _dosageController.text.trim(),
              'purpose': _purposeController.text.trim(),
              'frequency': _frequencyController.text.trim(),
              'type': _medicineType,
              'start_date': _startDate,
              'end_date': _endDate,
              'notes': _notesController.text.trim(),
              'created_at': FieldValue.serverTimestamp(),
            });

        if (_selectedImage != null || (kIsWeb && _webImage != null)) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('medicines_images')
              .child('${user.uid}/${docRef.id}.jpg');

          if (kIsWeb && _webImage != null) {
            await storageRef.putData(_webImage!);
          } else {
            await storageRef.putFile(_selectedImage!);
          }

          final imageUrl = await storageRef.getDownloadURL();

          // --- التعديل هنا: استخدام اسم حقل موحد ---
          await docRef.update({'file_url': imageUrl});
        }

        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
          'الادوية',
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
              Navigator.of(context).pop();
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
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
                    // Profile Selection Tabs
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                      child: SharedProfileTabs(showTitle: false),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'اسم الدواء',
                      hint: 'اسم الدواء',
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'المعيار / الجرعة',
                      hint: 'المعيار / الجرعة',
                      controller: _dosageController,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      label: 'يستخدم لعلاج',
                      hint: 'يستخدم لعلاج',
                      controller: _purposeController,
                    ),
                    const SizedBox(height: 20),
                    _buildQuantityField(
                      label: 'عدد مرات التناول يومياً',
                      hint: 'اضف كم مرة تاخذ الدواء يوميا',
                      controller: _frequencyController,
                    ),
                    const SizedBox(height: 20),
                    _buildMedicineTypeSelector(),
                    const SizedBox(height: 20),
                    _buildDateTextField(
                      label: 'تاريخ البداية',
                      date: _startDate,
                      onTap: () => _pickDate(true),
                    ),
                    const SizedBox(height: 20),
                    _buildDateTextField(
                      label: 'تاريخ النهاية',
                      date: _endDate,
                      onTap: () => _pickDate(false),
                    ),
                    const SizedBox(height: 30),
                    _buildUploadField(),
                    const SizedBox(height: 30),
                    _buildNotesField(),
                    const SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveMedicine,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HomeScreen.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
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
                  ],
                ),
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
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
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            textAlign: TextAlign.right,
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
      ],
    );
  }

  Widget _buildQuantityField({
    required String label,
    required String hint,
    required TextEditingController controller,
  }) => _buildTextField(label: label, hint: hint, controller: controller);

  Widget _buildMedicineTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'نوع الدواء',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            _buildRadioOption(title: 'مزمن', value: 'مزمن'),
            const SizedBox(width: 20),
            _buildRadioOption(title: 'مؤقت', value: 'مؤقت'),
            const SizedBox(width: 20),
            _buildRadioOption(title: 'مكمل غذائي', value: 'مكمل غذائي'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption({required String title, required String value}) {
    final isSelected = _medicineType == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _medicineType = value;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: isSelected ? HomeScreen.primaryBlue : Colors.black87,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? HomeScreen.primaryBlue
                    : Colors.grey.shade400,
                width: 2,
              ),
              color: Colors.white,
            ),
            child: isSelected
                ? Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: HomeScreen.primaryBlue,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTextField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    String hint = date == null
        ? 'اليوم / الشهر / السنة'
        : "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
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
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: InkWell(
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    hint,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 15,
                      color: date == null ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'رفع ملف / صورة (اختياري)',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'بامكانك اضافة صورة الدواء او الوصفة الطبية',
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: InkWell(
            onTap: _pickImage,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _imageName ?? 'اضغط لرفع الملفات...',
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: _imageName != null ? Colors.black87 : Colors.grey,
                    ),
                  ),
                ),
                Icon(
                  _imageName != null
                      ? Icons.check_circle
                      : Icons.upload_file_outlined,
                  color: _imageName != null ? Colors.green : Colors.grey,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        if (_webImage != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 100,
              child: Image.memory(_webImage!, fit: BoxFit.cover),
            ),
          )
        else if (_selectedImage != null && !kIsWeb)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              height: 100,
              child: Image.file(_selectedImage!, fit: BoxFit.cover),
            ),
          ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'الملاحظات',
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: TextField(
            controller: _notesController,
            textAlign: TextAlign.right,
            maxLines: 3,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              hintText: 'أضف ملاحظاتك هنا...',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
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
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
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
