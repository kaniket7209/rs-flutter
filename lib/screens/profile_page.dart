import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:file_picker/file_picker.dart';

class ProfilePage extends StatefulWidget {
  final String employeeId;

  const ProfilePage({required this.employeeId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profileData;

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
        title: const Text('Profile'),
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    _buildSectionTitle('Date of Availability'),
                    _buildDetailTile(
                        'Date of Availability',
                        'dateOfAvailability',
                        _profileData!['dateOfAvailability'] ?? '',
                        isDate: true),
                    _buildSectionTitle('Contact Detail'),
                    _buildDetailTile('Enter your full name', 'name',
                        _profileData!['name'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile('Enter your designation', 'designation',
                        _profileData!['designation'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile(
                        'Email ID', 'emailid', _profileData!['emailid'] ?? '',
                        inputType: TextInputType.emailAddress),
                    _buildDetailTile('Contact', 'mobile_no',
                        _profileData!['mobile_no'] ?? '',
                        inputType: TextInputType.phone),
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
                    _buildSectionTitle('Type of Ship Experience'),
                    _buildDetailTile('Ship Name', 'shipName',
                        _profileData!['shipName'] ?? '',
                        inputType: TextInputType.text),
                    _buildSectionTitle('Last Vessel Type'),
                    _buildDetailTile('Ship Name', 'lastVesselType',
                        _profileData!['lastVesselType'] ?? '',
                        inputType: TextInputType.text),
                    _buildSectionTitle('Vessel Applied For'),
                    _buildDetailTile('Ship Name', 'vesselAppliedFor',
                        _profileData!['vesselAppliedFor'] ?? '',
                        inputType: TextInputType.text),
                    _buildSectionTitle('License Holding'),
                    _buildDetailTile('COC', 'coc', _profileData!['coc'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile('COP', 'cop', _profileData!['cop'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile('Watch Keeping', 'watchKeeping',
                        _profileData!['watchKeeping'] ?? '',
                        inputType: TextInputType.text),
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
                    _buildDetailTile(
                        'Country', 'country', _profileData!['country'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile(
                        'Pincode', 'pincode', _profileData!['pincode'] ?? '',
                        inputType: TextInputType.number),
                    _buildDetailTile('Nationality', 'nationality',
                        _profileData!['nationality'] ?? '',
                        inputType: TextInputType.text),
                    _buildSectionTitle('Co-win Vaccination'),
                    _buildDetailTile('1st Dose', 'firstDose',
                        _profileData!['firstDose'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile('2nd Dose', 'secondDose',
                        _profileData!['secondDose'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile(
                        'Booster', 'booster', _profileData!['booster'] ?? '',
                        inputType: TextInputType.text),
                    _buildSectionTitle('Others'),
                    _buildDetailTile(
                        'Height (Cm)', 'height', _profileData!['height'] ?? '',
                        inputType: TextInputType.number),
                    _buildDetailTile(
                        'Weight (Kg)', 'weight', _profileData!['weight'] ?? '',
                        inputType: TextInputType.number),
                    _buildDetailTile('BMI', 'bmi', _profileData!['bmi'] ?? '',
                        inputType: TextInputType.number),
                    _buildDetailTile(
                        'SID Card', 'sidCard', _profileData!['sidCard'] ?? '',
                        inputType: TextInputType.text),
                    _buildDetailTile(
                        'Willing to accept lower rank',
                        'acceptLowerRank',
                        _profileData!['acceptLowerRank'] ?? '',
                        inputType: TextInputType.text),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
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
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _profileData!['name'] ?? 'Name not available',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _profileData!['designation'] ?? 'Designation not available',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => _selectAndUploadFile(),
                icon: const Icon(Icons.upload_file),
                label: Text(_profileData!['resume'] != null
                    ? _profileData!['resume']!.split('_').last
                    : 'Upload resume'),
              ),
            ],
          ),
        ),
      ],
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
          fontSize: 18,
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
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
      subtitle: Text(
        value.isNotEmpty ? value : 'Not available',
        style: const TextStyle(fontSize: 16),
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
}
