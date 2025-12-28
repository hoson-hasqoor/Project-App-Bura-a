import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/shared_profile_tabs.dart';
import 'package:flutter_application_1/screens/health_record_screen.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddLabXrayScreen extends StatefulWidget {
  final XFile? initialImage;
  
  const AddLabXrayScreen({super.key, this.initialImage});

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
  bool _isLoading = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final TextEditingController _otherLabController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  DateTime? _selectedDate;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedLabs = {for (var option in labOptions) option: false};
    _selectedImage = widget.initialImage;
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

      // locale: const Locale('ar', 'EG'),
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

  Future<String?> _uploadImageToStorage(XFile imageFile) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // Create unique file name
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'lab_${timestamp}_${imageFile.name}';
      
      // Create reference to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(user.uid)
          .child('lab_xray')
          .child(fileName);

      // Upload file
      final uploadTask = storageRef.putFile(File(imageFile.path));
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final downloadUrl = await storageRef.getDownloadURL();
      
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في اختيار الصورة: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveLabXray() async {
    // Collect selected labs
    List<String> selected = [];
    selectedLabs.forEach((key, value) {
      if (value) selected.add(key);
    });

    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يرجى اختيار تحليل واحد على الأقل')));
      return;
    }

    // Handle "Other"
    if (selected.contains('أخرى')) {
      if (_otherLabController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('يرجى كتابة اسم التحليل الآخر')));
        return;
      }
      // Replace 'أخرى' with the actual text or just add it
      selected.remove('أخرى');
      selected.add(_otherLabController.text.trim());
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // CHECK WRITE PERMISSION
        final profileProvider = context.read<ProfileProvider>();
        if (!profileProvider.hasPermission('medical_tests', 'write')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('عذراً، ليس لديك صلاحية لإضافة تحاليل طبية'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() => _isLoading = false);
          }
          return;
        }

        // Upload image if selected
        String? imageUrl;
        if (_selectedImage != null) {
          imageUrl = await _uploadImageToStorage(_selectedImage!);
          if (imageUrl == null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('فشل رفع الصورة. سيتم الحفظ بدون صورة.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }

        // Use getFirestorePath to support shared profiles
        final collectionPath =
            profileProvider.getFirestorePath(user.uid, 'lab_xray');

        // Prepare data
        Map<String, dynamic> data = {
          'lab_names': selected,
          'date': _selectedDate,
          'notes': _notesController.text.trim(),
          'created_at': FieldValue.serverTimestamp(),
        };

        // Add image URL if available
        if (imageUrl != null) {
          data['image_url'] = imageUrl;
        }

        await FirebaseFirestore.instance.collection(collectionPath).add(data);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('تم حفظ البيانات بنجاح'),
              backgroundColor: Colors.green));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  // 7. بناء حاوية رفع ملف / صورة مع معاينة
  Widget _buildUploadContainer() {
    if (_selectedImage != null) {
      // Show image preview
      return Column(
        children: [
          Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_selectedImage!.path),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_isUploading)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      HomeScreen.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'جاري الرفع... ${(_uploadProgress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    // Show upload options
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.camera_alt),
                label: const Text('التقاط صورة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryBlue.withOpacity(0.1),
                  foregroundColor: HomeScreen.primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _pickImage(ImageSource.gallery),
                icon: const Icon(Icons.photo_library),
                label: const Text('من المعرض'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryBlue.withOpacity(0.1),
                  foregroundColor: HomeScreen.primaryBlue,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
              // Profile Selection Tabs
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 0.0),
                child: SharedProfileTabs(showTitle: false),
              ),
              const SizedBox(height: 20),
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
                  onPressed: (_isLoading || _isUploading) ? null : _saveLabXray,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HomeScreen.primaryBlue,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: (_isLoading || _isUploading)
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
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
