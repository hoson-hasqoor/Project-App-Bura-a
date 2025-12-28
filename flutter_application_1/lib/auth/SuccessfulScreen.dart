import 'package:flutter/material.dart';
import 'dart:async';

class SuccessfulScreen extends StatefulWidget {
  const SuccessfulScreen({super.key});

  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
  // تحديد الألوان المستخدمة في التصميم
  static const Color primaryBlue = Color(0xFF004AAD);
  static const Color lightBlue = Color(0xFF4C7FFF);
  static const Color timeBoxColor = Color(0xFFE5E7EB);
  static const Color timerTextColor = Color(0xFF1F2937);

  // حالة المؤقت - تم تحديد المدة بدقيقتين
  int _minutes = 2;
  int _seconds = 0;
  late Timer _timer;
  bool _isTimerActive = true;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _isTimerActive = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_minutes == 0 && _seconds == 0) {
          _timer.cancel();
          _isTimerActive = false;
        } else if (_seconds == 0) {
          _minutes--;
          _seconds = 59;
        } else {
          _seconds--;
        }
      });
    });
  }

  void _resetTimer() {
    setState(() {
      _timer.cancel();
      _minutes = 2; // إعادة ضبط المؤقت إلى دقيقتين
      _seconds = 0;
      _startTimer();
    });
    // TODO: إضافة منطق لإعادة إرسال الطلب فعلياً (API call)
    debugPrint('Request resent.');
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String minutesStr = _minutes.toString().padLeft(2, '0');
    String secondsStr = _seconds.toString().padLeft(2, '0');

    // تحديد اتجاه النص ليكون من اليمين إلى اليسار (RTL) بشكل افتراضي للشاشة
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 30.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. زر العودة (السهم المتجه لليمين)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Image.asset(
                        'assets/images/back.png', // استخدام back.png
                        width: 28,
                        height: 28,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 28,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // 2. الشعار والعنوان
                  Center(
                    child: Column(
                      children: [
                        // الشعار (استخدام assets/images/logo.png)
                        Image.asset(
                          'assets/images/logo.png',
                          height: 80,
                          width: 80,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.medical_services_outlined,
                              size: 80,
                              color: primaryBlue,
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'انقل سجلك الصحي',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 3. الوصف
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'يمكنك ان تستورد سجلك الطبي من نظام آخر بسهولة',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Color(0xFF6B7280)),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 4. الرسم التوضيحي (صورة النجاح)
                  Center(
                    child: Image.asset(
                      'assets/images/success_transfer_illustration.png',
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return SizedBox(
                          height: 250,
                          width: double.infinity,
                          child: Center(
                            child: Icon(
                              Icons.cloud_done_outlined,
                              size: 150,
                              color: lightBlue.withOpacity(0.7),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 5. رسالة النجاح
                  const Text(
                    'تم إرسال طلبك بنجاح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: lightBlue,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // 6. رسالة الانتظار
                  const Text(
                    'يرجى انتظار موافقة الشخص المسؤول ليتم نقل سجلك الطبي',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 30),

                  // 7. المؤقت الزمني
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildTimeBox(minutesStr),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w600,
                            color: timerTextColor,
                          ),
                        ),
                      ),
                      _buildTimeBox(secondsStr),
                    ],
                  ),
                  const SizedBox(height: 60),

                  // 8. زر إعادة إرسال الطلب
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      // تعطيل الزر طالما المؤقت نشط
                      onPressed: _isTimerActive ? null : _resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                        disabledBackgroundColor: lightBlue.withOpacity(0.5),
                      ),
                      child: const Text(
                        'إعادة إرسال الطلب',
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
        ),
      ),
    );
  }

  // دالة مساعدة لبناء صندوق عرض الوقت (للدقائق والثواني)
  Widget _buildTimeBox(String time) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: timeBoxColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      alignment: Alignment.center,
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: timerTextColor,
        ),
      ),
    );
  }
}
