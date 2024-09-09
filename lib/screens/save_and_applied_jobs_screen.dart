import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:right_ship/screens/apply_jobs_screen.dart';
import 'package:right_ship/screens/apply_jobs_screen.dart';
import 'package:right_ship/screens/bottom_navigation_bar.dart';
import 'package:right_ship/screens/custom_bottom_navbar.dart';
import 'package:right_ship/screens/home_page_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:intl/intl.dart';

class SaveAndAppliedJobsScreen extends StatefulWidget {
  const SaveAndAppliedJobsScreen({super.key});

  @override
  State<SaveAndAppliedJobsScreen> createState() => _SaveAndAppliedJobsScreenState();
}

class _SaveAndAppliedJobsScreenState extends State<SaveAndAppliedJobsScreen> {

  List<dynamic> savedList = [];
  List<dynamic> appliedList = [];
  int _currentIndex = 2;
  String employee_id = '';
  bool ispressed = false;
  int _toggleIndex = 0;
  Map<String,dynamic> employee_data = {};
  bool isLoading = false;


  void _onTabTapped(int index){
    if (index == 0 && _currentIndex != 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePageScreen(),
        ),
      );
    }

    else if(index ==3 && _currentIndex != 3){
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
    else {
      setState(() {
        _currentIndex = index;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<List<Map<String, dynamic>>> getAppliedJobsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? appliedJobsJson = prefs.getString('appliedJobs');
    return appliedJobsJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(appliedJobsJson))
        : [];
  }
  Future<List<Map<String, dynamic>>> getSavedJobsList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? saveJobsJson = prefs.getString('saveJobs');
    return saveJobsJson != null
        ? List<Map<String, dynamic>>.from(jsonDecode(saveJobsJson))
        : [];
  }


  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
      getAppliedJobsList();
      getSavedJobsList();
    });

    try {
      List<dynamic> appliedJobs = await getAppliedJobsList();
      List<dynamic> savedJobs = await getSavedJobsList();

      setState(() {
        appliedList = appliedJobs;
        savedList = savedJobs;
        print('Applied list -------------------------> $appliedList');
        print('Saved list -------------------------> $savedList');

        isLoading = false;
      });
    } catch (e) {
      // Handle errors if needed
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:     const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        // toolbarHeight: 74,
        leading:
        // Padding(
        // padding: const EdgeInsets.only(top: 1, left: 23, bottom: 2.69),
        // child:
        Container(
          height: 70.31,
          width: 75,
          child: Image.asset('assets/images/right_ship.png'),
        ),
        // ),
        elevation: 4,
        actions: [
          // Padding(
          //   padding: const EdgeInsets.only(top: 20.0, right: 19),
          //   child:
          Container(
            height: 35,
            width: 35,
            child: const Icon(Icons.notifications_none, size: 35,color: Colors.black,),
          ),
          // ),
        ],
      ),
      body: isLoading ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
    onRefresh: _fetchData,
    child:
        ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                    padding: const EdgeInsets.only(top: 21,left: 39),
                    child: textWidget('Jobs', 'Inter', FontWeight.w700, 20, 0, 0, 0, 0, null)
                ),
                _buildToggleSwitch(),
                _buildJobList(),
              ],
            )
          ],
        )
      ),
      bottomNavigationBar:  CurvedBottomNavBar(
      currentIndex: _currentIndex,
      onTabItemSelected: _onTabTapped,
    ),
    );
  }


  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.only(top: 21, left: 36),
      child: ToggleSwitch(
        minHeight: 35,
        minWidth: 110,
        fontSize: 14,
        initialLabelIndex: _toggleIndex,
        activeBgColor: const [Color(0xFF4E7CD4)],
        activeFgColor: Colors.white,
        inactiveBgColor: const Color(0x424E7CD4),
        inactiveFgColor: Colors.black,
        totalSwitches: 2,
        cornerRadius: 0,
        labels: [
          "Saved (${savedList.length})",
          "Applied (${appliedList.length})"
        ],
        onToggle: (index) {
          setState(() {
            _toggleIndex = index!;
          });
        },
      ),
    );
  }

  String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 365) {
      return '${(difference.inDays / 365).floor()} year(s) ago';
    } else if (difference.inDays >= 30) {
      return '${(difference.inDays / 30).floor()} month(s) ago';
    } else if (difference.inDays >= 7) {
      return '${(difference.inDays / 7).floor()} week(s) ago';
    } else if (difference.inDays >= 1) {
      return '${difference.inDays} day(s) ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour(s) ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute(s) ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildJobList() {
    // Choose the list based on the toggle index
    List<dynamic> jobsToShow = _toggleIndex == 0 ? savedList : appliedList;

    // Debugging: Print the data structure
    print('Jobs to show: $jobsToShow');

    return Column(
      children: jobsToShow.map<Widget>((job) {
        // Print each job to see its structure
        print('Job: $job');

        if (job is Map<String, dynamic>) {
          final companyName = job['company_name'] as String? ?? 'Unknown Company';
          final rsplNo = job['rspl_no'] as String? ?? 'Unknown RSPL';

          // Ensure that `hiring_for` and `open_positions` are lists before mapping
          final hiringForList = job['hiring_for'] as List<dynamic>? ?? [];
          final hiringFor = hiringForList.map((e) => e.toString()).join(', ');

          final openPositionsList = job['open_positions'] as List<dynamic>? ?? [];
          final openPositions = openPositionsList.map((e) => e.toString()).join('   ');

          // Parse the dates
          final appliedDate = DateTime.parse(job['applied_date'] ?? DateTime.now().toIso8601String());
          final savedDate = DateTime.parse(job['saved_date'] ?? DateTime.now().toIso8601String());
          final String formattedAppliedDate = timeAgo(appliedDate);
          final String formattedSavedDate = timeAgo(savedDate);

          return dataCard(
            "$companyName | $rsplNo",
            'Hiring For',
            hiringFor,
            'Open Positions',
            openPositions,
            _toggleIndex == 0 ? formattedSavedDate : formattedAppliedDate, // Show appropriate date based on toggle index
          );
        } else {
          print('-----------------------Unexpected data format:---------------- $job');
          return Container(); // Return an empty container if the data format is unexpected
        }
      }).toList(),
    );
  }


  Padding dataCard(String companyAndRPSL, String hiringFor, String hiringPosition, String rankPosition, String rank,String dateandtime) {
    return Padding(
      padding: const EdgeInsets.only(top: 21,left: 37,right: 34),
      child: Card(
        elevation: 0,
        child: Container(
          color: const Color(0xFFFFFFFF),
          width: MediaQuery.of(context).size.width,
          // height: 217,
          // width: 359,
          child:  Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10,),
              textWidget(companyAndRPSL, 'Inter',  FontWeight.w400, 15, 0, 0, 0, 0, null),
              const SizedBox(height: 12,),
              textWidget(hiringFor,  'Inter', FontWeight.w700, 16, 0, 0, 0, 0, null),
              const SizedBox(height: 7,),
              textWidget(hiringPosition, 'Inter', FontWeight.w400, 15, 0, 0, 0, 0, null),
              const SizedBox(height: 10,),
              textWidget(rankPosition, 'Inter', FontWeight.w700, 16, 0, 0, 0, 0, null),
              const SizedBox(height: 7,),
              textWidget(rank, 'Inter',FontWeight.w400 , 15, 0, 0, 0, 0, null),
              const SizedBox(height: 14,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      height: 31,
                      width: 122,
                      child: Row(
                        children: [
                          SizedBox(height:31,width: 85,
                            child: OutlinedButton(onPressed: (){}, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),side: BorderSide(width: 1,color: Color(0x4500000)))),
                              child: textWidget('Apply', 'Inter', FontWeight.w700, 14, 0, 0, 0, 0, const Color(0xFF2557A7) ),
                              )
                          ),
                          const SizedBox(width: 8,),
                          SizedBox(height: 29,width: 29,
                              child: Icon(ispressed ?  Icons.bookmark_border_outlined : Icons.bookmark )
                          ),
                        ],
                      )
                  ),
                  textWidget(dateandtime, 'Inter',  FontWeight.w400, 14, 0, 0, 0, 0,const Color(0x8C000000))
                ],
              ),
              const SizedBox(height: 16,),
              Container(
                height: 1, // Height of the line
                color: const Color(0xFF949494), // Color of the line
              )
            ],
          ),
        ),
      ),
    );
  }

  Padding textWidget(String val,String fontFamily,FontWeight fw, double? fontSize, double top,double left,double bottom,double right,Color? color) {
    return Padding(
      padding: EdgeInsets.only(top: top,left: left,bottom: bottom,right: right),
      child: Text(val,style: TextStyle(fontFamily: fontFamily,fontWeight: fw,fontSize: fontSize),),
    );
  }

}

