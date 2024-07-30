import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'address_screen.dart';

class ProfileCreationScreen extends StatefulWidget {
  final String employeeId;
  const ProfileCreationScreen({super.key, required this.employeeId});

  @override
  _ProfileCreationScreenState createState() => _ProfileCreationScreenState();
}

class _ProfileCreationScreenState extends State<ProfileCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  final Map<String, dynamic> _profileData = {
    "name": "",
    "surname": "",
    "contactNumber": "",
    "email": "",
    "whatsappNumber": "",
    "dateOfBirth": "",
    "gender": "",
    "dateOfAvailability": ""
  };

  void _submit() async {
    print(widget.employeeId);
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _profileData['employee_id'] = widget.employeeId;
      print("_profileData $_profileData");

      setState(() {
        _isLoading = true;
      });

      bool success = await ApiService.updateProfile(_profileData);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddressScreen(profileData: _profileData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update profile. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
          left: 30.0,
          right: 30.0,
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  alignment: Alignment.topLeft,
                  child: Text(
                    textAlign: TextAlign.left,
                    'Basic Detail',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins'),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField("Name *", "name"),
                _buildTextField("Surname *", "surname"),
                _buildTextField("Contact Number *", "contactNumber"),
                _buildTextField("Email *", "email"),
                _buildTextField("WhatsApp Number", "whatsappNumber"),
                _buildTextField("Date Of Birth *", "dateOfBirth"),
                _buildTextField("Gender *", "gender"),
                _buildTextField("Date of Availability", "dateOfAvailability"),
                const SizedBox(height: 20),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Next'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: InputDecoration(
              fillColor: const Color(0xffFBF8F8), // Light grey color
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 10.0),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xff1F5882)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
              return null;
            },
            onSaved: (value) {
              _profileData[key] = value;
            },
          ),
        ],
      ),
    );
  }
}
