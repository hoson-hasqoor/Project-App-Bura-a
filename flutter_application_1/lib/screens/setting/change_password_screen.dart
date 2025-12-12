import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/app_drawer.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';
import 'package:flutter_application_1/home_screen/notifications_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color buttonBlue = Color(0xFF3B82F6);
  static const Color lightGrey = Color(0xFFF0F0F0);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double illustrationHeight = screenHeight * 0.25;

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
        title: const Text(
          'تغيير كلمة المرور', // توحيد النص مع الصفحة
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ChangePasswordScreen.primaryBlue,
          ),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              const Text(
                'تغيير كلمة المرور',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: ChangePasswordScreen.primaryBlue,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'أدخل كلمة المرور الحالية ثم عيّن كلمة مرور جديدة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),

              Center(
                child: Image.asset(
                  'assets/images/set_new_password_illustration.png',
                  height: illustrationHeight,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: illustrationHeight,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.vpn_key_outlined,
                      size: 150,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              const Text(
                'كلمة المرور الحالية',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPasswordTextField(
                hintText: '***********',
                isVisible: _isCurrentPasswordVisible,
                onVisibilityToggle: (value) {
                  setState(() {
                    _isCurrentPasswordVisible = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'كلمة المرور الجديدة',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPasswordTextField(
                hintText: '***********',
                isVisible: _isNewPasswordVisible,
                onVisibilityToggle: (value) {
                  setState(() {
                    _isNewPasswordVisible = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              const Text(
                'تأكيد كلمة المرور الجديدة',
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildPasswordTextField(
                hintText: '***********',
                isVisible: _isConfirmPasswordVisible,
                onVisibilityToggle: (value) {
                  setState(() {
                    _isConfirmPasswordVisible = value;
                  });
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    _showSnackBar(context, 'جاري تغيير كلمة المرور...');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ChangePasswordScreen.buttonBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'تأكيد التغيير',
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
    );
  }

  Widget _buildPasswordTextField({
    required String hintText,
    required bool isVisible,
    required ValueChanged<bool> onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ChangePasswordScreen.lightGrey,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextFormField(
        textAlign: TextAlign.right,
        obscureText: !isVisible,
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15.0,
            horizontal: 20.0,
          ),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: ChangePasswordScreen.primaryBlue,
              width: 2,
            ),
          ),
          prefixIcon: IconButton(
            icon: Icon(
              isVisible ? Icons.visibility : Icons.visibility_off,
              color: ChangePasswordScreen.primaryBlue,
            ),
            onPressed: () => onVisibilityToggle(!isVisible),
          ),
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 2),
      ),
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
          IconButton(
            onPressed: () => Scaffold.of(context).openEndDrawer(),
            icon: const Icon(Icons.menu, size: 30, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
