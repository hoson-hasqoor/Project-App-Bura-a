// lib/screens/request_record_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/home_screen/home_screen.dart';

class RequestRecordScreen extends StatelessWidget {
  const RequestRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== AppBar
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
          'اطلب ادارة سجل اخر',
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
                (route) => false,
              );
            },
            icon: Image.asset('assets/images/back.png', width: 24, height: 24),
          ),
          const SizedBox(width: 10),
        ],
      ),

      // ===== Body
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // وصف توضيحي
              const Text(
                'يمكنك ان تستورد سجلك الطبي من\nنظام آخر بسهولة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              // صورة توضيحية
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
                  'assets/images/request.PNG',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'سيتم ارسال له طلب لمشاركتك سجله\nالشخصي',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              // حقل البريد الإلكتروني
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'البريد الالكتروني',
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

              // زر الإرسال
              _buildTransferButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ===== ويدجت حقل البريد الإلكتروني
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
          textAlign: TextAlign.right,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(fontSize: 17, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'البريد الإلكتروني الذي تريد الحصول على سجله الطبي',
            hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
    );
  }

  // ===== ويدجت زر الإرسال
  Widget _buildTransferButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال طلب النقل بنجاح (عرض توضيحي)'),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: HomeScreen.primaryBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 18),
        minimumSize: Size(MediaQuery.of(context).size.width * 0.9, 55),
        elevation: 5,
      ),
      child: const Text(
        'إرسال طلب النقل',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
