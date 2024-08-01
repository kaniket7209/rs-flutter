import 'package:flutter/material.dart';
import 'package:right_ship/screens/login_screen.dart';
import 'package:right_ship/screens/profile_creation_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final employeeId = prefs.getString('employeeId');
    
    if (employeeId != null) {
      
      // User is logged in, navigate to profile screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(employeeId: employeeId),
          // builder: (context) => ProfileCreationScreen(employeeId: employeeId),
        ),
      );
    } else {
      // User is not logged in, navigate to login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}