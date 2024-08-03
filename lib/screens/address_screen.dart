import 'package:flutter/material.dart';
import 'package:right_ship/services/api_service.dart';
import 'sea_experience_screen.dart';

class AddressScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const AddressScreen({required this.profileData, super.key});

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _addressData = {
    "address1": "",
    "address2": "",
    "pincode": "",
    "city": "",
    "state": "",
    "country": "",
    "nationality": "",
  };

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.profileData.addAll(_addressData);
       _addressData['employee_id'] = widget.profileData['_id'];
      print("_addressData $_addressData  ${widget.profileData}");
     

      var success = await ApiService.updateProfile(_addressData);

      
      if (success['code'] == 200) {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeaExperienceScreen(profileData: widget.profileData),
        ),
      );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update details. Please try again.')),
        );
      }

     
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTextField("Address 1", "address1"),
              _buildTextField("Address 2", "address2"),
              _buildTextField("Pincode", "pincode"),
              _buildTextField("City", "city"),
              _buildTextField("State", "state"),
              _buildTextField("Country", "country"),
              _buildTextField("Nationality", "nationality"),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: label,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
        onSaved: (value) {
          _addressData[key] = value;
        },
      ),
    );
  }
}