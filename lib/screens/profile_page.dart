import 'dart:io';

import 'package:flutter/material.dart';
import 'package:right_ship/screens/custom_bottom_navbar.dart';
import 'package:right_ship/screens/home_page.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfilePage extends StatefulWidget {
  final String employeeId;
  final Map<String, dynamic> profileData;

  const ProfilePage({required this.employeeId, required this.profileData});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;
  int _currentIndex = 3;

  void _onTabTapped(int index) {
    if (index == 0 && _currentIndex != 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    String? profileData = prefs.getString('employee_data');
    print("profileDatais $profileData");
    if (profileData != null) {
      setState(() {
        _profileData = jsonDecode(profileData);
      });
    }
  }

  Future<void> _updateProfile() async {
    print("_profileData $_profileData");

    // Check if _id exists in _profileData
    if (_profileData!.containsKey('_id')) {
      _profileData!['employee_id'] = _profileData!['_id'];

      // Call the updateProfile API
      final response = await ApiService.updateProfile(_profileData!);

      if (response['code'] == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employee_data', jsonEncode(_profileData));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('employee_id is not present in the payload.')),
      );
    }
  }

 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Container(
          alignment: Alignment.topLeft,
          child: Image.asset(
            'assets/images/logo.png', // Replace with your actual image path
            height: 40, // Adjust the height as needed
          ),
        ),
        centerTitle: true, // Center the image in the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _profileData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                color: Color(0xffF1F1F1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    _buildProfileHeader(),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                        padding: EdgeInsets.all(25),
                        color: Colors.white,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                print(
                                    "_profileData!['resume']  ${_profileData!['resume']!}");
                                if (_profileData!['resume'] != null) {
                                  // Open the PDF in view mode

                                  _openPdf(_profileData!['resume']!);
                                }
                              },
                              child:
                                  Icon(Icons.picture_as_pdf, color: Colors.red),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                _profileData!['resume'] != null
                                    ? _profileData!['resume']!.split('_').last
                                    : 'Upload resume',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _selectAndUploadFile(),
                              child: Image.asset('assets/images/Edit.png',
                                  height: 24, width: 24),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailTile(
                              'Date of Availability',
                              'dateOfAvailability',
                              _profileData!['dateOfAvailability'] ?? '',
                              isDate: true),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Contact Detail'),
                          _buildDetailTile('Enter your full name', 'name',
                              _profileData!['name'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile(
                              'Email ID', 'email', _profileData!['email'] ?? '',
                              inputType: TextInputType.emailAddress),
                          _buildDetailTile('WhatsApp Number', 'whatsappNumber',
                              _profileData!['whatsappNumber'] ?? '',
                              inputType: TextInputType.phone),
                          _buildDetailTile('Date of Birth', 'dateOfBirth',
                              _profileData!['dateOfBirth'] ?? '',
                              isDate: true),
                          _buildDropdown(
                              'Gender',
                              'gender',
                              _profileData!['gender'] ?? '',
                              ['Male', 'Female', 'Prefer not to say']),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Experience'),
                          _buildDetailTile(
                              'Total Sea Experience (years)',
                              'totalSeaExperience',
                              _profileData!['totalSeaExperience'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile(
                              'Total Last Rank Experience',
                              'totalLastRankExperience',
                              _profileData!['totalLastRankExperience'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Present Rank', 'presentRank',
                              _profileData!['presentRank'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Last Rank', 'lastRank',
                              _profileData!['lastRank'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Type of Ship Experience'),
                          _buildDetailTile('Ship Name', 'shipName',
                              _profileData!['shipName'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Last Vessel Type'),
                          _buildDetailTile('Ship Name', 'lastVesselType',
                              _profileData!['lastVesselType'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Vessel Applied For'),
                          _buildDetailTile('Ship Name', 'vesselAppliedFor',
                              _profileData!['vesselAppliedFor'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('License Holding'),
                          _buildDetailTile(
                              'COC', 'coc', _profileData!['coc'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile(
                              'COP', 'cop', _profileData!['cop'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Watch Keeping', 'watchKeeping',
                              _profileData!['watchKeeping'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Address'),
                          _buildDetailTile('Address 1', 'address1',
                              _profileData!['address1'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Address 2', 'address2',
                              _profileData!['address2'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile(
                              'City', 'city', _profileData!['city'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile(
                              'State', 'state', _profileData!['state'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Country', 'country',
                              _profileData!['country'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Pincode', 'pincode',
                              _profileData!['pincode'] ?? '',
                              inputType: TextInputType.number),
                          _buildDetailTile('Nationality', 'nationality',
                              _profileData!['nationality'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Co-win Vaccination'),
                          _buildDetailTile('1st Dose', 'firstDose',
                              _profileData!['firstDose'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('2nd Dose', 'secondDose',
                              _profileData!['secondDose'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile('Booster', 'booster',
                              _profileData!['booster'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Others'),
                          _buildDetailTile('Height (Cm)', 'height',
                              _profileData!['height'] ?? '',
                              inputType: TextInputType.number),
                          _buildDetailTile('Weight (Kg)', 'weight',
                              _profileData!['weight'] ?? '',
                              inputType: TextInputType.number),
                          _buildDetailTile(
                              'BMI', 'bmi', _profileData!['bmi'] ?? '',
                              inputType: TextInputType.number),
                          _buildDetailTile('SID Card', 'sidCard',
                              _profileData!['sidCard'] ?? '',
                              inputType: TextInputType.text),
                          _buildDetailTile(
                              'Willing to accept lower rank',
                              'acceptLowerRank',
                              _profileData!['acceptLowerRank'] ?? '',
                              inputType: TextInputType.text),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
      
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTabItemSelected: _onTabTapped,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _selectAndUploadProfilePhoto(),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileData!['profile_photo'] != null &&
                      _profileData!['profile_photo']!.isNotEmpty
                  ? NetworkImage(_profileData!['profile_photo']!)
                  : AssetImage('assets/images/noProfilePhoto.png')
                      as ImageProvider,
            ),
          ),
          const SizedBox(height: 16),
          if (_profileData!['name'] != null &&
              _profileData!['surname'] != null) ...[
            Text(
              '${_profileData!['name']} ${_profileData!['surname']}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] else ...[
            Text(
              'Name not available',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xff1F5882),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 2),
            child: Text(
              _profileData!['presentRank'] ?? 'Designation not available',
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 8),
          //resume
        ],
      ),
    );
  }

  Future<void> _selectAndUploadProfilePhoto() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      // Upload the file
      String? fileUrl = await ApiService.uploadFile(file);

      if (fileUrl != null && fileUrl.isNotEmpty) {
        // Update the profile with the new file URL
        setState(() {
          _profileData!['profile_photo'] = fileUrl;
        });
        await _updateProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Failed to upload profile photo. Please try again.')),
        );
      }
    }
  }

  Future<void> _selectAndUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);

      // Upload the file
      String? fileUrl = await ApiService.uploadFile(file);

      if (fileUrl != null && fileUrl.isNotEmpty) {
        // Update the profile with the new file URL
        _profileData!['resume'] = fileUrl;
        await _updateProfile();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to upload file. Please try again.')),
        );
      }
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, String key, String selectedValue, List<String> options) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
      subtitle: DropdownButton<String>(
        value: selectedValue.isNotEmpty ? selectedValue : null,
        hint: Text('Select $label'),
        isExpanded: true,
        onChanged: (String? newValue) async {
          if (newValue != null) {
            setState(() {
              _profileData![key] = newValue;
            });
            await _updateProfile();
          }
        },
        items: options.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailTile(String label, String key, String value,
      {TextInputType inputType = TextInputType.text, bool isDate = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 1.0),
      title: Text(
        label,
        style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins'),
      ),
      subtitle: Text(
        value.isNotEmpty ? value : 'Not available',
        style: const TextStyle(fontSize: 18, fontFamily: 'Poppins'),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _editField(key, label, inputType, isDate: isDate),
      ),
    );
  }

  void _editField(String key, String label, TextInputType inputType,
      {bool isDate = false}) async {
    if (isDate) {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2100),
      );
      if (pickedDate != null) {
        setState(() {
          _profileData![key] = DateFormat('dd MMM, yyyy').format(pickedDate);
        });
        await _updateProfile();
      }
    } else {
      TextEditingController _controller =
          TextEditingController(text: _profileData![key] ?? '');
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit $label'),
            content: TextField(
              controller: _controller,
              keyboardType: inputType,
              decoration: InputDecoration(hintText: 'Enter $label'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _profileData![key] = _controller.text;
                  });
                  Navigator.of(context).pop();
                  await _updateProfile();
                },
                child: Text('Save'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _openPdf(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error opening URL: $e');
    }
  }
}
