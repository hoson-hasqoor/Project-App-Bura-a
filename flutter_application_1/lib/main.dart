import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // (1) استيراد حزمة الخدمات
import 'package:flutter_application_1/splash_screen.dart';
//استيراد حزمة firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
// استيراد Provider
import 'package:provider/provider.dart';
import 'providers/profile_provider.dart';

import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Notifications
  await NotificationService().initialize();

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
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
        home: const SplashScreen(), // 👈 التغيير: ابدأ بشاشة البداية
      ),
    );
  }
}
