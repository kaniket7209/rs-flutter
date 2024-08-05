import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:right_ship/services/api_service.dart';
import 'upload_resume_screen.dart';

class SeaExperienceScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;
  final String employeeId;

  const SeaExperienceScreen({required this.profileData, super.key,  required this.employeeId});

  @override
  _SeaExperienceScreenState createState() => _SeaExperienceScreenState();
}

class _SeaExperienceScreenState extends State<SeaExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<dynamic> adminAttributes = [];
  final Map<String, dynamic> _seaExperienceData = {
    "lastVesselType": "",
    "presentRank": "",
    "appliedRank": "",
    "totalSeaExperienceYears": "",
    "totalSeaExperienceMonths": "",
    "lastRankExperienceYears": "",
    "lastRankExperienceMonths": "",
    "coc": "",
    "cop": "",
    "watchKeeping": ""
  };

  @override
  void initState() {
    super.initState();
    _getAllAttributes();
  }

  Future<void> _getAllAttributes() async {
    final attributes = await ApiService.getAllAttributes();
    setState(() {
      adminAttributes = attributes;
    });
    print("adminAttributes  $adminAttributes");
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.profileData.addAll(_seaExperienceData);
      _seaExperienceData['employee_id'] = widget.employeeId;
      print("_seaExperienceData $_seaExperienceData");
      setState(() {
        _isLoading = true;
      });

      var success = await ApiService.updateProfile(_seaExperienceData);

      setState(() {
        _isLoading = false;
      });
      print("success  $success");
      if (success['code'] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UploadResumeScreen(profileData: widget.profileData),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                _buildDropdown(
                  'Last Vessel Type',
                  'lastVesselType',
                  _seaExperienceData['lastVesselType'] ?? '',
                  adminAttributes
                      .firstWhere(
                          (attr) => attr['name'].toLowerCase() == 'ship type',
                          orElse: () => {'values': []})['values']
                      .cast<String>(),
                ),
                _buildDropdown(
                  'Present Rank',
                  'presentRank',
                  _seaExperienceData['presentRank'] ?? '',
                  adminAttributes
                      .firstWhere(
                          (attr) => attr['name'].toLowerCase() == 'rank',
                          orElse: () => {'values': []})['values']
                      .cast<String>(),
                ),
                _buildDropdown(
                  'Applied Rank',
                  'appliedRank',
                  _seaExperienceData['appliedRank'] ?? '',
                  adminAttributes
                      .firstWhere(
                          (attr) => attr['name'].toLowerCase() == 'rank',
                          orElse: () => {'values': []})['values']
                      .cast<String>(),
                ),
                _buildExperienceField('Total Sea Experience',
                    'totalSeaExperienceYears', 'totalSeaExperienceMonths'),
                _buildExperienceField('Last Rank Experience',
                    'lastRankExperienceYears', 'lastRankExperienceMonths'),
                _buildDropdown(
                  'COC',
                  'coc',
                  _seaExperienceData['coc'] ?? '',
                  adminAttributes
                      .firstWhere((attr) => attr['name'].toLowerCase() == 'coc',
                          orElse: () => {'values': []})['values']
                      .cast<String>(),
                ),
                _buildDropdown(
                  'COP',
                  'cop',
                  _seaExperienceData['cop'] ?? '',
                  adminAttributes
                      .firstWhere((attr) => attr['name'].toLowerCase() == 'cop',
                          orElse: () => {'values': []})['values']
                      .cast<String>(),
                ),
                _buildDropdown(
                  'Watch Keeping',
                  'watchKeeping',
                  _seaExperienceData['watchKeeping'] ?? '',
                  adminAttributes
                      .firstWhere(
                          (attr) =>
                              attr['name'].toLowerCase() == 'watch keeping',
                          orElse: () => {'values': []})['values']
                      .cast<String>(),
                ),
                const SizedBox(height: 30),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      String label, String key, String value, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          fillColor: const Color(0xffFBF8F8),
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
        value: value.isEmpty ? null : value,
        onChanged: (String? newValue) {
          setState(() {
            _seaExperienceData[key] = newValue!;
          });
        },
        items: items.map<DropdownMenuItem<String>>((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          return null;
        },
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
          _seaExperienceData[key] = value;
        },
      ),
    );
  }

  Widget _buildExperienceField(
      String label, String keyYears, String keyMonths) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '$label (Years)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              },
              onSaved: (value) {
                _seaExperienceData[keyYears] = value;
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '(Months)',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '$label is required';
                }
                return null;
              },
              onSaved: (value) {
                _seaExperienceData[keyMonths] = value;
              },
            ),
          ),
        ],
      ),
    );
  }
}
