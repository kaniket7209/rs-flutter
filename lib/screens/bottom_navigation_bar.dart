import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:right_ship/screens/home_page_screen.dart';
import 'package:right_ship/screens/save_and_applied_jobs_screen.dart';


//not using this one anywhere now
class BottomNavigationBarClass extends StatefulWidget {
  const BottomNavigationBarClass({super.key, required items});

  @override
  State<BottomNavigationBarClass> createState() => _BottomNavigationBarClassState();
}

class _BottomNavigationBarClassState extends State<BottomNavigationBarClass> {

  int selectedindex = 0;
  PageController pageController = PageController();

  void onTap(int index)
  {
    setState(() {
      selectedindex = index;
    });
    pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: PageView(
        controller: pageController,
        children: [
          HomePageScreen(),
          SaveAndAppliedJobsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items :  [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),label: 'Home'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings),label: 'Settings'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add),label: 'Add'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined),label: 'Profile'
          ),
        ],
        currentIndex : selectedindex,
        selectedItemColor : Colors.green,
        unselectedItemColor : Colors.grey,
        onTap : onTap
      ),
    );
  }
}
