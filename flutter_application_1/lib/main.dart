import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // (1) استيراد حزمة الخدمات
import 'package:flutter_application_1/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,

      statusBarIconBrightness: Brightness.dark,

      statusBarBrightness: Brightness.light,
    ),
  );
  // --------------------------------------------------------------------------

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: const SplashScreen(), // 👈 التغيير: ابدأ بشاشة البداية
    );
  }
}
