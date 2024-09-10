import 'package:flutter/material.dart';
import 'package:right_ship/screens/apply_jobs_screen.dart';
import 'package:right_ship/screens/curved_bottom_navigation_bar.dart';
import 'package:right_ship/screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Right Ship App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  SplashScreen(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const SignUpScreen(),
      },
    );
  }
}