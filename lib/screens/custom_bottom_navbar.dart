import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

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
      initialSelectedTab: currentIndex == 0
          ? "Home"
          : currentIndex == 1
              ? "Settings"
              : currentIndex == 2
                  ? "Save Jobs"
                  : "Profile",
      tabIconColor: Colors.black,
      tabSelectedColor: Color(0xff1F5882),
      textStyle: TextStyle(color: Colors.black),
      onTabItemSelected: onTabItemSelected,
      icons: [Icons.home, Icons.settings, Icons.save, Icons.person],
    );
  }
}