import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:right_ship/screens/apply_jobs_screen.dart';
import 'package:right_ship/screens/custom_bottom_navbar.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:right_ship/screens/save_and_applied_jobs_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {

  TextEditingController textEditingController = TextEditingController();
  List<dynamic> applications = [];
  List<dynamic> filteredItems = [];
  bool isLoading = false;
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
    else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchApplications();
    _fetchPrefsData();
    textEditingController.addListener(filterList);
  }


  void filterList() {
    setState(() {
      filteredItems = applications.where((item) {
        final companyName = (item['company_name'] as String?) ?? '';
        final rsplNo = (item['rspl_no'] as String?) ?? '';
        final hiringFor = (item['hiring_for'] as List<dynamic>? ?? []).join(', ');
        final openPositions = (item['open_positions'] as List<dynamic>? ?? []).join('   ');

        final searchQuery = textEditingController.text.toLowerCase();

        return companyName.toLowerCase().contains(searchQuery) ||
            rsplNo.toLowerCase().contains(searchQuery) ||
            hiringFor.toLowerCase().contains(searchQuery) ||
            openPositions.toLowerCase().contains(searchQuery);
      }).toList();

      print("Filtered items: $filteredItems");
    });
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
      print("------------------Applications Data--------------->  $data");

      setState(() {
        applications = data['applications'];
        // print('Applications ----------> $applications');
        filteredItems = applications;
        isLoading = false;
      });
      //storing in shared pref
      // await storeWholeNewListOfAppliedJobsDataInSharedPref(applications);
      // await storeWholeNewListWithSavedJobsDataInSharedPref(applications);
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load applications');
    }
  }

  Future<void> setAppliedJobsList(jsonData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Convert the List<Map<String, dynamic>> to a JSON string
    String appliedListData = jsonEncode(jsonData);

    // Store the JSON string in SharedPreferences
    await prefs.setString('applied_data', appliedListData);
  }

  Future<List<dynamic>> getAppliedJobsList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the JSON string from SharedPreferences
    String? dataFromSP = prefs.getString('applied_data');

    if (dataFromSP == null) {
      return []; // Return an empty list if no data is found
    }

    // Convert the JSON string to a List<Map<String, dynamic>>
    List<dynamic> jsonList = jsonDecode(dataFromSP);
    return jsonList;
  }

  Future<void> storeWholeNewListOfAppliedJobsDataInSharedPref(dynamic appliedData) async {
    final prefs = await SharedPreferences.getInstance();
    // print('-----------------------Whole Data: ${jsonEncode(wholeData)}'); // Debugging log
    List<dynamic> olddata = await getAppliedJobsList();

    // // Remove jobs that were unapplied
    // olddata?.removeWhere((job) =>
    // job['application_id'] == appliedData['application_id'] &&
    //     job['company_id'] == appliedData['company_id']);

    if(prefs.containsKey('applied_data')){
      print('---------------------------------SHOWING OLD DATA--------------------------------------');
      olddata.add(appliedData);
      await setAppliedJobsList(olddata);
    }
    else{
      List<dynamic> newData = [];
      newData.add(appliedData);
      print('---------------------------------ADDED NEW DATA--------------------------------------');
      await setAppliedJobsList(newData);
    }
    // await prefs.setString('applied_data', jsonEncode(appliedData));

    print('----------------------------Applied Data stored successfully'); // Confirmation log

  }


  Future<void> setSavedJobsList(jsonData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();


    // Convert the List<Map<String, dynamic>> to a JSON string
    String appliedListData = jsonEncode(jsonData);

    // Store the JSON string in SharedPreferences
    await prefs.setString('saved_jobs_data', appliedListData);
  }

  Future<List<dynamic>> getSavedJobsList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get the JSON string from SharedPreferences
    String? dataFromSP = prefs.getString('saved_jobs_data');

    if (dataFromSP == null) {
      return []; // Return an empty list if no data is found
    }

    // Convert the JSON string to a List<Map<String, dynamic>>
    List<dynamic> jsonList = jsonDecode(dataFromSP);
    return jsonList;
  }

  Future<void> storeWholeNewListWithSavedJobsDataInSharedPref(dynamic appliedData) async {
    final prefs = await SharedPreferences.getInstance();
    // print('-----------------------Whole Data: ${jsonEncode(wholeData)}'); // Debugging log
    List<dynamic> olddata = await getSavedJobsList();

    // Remove jobs that were unapplied
    // olddata.removeWhere((job) =>
    // job['application_id'] == appliedData['application_id'] &&
    //     job['company_id'] == appliedData['company_id']);

    if(prefs.containsKey('saved_jobs_data')){
      print('---------------------------------SHOWING OLD SAVED JOBS DATA--------------------------------------');
      olddata.add(appliedData);
      await setSavedJobsList(olddata);
    }
    else{
      List<dynamic> newData = [];
      newData.add(appliedData);
      print('---------------------------------ADDED NEW SAVED JOBS DATA--------------------------------------');
      await setSavedJobsList(newData);
    }
    // await prefs.setString('applied_data', jsonEncode(appliedData));

    print('----------------------------SAVED Data stored successfully'); // Confirmation log

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
      print("Applied successfully-------------->: $data");


      for (var application in applications) {
        if (application['application_id'] == appId && application['company_id'] == companyId) {
          print('Match found: $application');

          bool employeeAlreadyApplied = application['applied_by']?.any((appliedBy) => appliedBy['employee_id'] == employeeId) ?? false;

          print("-----------------TRUE OR FALSE : ${employeeAlreadyApplied}");
          if (!employeeAlreadyApplied) {
            // Ensure 'applied_by' is initialized as a list before adding to it
            application['applied_by'] ??= [];
            application['applied_by'].add(newAppliedByEntry);
            print('Employee added for the first time: ${newAppliedByEntry}');
          }
        }

      }
      await storeWholeNewListOfAppliedJobsDataInSharedPref(applications);
      print('Applications after update: $applications');

      // Fetch the updated applications and refresh UI
      await _fetchApplications();

    } else {
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
      print("UnApplied successfully-------------->: $data");

      // Update the specific application in the list
      for (var application in applications) {
        if (application['application_id'] == appId && application['company_id'] == companyId) {
          // Remove the employee ID from the applied_by array
          application['applied_by'].removeWhere((unAppliedBy) =>
          unAppliedBy['employee_id'] == employeeId
          );
        }
      }

      // Store updated applications back to SharedPreferences
      // await storeWholeNewListOfAppliedJobsDataInSharedPref(applications);

      // Fetch the updated applications and refresh UI
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

      // Update the specific application in the list
      for (var application in applications) {
        if (application['application_id'] == appId && application['company_id'] == companyId) {
          // Check if the employee ID already exists in the saved jobs application array
          bool alreadySaved = application['save_jobs_applications']?.any((savedJobs) =>
          savedJobs['employee_id'] == employeeId) ?? false;

          if (!alreadySaved) {
            // Ensure 'save_jobs_applications' is initialized as a list before adding to it
            application['save_jobs_applications'] ??= [];
            application['save_jobs_applications'].add(newSaveJobs);
          }
        }
      }

      await storeWholeNewListWithSavedJobsDataInSharedPref(applications);
      print('----------------------Stored saved data------------------> $applications');

      // Fetch the updated applications and refresh UI
      await _fetchApplications();

    }else{
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

      // Update the specific application in the list
      for (var application in applications) {
        if (application['application_id'] == appId && application['company_id'] == companyId) {
          // Remove the employee ID from the applied_by array
          application['save_jobs_applications'].removeWhere((unSavedJob) =>
          unSavedJob['employee_id'] == employeeId
          );
        }
      }

      // Store updated applications back to SharedPreferences
      // await storeWholeNewListWithSavedJobsDataInSharedPref(applications);

      // Fetch the updated applications and refresh UI
      await _fetchApplications();

    } else {
      throw Exception('Failed to UnSaved');
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Profile employee id ------> ${employee_id}');
    return Scaffold(
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchApplications,
        child: ListView(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(height:44 ,width: 392,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: const Color(0x75484848),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(11),
                ),
                child:  TextField(
                  controller: textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Job title, keywords, or company',
                    hintStyle: TextStyle(
                      color: Color(0x75484848),
                    ),
                    border: InputBorder.none,
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
            // List of Applications
            ...filteredItems.map((application) {

              // Check if 'applied_by' is not empty
              bool isAppliedByExist = application['applied_by'] != null && application['applied_by'].isNotEmpty;
              // Determine the button text based on employee_id comparison
              String btnText = "Apply";
              if (isAppliedByExist) {
                btnText = application['applied_by'].any((appliedBy) =>
                appliedBy['employee_id'] == employee_id) ? "Unapply" : "Apply";
              }

              //check if 'save_jobs_applications' is not empty
              bool isSavedJobExist = application['save_jobs_applications'] != null && application['save_jobs_applications'].isNotEmpty;
              IconData usedIcon = Icons.bookmark_border_outlined;
              if(isSavedJobExist){
                usedIcon = application['save_jobs_applications'].any((saveJobs) =>
                saveJobs['employee_id'] == employee_id) ? Icons.bookmark : Icons.bookmark_border_outlined;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 3),
                  dataCard(
                          (){
                            //card on tap functionality
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ApplyJobsScreen(
                                  application: application,
                                  // btnText: btnText,
                                  employee_id: employee_id,
                                  btnOnTap: () async{
                                    buttonOnTapFunctionality(isAppliedByExist, application);
                                  },
                                  applyForJob: () async {
                                    await _applyForJob(employee_id, application['application_id'], application['company_id']);
                                  },
                                  unApplyForJob: () async {
                                    await _unApplyForJob(employee_id, application['application_id'], application['company_id']);
                                  },
                                  // usedIcon: usedIcon,
                                  iconTap: () async{
                                    iconTapFunctionality(isSavedJobExist, application);
                                  },

                                ),
                              ),
                            );
                          },
                      (){
                        iconTapFunctionality(isSavedJobExist,application);
                      }
                     ,(){
                          //button ontap functionality
                        buttonOnTapFunctionality(isAppliedByExist, application);
                       },
                     '${application['company_name']} | ${application['rspl_no']}',
                      'Hiring For',
                      (application['hiring_for'] as List<dynamic>).join(', '),
                      'Open Positions',
                      (application['open_positions'] as List<dynamic>).join('   '),
                      '${application['created_date']}',
                       usedIcon,
                       btnText
                  )
                ],
              );
            }).toList(),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabItemSelected: _onTabTapped,
      ),
    );
  }

  void buttonOnTapFunctionality(bool isAppliedByExist, application) {
       //button ontap functionality
    if (isAppliedByExist) {
      bool isMatched = application['applied_by'].any((appliedBy) =>
      appliedBy['employee_id'] == employee_id);

      if (isMatched) {
        // If employee_id matches, call unapply API
        _unApplyForJob(
            application['applied_by'][0]['employee_id'],
            application['application_id'],
            application['company_id']
        );
      } else {
        // If employee_id does not match, call apply API
        _applyForJob(
            employee_id,
            application['application_id'],
            application['company_id']
        );
      }
    }
    else {
      // If `applied_by` does not exist, just call apply API
      _applyForJob(
          employee_id,
          application['application_id'],
          application['company_id']
      );
    }
  }

  void iconTapFunctionality(bool isSaved, application) {
    //icon ontap functionality
    if (isSaved) {
      bool isMatched = application['save_jobs_applications'].any((savejobs) =>
      savejobs['employee_id'] == employee_id);

      if (isMatched) {
        // If employee_id matches, call unsave API
        _unSaveJob(
            application['save_jobs_applications'][0]['employee_id'],
            application['application_id'],
            application['company_id']
        );
      } else {
        // If employee_id does not match, call save API
        _saveJob(
            employee_id,
            application['application_id'],
            application['company_id']
        );
      }
    } else {
      // If `save_jobs_applications` does not exist, just call apply API
      _saveJob(
          employee_id,
          application['application_id'],
          application['company_id']
      );
    }
  }

  InkWell dataCard(VoidCallback cardOnTap,VoidCallback iconTap,VoidCallback btnOnTap, String companyAndRPSL, String hiringFor, String hiringPosition, String rankPosition, String rank, String date, IconData icon, String btnText) {
    return InkWell(onTap: cardOnTap,
      child: Card(
        elevation: 1,
        child: Container(
          color: const Color(0xFFFFFFFF),
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.only(top: 0, left: 24, right: 62),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWidget(companyAndRPSL, 'Inter', FontWeight.w400, 15, 0, 0, 0, 0, null),
                const SizedBox(height: 12),
                textWidget(hiringFor, 'Inter', FontWeight.w700, 16, 0, 0, 0, 0, null),
                const SizedBox(height: 7),
                textWidget(hiringPosition, 'Inter', FontWeight.w400, 15, 0, 0, 0, 0, null),
                const SizedBox(height: 10),
                textWidget(rankPosition, 'Inter', FontWeight.w700, 16, 0, 0, 0, 0, null),
                const SizedBox(height: 7),
                textWidget(rank, 'Inter', FontWeight.w400, 15, 0, 0, 0, 0, null),
                const SizedBox(height: 12),
                Row(
                  children: [
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        onPressed: btnOnTap,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                            side: const BorderSide(
                              width: 1,
                              color: Color(0x75484848),
                            ),
                          ),
                        ),
                        child: textWidget(btnText, 'Inter', FontWeight.w700, 14, 0, 0, 0, 0, const Color(0xFF2557A7)),
                      ),
                    ),
                    SizedBox(
                      height: 29,
                      width: 29,
                      child: IconButton(icon: Icon(icon), onPressed: iconTap,),
                    ),
                  ],
                ),
                const SizedBox(height: 10.89),
                textWidget('Posted on $date', 'Inter', FontWeight.w400, 10, 0, 0, 0, 0, const Color(0x8C000000)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding textWidget(String val, String fontFamily, FontWeight fw, double? fontSize, double top, double left, double bottom, double right, Color? color) {
    return Padding(
      padding: EdgeInsets.only(top: top, left: left, bottom: bottom, right: right),
      child: Text(
        val,
        style: TextStyle(
          fontFamily: fontFamily,
          fontWeight: fw,
          fontSize: fontSize,
          color: color,
        ),
      ),
    );

  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

