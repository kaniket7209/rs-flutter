import 'package:flutter/material.dart';
import 'package:right_ship/screens/bottom_navigation_bar.dart';
import 'package:right_ship/screens/home_page_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:right_ship/screens/save_and_applied_jobs_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  String employee_id = '';
  Map<String,dynamic> employee_data = {};
  int _currentIndex = 0;

  void _onTabTapped(int index){
    if (index == 3 && _currentIndex != 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfilePage(
            employeeId: employee_id, // Replace with actual employeeId
            profileData: employee_data, // Replace with actual profileData
          ),
        ),
      );
    }
    else if(index == 2 && _currentIndex !=2 ){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => SaveAndAppliedJobsScreen()
        ),
      );
    }
    else if(index == 0 && _currentIndex !=0 ){
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomePageScreen()
        ),
      );
    }
    else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings')
          ],
        ),
      ),
      bottomNavigationBar: CurvedBottomNavBar(
        currentIndex: _currentIndex,
        onTabItemSelected: _onTabTapped,
      ),
    );
  }
}
