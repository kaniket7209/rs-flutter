import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:right_ship/screens/bottom_navigation_bar.dart';
import 'package:right_ship/screens/home_page_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:right_ship/screens/settings_screen.dart';
import 'package:right_ship/sharedPref/shared_pref.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;


class SaveAndAppliedJobsScreen extends StatefulWidget {
  const SaveAndAppliedJobsScreen({super.key});

  @override
  State<SaveAndAppliedJobsScreen> createState() => _SaveAndAppliedJobsScreenState();
}

class _SaveAndAppliedJobsScreenState extends State<SaveAndAppliedJobsScreen> {
  List<dynamic> applications = [];
  List<dynamic> savedList = [];
  List<dynamic> appliedList = [];
  int _currentIndex = 1;
  String employee_id = '';
  bool ispressed1 = false;
  bool ispressed2 = false;
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
    else if(index ==2 && _currentIndex != 2){
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
    // else if(index == 1 && _currentIndex !=1 ){
    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => SettingsScreen()
    //     ),
    //   );
    // }
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
    _fetchApplications();
    _fetchPrefsData();
    _buildJobList();
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

  Future<void> _fetchApplications() async {
    final response = await http.post(
      Uri.parse('https://api.rightships.com/company/application/get'),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print("------------------Applications Data--------------->  $data");

      setState(() {
        applications = data['applications'];
        // print('Applications: ----------> $applications');
        // filteredItems = applications;
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load applications');
    }
  }

  Future<void> _fetchPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    String? existingEmployeeData = prefs.getString('employee_data');
    if (existingEmployeeData != null) {
      setState(() {
        employee_data = json.decode(existingEmployeeData);
        employee_id =  prefs.getString('employeeId')!;
      });
    }
  }

  Future<void> _applyForJob(String employeeId, String appId, String companyId) async {
    final response = await http.post(
      Uri.parse('https://api.rightships.com/employee/apply_job'),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode({
        "employee_id": employeeId,
        "application_id": appId,
        "company_id": companyId,
      }),
    );
    // Create the new applied_by entry
    final newAppliedByEntry = {
      "applied_date": DateTime.now().toUtc().toIso8601String(), // current date in UTC format
      "employee_id": employeeId,
    };
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // print("Applied successfully-------------->: $data");

      List<Map<String, dynamic>>? matchingApplication = [];

      setState(() {
        for (var application in applications) {
          if (application['application_id'] == appId && application['company_id'] == companyId) {
            // print('-----------Match found-------------> $application');
            application['applied_by'] ??= [];
            bool employeeAlreadyApplied = application['applied_by'].any((appliedBy) => appliedBy['employee_id'] == employeeId);
            // print("------------TRUE OR FALSE : ${employeeAlreadyApplied}");
            if (!employeeAlreadyApplied) {
              application['applied_by'].add(newAppliedByEntry);
              // print('Employee added for the first time--------> ${newAppliedByEntry}');
              matchingApplication.add(application);
              print('----------Applied----------$matchingApplication');
              break;
            }
          }
        }
      });

      // Fetch existing applied job list from SharedPreferences
      List<Map<String, dynamic>> appliedJobsList = await getAppliedJobsList();

      // Add new application to the list
      appliedJobsList.addAll(matchingApplication);

      print('------------------Shared Pref---------------------$appliedJobsList');

      // Save the updated list to SharedPreferences
      await setAppliedJobsList(appliedJobsList);

      print('Applications after update: $appliedJobsList');
      // Fetch the updated applications and refresh UI
      await _fetchData();
      await _fetchApplications();

    }
    else {
      throw Exception('Failed to apply for the job');
    }
  }

  Future<void> _unApplyForJob(String employeeId, String appId, String companyId) async {
    final response = await http.post(
      Uri.parse('https://api.rightships.com/employee/unapply'),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode({
        "employee_id": employeeId,
        "application_id": appId,
        "company_id": companyId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("----------------UnApplied successfully-------------->: $data");

      // Remove the job from the list in SharedPreferences
      List<Map<String, dynamic>> appliedJobsList = await getAppliedJobsList();

      // Find and remove the job from the list
      appliedJobsList.removeWhere((job) => job['application_id'] == appId && job['company_id'] == companyId);
      print('------------------Unapply SHARED PR------------------$appliedJobsList');

      // Save the updated list to SharedPreferences
      await setAppliedJobsList(appliedJobsList);

      // Update the local applications list and refresh the UI
      setState(() {
        for (var application in applications) {
          if (application['application_id'] == appId && application['company_id'] == companyId) {
            // Remove the entire 'applied_by' array
            application.remove('applied_by');
          }
        }
      });

      await _fetchData();
      await _fetchApplications();

    } else {
      throw Exception('Failed to UnApply');
    }
  }

  Future<void> _saveJob(String employeeId, String appId, String companyId) async{
    final response = await http.post(Uri.parse('https://api.rightships.com/employee/save_jobs'),
        headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
        body: jsonEncode({
          "employee_id": employeeId,
          "application_id": appId,
          "company_id": companyId,
        })
    );

    if(response.statusCode == 200){
      final data = jsonDecode(response.body);
      print('---------------------------------Saved Successfully-----------------------------> $data');

      //create the new saved jobs
      final newSaveJobs = {
        'saved_date' : DateTime.now().toUtc().toIso8601String(),
        "employee_id": employeeId,
      };

      List<Map<String,dynamic>>? saveJobsListInSharedPref = [];

      // Update the specific application in the list
      setState(() {
        for (var application in applications) {
          if (application['application_id'] == appId && application['company_id'] == companyId) {

            application['save_jobs_applications'] ??= [];
            // Check if the employee ID already exists in the saved jobs application array
            bool alreadySaved = application['save_jobs_applications'].any((savedJobs) =>
            savedJobs['employee_id'] == employeeId) ?? false;

            if (!alreadySaved) {
              // Ensure 'save_jobs_applications' is initialized as a list before adding to it
              application['save_jobs_applications'].add(newSaveJobs);
              saveJobsListInSharedPref.add(application);
              break;
            }
          }
        }
      });

      // Fetch existing applied job list from SharedPreferences
      List<Map<String, dynamic>> saveJobsList = await getSavedJobsList();


      // Add new application to the list
      saveJobsList.addAll(saveJobsListInSharedPref);

      print('---------------------Shared Pref Saved List------------------------$saveJobsList');

      // Save the updated list to SharedPreferences
      await setSavedJobsList(saveJobsList);

      print('Applications after update: $saveJobsList');
      // Fetch the updated applications and refresh UI

      await _fetchData();
      // Fetch the updated applications and refresh UI
      await _fetchApplications();

    }
    else{
      throw Exception('Failed to save for the job');
    }
  }

  Future<void> _unSaveJob(String employeeId, String appId, String companyId) async{
    final response = await http.post(
      Uri.parse('https://api.rightships.com/employee/unsave'),
      headers: {'Accept': '*/*', 'Content-Type': 'application/json'},
      body: jsonEncode({
        "employee_id": employeeId,
        "application_id": appId,
        "company_id": companyId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Unsaved Job successfully-------------------------->: $data");

      // Remove the job from the list in SharedPreferences
      List<Map<String, dynamic>> savedJobsList = await getSavedJobsList();

      // Find and remove the job from the list
      savedJobsList.removeWhere((job) => job['application_id'] == appId && job['company_id'] == companyId);

      print('------------------SAVED SHARED PR------------------$savedJobsList');
      // Save the updated list to SharedPreferences
      await setSavedJobsList(savedJobsList);

      // Update the local applications list and refresh the UI
      setState(() {
        for (var application in applications) {
          if (application['application_id'] == appId && application['company_id'] == companyId) {
            // Remove the entire 'applied_by' array
            application.remove('save_jobs_applications');
          }
        }
      });

      await _fetchData();
      await _fetchApplications();

    } else {
      throw Exception('Failed to UnSaved');
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
    IconData usedIcon = Icons.bookmark_border_outlined;
    String btnText = 'Apply';

    return Column(
      children:
      jobsToShow.map<Widget>((job) {
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


          bool isAppliedByExist = job['applied_by'] != null && job['applied_by'].isNotEmpty;
          bool isAppliedByUser = isAppliedByExist && job['applied_by'].any((appliedBy) => appliedBy['employee_id'] == employee_id);

          bool isSavedJobExist = job['save_jobs_applications'] != null && job['save_jobs_applications'].isNotEmpty;
          bool isSavedByUser = isSavedJobExist && (job['save_jobs_applications'] ?? []).any((saveJobs) => saveJobs['employee_id'] == employee_id);

          setState(() {
            btnText = isAppliedByUser ? "Unapply" : "Apply";
            usedIcon = isSavedByUser ? Icons.bookmark : Icons.bookmark_border_outlined;
          });


          return dataCard(
            "$companyName | $rsplNo",
            'Hiring For',
            hiringFor,
            'Open Positions',
            openPositions,
            _toggleIndex == 0 ? formattedSavedDate : formattedAppliedDate, // Show appropriate date based on toggle index,
            job['application_id'],
            job['company_id'],
             btnText,
           usedIcon,
              (){
                 _toggleIndex == 0 ? buttonOnTapFunctionality(isAppliedByExist, job,btnText) :  _unApplyForJob(employee_id, job['application_id'],job['company_id']);
              },
              (){
                _toggleIndex == 0 ? _unSaveJob(employee_id, job['application_id'],job['company_id']) : iconOnTap(isAppliedByExist, job,usedIcon);
                // buttonOnTapFunctionality(isAppliedByExist, applications);
              }
          );
        } else {
          print('-----------------------Unexpected data format:---------------- $job');
          return Container(); // Return an empty container if the data format is unexpected
        }
      }).toList(),
    );
  }

  void buttonOnTapFunctionality(bool isAppliedByExist,Map<String,dynamic> application,String btnText) {
    if (isAppliedByExist) {
      bool isMatched = application['applied_by'].any((appliedBy) => appliedBy['employee_id'].toString() == employee_id.toString()
      );

      if (isMatched) {
        _unApplyForJob(
            employee_id,
            application['application_id'].toString(),
            application['company_id'].toString()
        );
        setState(() {
          btnText = 'Apply';
        });

      } else {
        _applyForJob(
            employee_id,
            application['application_id'].toString(),
            application['company_id'].toString()
        );
        setState(() {
          btnText = 'Unapply';
        });
      }
    } else {
      _applyForJob(
          employee_id,
          application['application_id'].toString(),
          application['company_id'].toString()
      );
      setState(() {
        btnText = 'Unapply';
      });
    }
    setState(() {
      _fetchData();
    });

  }

  void iconOnTap(bool isSavedJobExist, Map<String,dynamic> application, IconData usedIcon){
    if(isSavedJobExist){
      bool isMatched = application['save_jobs_applications'] ?? [].any((saveJobs) => saveJobs['employee_id'] == employee_id);
      if(isMatched){
        _unSaveJob(employee_id, application['application_id'].toString(), application['company_id'].toString());
        setState(() {
          usedIcon = Icons.bookmark_border_outlined;
        });
      }else{
        _saveJob(employee_id, application['application_id'].toString(), application['company_id'].toString());
        setState(() {
          usedIcon = Icons.bookmark;
        });
      }
    }else{
      _saveJob(employee_id, application['application_id'].toString(), application['company_id'].toString());
      setState(() {
        usedIcon = Icons.bookmark;
      });
    }
    setState(() {
      _fetchData();
    });
  }

  Padding dataCard(String companyAndRPSL, String hiringFor, String hiringPosition, String rankPosition, String rank,String dateandtime, String application_id, String company_id,String btnText, IconData usedIcon, VoidCallback btnPress, VoidCallback iconpress, ) {
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
                      // width: 122,
                      child: Row(
                        children: [
                          SizedBox(height:31,
                              // width: 85,
                            child: OutlinedButton(
                              onPressed: btnPress,
                              style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4),side: BorderSide(width: 1,color: Color(0x4500000)))),
                              child: textWidget(_toggleIndex == 1 ? 'Unapply' : btnText, 'Inter', FontWeight.w700, 14, 0, 0, 0, 0, const Color(0xFF2557A7) ),
                              )
                          ),
                          const SizedBox(width: 8,),
                          SizedBox(height: 29,width: 29,
                              child: IconButton(
                                onPressed: iconpress,
                                icon: Icon(_toggleIndex == 0 ? Icons.bookmark : usedIcon),)
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

