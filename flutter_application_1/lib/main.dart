import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// تأكد من وجود حزمة firebase_core في ملف pubspec.yaml
import 'package:firebase_core/firebase_core.dart';
// تأكد من أن هذا الملف قد تم توليده بواسطة FlutterFire CLI
import 'firebase_options.dart';

// يجب أن تكون الدالة main غير متزامنة (async)
void main() async {
  // تضمن أن الـ Widgets جاهزة قبل تهيئة Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة Firebase باستخدام الخيارات الخاصة بالمنصة الحالية
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // إعدادات شريط الحالة (Status Bar)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'تطبيق فلاتر بسيط',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      // يمكن تغيير هذه الصفحة إلى SplashScreen أو HomeScreen
      home: const MyHomePage(title: 'الصفحة الرئيسية'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: const Center(
        child: Text(
          'تمت تهيئة Firebase بنجاح!',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
