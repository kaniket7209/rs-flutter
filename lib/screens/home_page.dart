import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:right_ship/screens/custom_bottom_navbar.dart';
import 'dart:convert';

import 'package:right_ship/screens/profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> applications = [];
  bool isLoading = true;
  Map<String, dynamic> employee_data = {};
   int _currentIndex = 0;

  void _onTabTapped(int index) {
    if (index == 3 && _currentIndex != 3) {
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
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchApplications();
    _fetchPrefsData();
  }

  Future<void> _fetchPrefsData() async {
    final prefs = await SharedPreferences.getInstance();
    String? existingEmployeeData = prefs.getString('employee_data');
    if (existingEmployeeData != null) {
      // Parse the existing data

      setState(() {
        employee_data = json.decode(existingEmployeeData);
      });

      // Merge the new data with the existing data
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
      print("applications data $data");

      setState(() {
        applications = data['applications'];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load applications');
    }
  }

  

  @override
  Widget build(BuildContext context) {
    print("applications $applications");
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Job title, keywords, or company',
              border: InputBorder.none,
              fillColor: Colors.white,
              filled: true,
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchApplications,
              child: ListView.builder(
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final application = applications[index];
                  return Card(
                    margin: const EdgeInsets.all(10.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${application['company_name']} | ${application['rspl_no']}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          SizedBox(height: 8),
                          Text('Hiring For'),
                          Text(
                            application['hiring_for'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Open Positions'),
                          Text(
                            application['open_positions'].join('   '),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('Apply'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff1F5882),
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(
                                icon: Icon(Icons.bookmark_border),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Posted on ${application['created_date']}',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabItemSelected: _onTabTapped,
      ),
    );
  }
}
