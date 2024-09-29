import 'package:flutter/material.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTabItemSelected;

  CustomBottomNavigationBar({required this.currentIndex, required this.onTabItemSelected,});

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return
      MotionTabBar(
      labels: const ["Home","Save Jobs", "Profile"],
      initialSelectedTab: widget.currentIndex == 0 ? "Home" : widget.currentIndex == 1 ? "Save Jobs" : "Profile",
      tabIconColor: Colors.black,
      tabBarHeight: 89,
      tabIconSize: 35,
      tabSelectedColor: const Color(0xff1F5882),
      textStyle:  TextStyle(
          color: widget.currentIndex == 0 || widget.currentIndex == 1 || widget.currentIndex == 2 
              ? Colors.black // Unselected text color
              : Colors.white, // Selected text color
        ),
      onTabItemSelected: widget.onTabItemSelected,
      icons: const [Icons.home_outlined, Icons.shopping_bag_outlined, Icons.person_outline],
    );
  }
}