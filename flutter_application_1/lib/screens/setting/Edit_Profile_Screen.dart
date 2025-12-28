import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color lightGrey = Color(0xFFF0F0F0);
  static const Color buttonBlue = HomeScreen.primaryBlue;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Image Upload Variables
  File? _selectedImage;
  String? _currentPhotoUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    if (currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _nameController.text = data['name'] ?? '';
          _emailController.text = data['email'] ?? currentUser?.email ?? '';
          _phoneController.text = data['phone'] ?? '';
          _currentPhotoUrl = data['photoUrl'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل اختيار الصورة: $e')));
    }
  }

  Future<String?> _uploadImage(String userId) async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profiles')
          .child('$userId.jpg'); // Overwrite same file for profile simplicity

      await storageRef.putFile(_selectedImage!);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint("Error uploading image: $e");
      throw Exception('فشل رفع الصورة');
    }
  }

  // داخل ملف EditProfileScreen في دالة _saveChanges:

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى إدخال الاسم')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      String? newPhotoUrl;
      if (_selectedImage != null) {
        newPhotoUrl = await _uploadImage(currentUser!.uid);
      }

      // تحديث Firestore بمسميات حقول موحدة
      Map<String, dynamic> updates = {
        'name': _nameController.text
            .trim(), // تأكد أنها 'name' لتطابق صفحة الـ Profile
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (newPhotoUrl != null) {
        updates['photoUrl'] = newPhotoUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .update(updates);

      if (!mounted) return;

      // العودة مباشرة - صفحة الـ Profile ستتحدث تلقائياً بسبب الـ Stream
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم التحديث بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('خطأ: $e')));
    }
  }

  // ويدجت حقل الإدخال
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242),
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              // يحدد لون الخلفية والحدود بناءً على إمكانية التعديل
              color: isReadOnly ? lightGrey : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: isReadOnly
                  ? Border.all(color: Colors.transparent)
                  : Border.all(color: const Color(0xFFCCCCCC), width: 1),
            ),
            child: TextFormField(
              controller: controller,
              readOnly: isReadOnly,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                color: isReadOnly ? Colors.grey.shade700 : Colors.black,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15.0,
                  horizontal: 20.0,
                ),
                border: InputBorder.none,
                // حدود زرقاء عند التركيز لتصميم شاشة التعديل
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: HomeScreen.primaryBlue,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (_currentPhotoUrl != null && _currentPhotoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_currentPhotoUrl!);
    } else {
      imageProvider = const AssetImage('assets/images/profile.png');
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // لإزالة زر العودة الافتراضي
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 90,
        title: const Text(
          'تعديل الملف الشخصي',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
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
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.image,
                color: HomeScreen.primaryBlue,
                size: 40,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            // زر العودة: يغلق الشاشة الحالية للعودة للشاشة السابقة
            onPressed: () => Navigator.pop(context),
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // صورة الملف الشخصي وزر الكاميرا
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: HomeScreen.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image(
                      image: imageProvider,
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 60,
                        color: HomeScreen.primaryBlue,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: HomeScreen.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // حقول الإدخال القابلة للتعديل
            _buildInputField(
              label: 'الاسم الكامل',
              controller: _nameController,
              isReadOnly: false,
            ),
            _buildInputField(
              label: 'البريد الإلكتروني',
              controller: _emailController,
              isReadOnly: false,
            ),
            _buildInputField(
              label: 'رقم الجوال',
              controller: _phoneController,
              isReadOnly: false,
            ),
            const SizedBox(height: 20),

            // زر حفظ التغييرات
            SizedBox(
              height: 55,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'حفظ التغييرات',
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
    );
  }
}
