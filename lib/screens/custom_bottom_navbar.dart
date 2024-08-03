import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';
import 'package:right_ship/screens/profile_page.dart';
// Import other necessary screens here

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabItemSelected;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTabItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MotionTabBar(
      labels: ["Home", "Settings", "Save Jobs", "Profile"],
      initialSelectedTab: "Home",
      tabIconColor: Colors.black,
      tabSelectedColor: Color(0xff1F5882),
      textStyle: TextStyle(color: Colors.black),
      onTabItemSelected: (int value) {
        if (value == 3 && currentIndex != 3) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(
                employeeId: 'employeeId', // Replace with actual employeeId
                profileData: {}, // Replace with actual profileData
              ),
            ),
          );
        } else {
          onTabItemSelected(value);
        }
      },
      icons: [Icons.home, Icons.settings, Icons.save, Icons.person],
    );
  }
}