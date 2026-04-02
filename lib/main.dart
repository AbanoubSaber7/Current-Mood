import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // سطر جديد
import 'firebase_options.dart'; // سطر جديد
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // السطرين دول هما اللي بيفتحوا الطريق للفيربيز يشتغل
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
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}