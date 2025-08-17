import 'package:dental_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dental_app/screens/signup_screen.dart';
import 'package:dental_app/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyClExw50IqJNNXe5Wo8NwAXRQ0AGKz8BTA",
      appId: "1:326521123200:android:435e73edea140c14eb5165",
      messagingSenderId: "326521123200",
      projectId: "dental-proj-737fb",
      storageBucket: "dental-proj-737fb.appspot.com", // Should be .com instead of the .app
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
      home: const LoginScreen(),
      routes: {
        '/signup': (context) => const SignupScreen(),
        '/home' :(context) => const HomeScreen(),
      },
    );
  }
}
