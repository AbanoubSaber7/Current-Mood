import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/detection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 1. بنسأل الموبايل: هل فيه حد مسجل دخول؟
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  String? userName = prefs.getString('user_name');

  // 2. بنبعت الإجابة للأبلكيشن وهو بيفتح
  runApp(MoodApp(isLoggedIn: isLoggedIn, userName: userName));
}

class MoodApp extends StatelessWidget {
  final bool isLoggedIn;
  final String? userName;

  const MoodApp({super.key, required this.isLoggedIn, this.userName});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Current Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        primarySwatch: Colors.red,
      ),
      // اللوجيك هنا: لو مسجل (true) يروح للدكتيكشن، لو مش مسجل (false) يروح للسبلاش
      initialRoute: isLoggedIn ? '/detection' : '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/detection': (context) => DetectionScreen(userName: userName ?? "User"),
      },
    );
  }
}