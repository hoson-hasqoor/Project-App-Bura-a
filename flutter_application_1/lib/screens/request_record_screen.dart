import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/services/permission_request_service.dart';

class RequestRecordScreen extends StatefulWidget {
  const RequestRecordScreen({super.key});

  @override
  State<RequestRecordScreen> createState() => _RequestRecordScreenState();
}

class _RequestRecordScreenState extends State<RequestRecordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final PermissionRequestService _service = PermissionRequestService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendRequest() async {
    final email = _emailController.text.trim();

    // Validate email format
    if (email.isEmpty) {
      _showError('الرجاء إدخال البريد الإلكتروني');
      return;
    }

    if (!_service.isValidEmail(email)) {
      _showError('البريد الإلكتروني غير صحيح');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user info
      final currentUserInfo = await _service.getCurrentUserInfo();
      if (currentUserInfo == null) {
        _showError('خطأ: لم نتمكن من الحصول على معلومات المستخدم');
        setState(() => _isLoading = false);
        return;
      }

      // Check if trying to request own records
      if (email.toLowerCase() == currentUserInfo['email']!.toLowerCase()) {
        _showError('لا يمكنك إرسال طلب إلى نفسك');
        setState(() => _isLoading = false);
        return;
      }

      // Find target user by email
      final targetUserDoc = await _service.findUserByEmail(email);
      if (targetUserDoc == null) {
        _showError('المستخدم غير موجود\nالرجاء التحقق من البريد الإلكتروني');
        setState(() => _isLoading = false);
        return;
      }

      final targetUserId = targetUserDoc.id;

      // Check if request already exists
      final exists = await _service.requestExists(
        targetUserId: targetUserId,
        requesterId: currentUserInfo['id']!,
      );

      if (exists) {
        _showError('لقد أرسلت طلباً بالفعل إلى هذا المستخدم');
        setState(() => _isLoading = false);
        return;
      }

      // Create permission request
      final success = await _service.createPermissionRequest(
        targetUserId: targetUserId,
        requesterId: currentUserInfo['id']!,
        requesterName: currentUserInfo['name']!,
        requesterEmail: currentUserInfo['email']!,
      );

      setState(() => _isLoading = false);

      if (success) {
        _showSuccess();
      } else {
        _showError('فشل إرسال الطلب\nالرجاء المحاولة مرة أخرى');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('حدث خطأ: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 40),
              SizedBox(width: 10),
              Text('تم إرسال الطلب بنجاح'),
            ],
          ),
          content: const Text(
            'تم إرسال طلب الوصول إلى السجل الطبي.\nسيتم إشعار المستخدم وسيتمكن من قبول أو رفض الطلب.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HomeScreen.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'حسناً',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/images/logo.png',
              width: 40,
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: const Text(
          'طلب الوصول إلى سجل طبي',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: HomeScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Text(
                'يمكنك طلب الوصول إلى السجل الطبي\nلمستخدم آخر بإدخال بريده الإلكتروني',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                height: 250,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Image.asset(
                  'assets/images/request.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.medical_information_outlined,
                      size: 120,
                      color: HomeScreen.primaryBlue,
                    );
                  },
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'سيتم إرسال طلب للمستخدم\nوسيتمكن من قبول أو رفض طلبك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'البريد الإلكتروني للمستخدم',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildEmailInputField(),

              const SizedBox(height: 50),

              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputField() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextField(
          controller: _emailController,
          textAlign: TextAlign.right,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 17, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
          enabled: !_isLoading,
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _sendRequest,
      style: ElevatedButton.styleFrom(
        backgroundColor: HomeScreen.primaryBlue,
        disabledBackgroundColor: Colors.grey.shade400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 55),
        elevation: 5,
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Text(
              'إرسال الطلب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
