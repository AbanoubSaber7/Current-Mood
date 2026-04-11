import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/detection_screen.dart';
import 'screens/mood_history_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Current Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.red,
      ),
      // البداية دايماً من السبيلاش
      home: const SplashScreen(),
      // تعريف المسارات (Routes) عشان نستخدم Navigator.pushNamed لو حبيت
      routes: {
        '/login': (context) => const LoginScreen(),
        // ملحوظة: الـ Detection محتاجة userName، هنبعته من الـ Navigator العادي أضمن
      },
    );
  }
}