import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:right_ship/screens/login_screen.dart';
import 'package:right_ship/screens/profile_creation_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:right_ship/screens/sea_experience_screen.dart';
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
  final employeeData = prefs.getString('employee_data');
  print("employeeData $employeeId $employeeData");

  if (employeeData != null && employeeId != null) {
    final decodedEmployeeData = json.decode(employeeData);

    if (decodedEmployeeData['name'] == null ||
        decodedEmployeeData['name'].isEmpty) {
      // Navigate to ProfileCreation if name does not exist or is empty
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileCreationScreen(employeeId: employeeId),
        ),
      );
    } else if (decodedEmployeeData['presentRank'] == null ||
        decodedEmployeeData['presentRank'].isEmpty) {
      // Navigate to SeaExperienceScreen if presentRank does not exist or is empty
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              SeaExperienceScreen(profileData: decodedEmployeeData),
        ),
      );
    } else {
      // Navigate to ProfilePage if both name and presentRank exist
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
              employeeId: employeeId, profileData: decodedEmployeeData),
        ),
      );
    }
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
