import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:right_ship/screens/sea_experience_screen.dart';
import '../services/api_service.dart';


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
    "email": "",
    "whatsappNumber": "",
    "dateOfBirth": "",
    "gender": "",
    "dateOfAvailability": "",
    "country": "",
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

      var success = await ApiService.updateProfile(_profileData);

      setState(() {
        _isLoading = false;
      });

      if (success['code'] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SeaExperienceScreen(profileData: _profileData),
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
        top: 20,
        left: 30.0,
        right: 30.0,
        // bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: IntrinsicHeight(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Basic Detail',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                    
                  ],
                ),
                const SizedBox(height: 20),
                _buildTextField("Name *", "name"),
              
                _buildTextField("Email *", "email"),
                _buildTextField("WhatsApp Number", "whatsappNumber"),
                _buildDateField("Date Of Birth *", "dateOfBirth"),
                _buildDropdownField("Gender *", "gender", ["Male", "Female", "Prefer not to say"]),
                _buildDateField("Date of Availability", "dateOfAvailability"),
                _buildTextField("Country", "country"),
                const SizedBox(height: 20),
                if (_isLoading)
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                if (!_isLoading)
                  GestureDetector(
                    onTap: _submit,
                    child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Color(0xff2E5C99),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: const Text(
                          'Next',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
  

 Widget _buildDropdownField(String label, String key, List<String> items) {
  String? initialValue = _profileData[key];

  // If the initial value is not in the items list, set it to null
  if (!items.contains(initialValue)) {
    initialValue = null;
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        
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
      value: initialValue, // Set the initial value
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item,style: TextStyle(fontWeight: FontWeight.normal),),
        );
      }).toList(),
      validator: (value) {
        if (label.contains('*')) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          _profileData[key] = value;
        });
      },
      onSaved: (value) {
        _profileData[key] = value;
      },
    ),
  );
}
  Widget _buildDateField(String label, String key) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _profileData[key] = pickedDate.toLocal().toString().split(' ')[0];
          });
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
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
            if (label.contains('*')) {
              if (value == null || value.isEmpty) {
                return '$label is required';
              }
            }
            return null;
          },
          controller: TextEditingController(
            text: _profileData[key],
          ),
          onSaved: (value) {
            _profileData[key] = value;
          },
        ),
      ),
    ),
  );
}
  
  Widget _buildTextField(String label, String key) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10.0),
    child: TextFormField(
      decoration: InputDecoration(
        labelText: label,
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
        if (label.contains('*')) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
        }
        return null;
      },
      onSaved: (value) {
        _profileData[key] = value;
      },
    ),
  );
}
}
