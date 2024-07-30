import 'package:flutter/material.dart';
import 'upload_resume_screen.dart';

class SeaExperienceScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const SeaExperienceScreen({required this.profileData, super.key});

  @override
  _SeaExperienceScreenState createState() => _SeaExperienceScreenState();
}

class _SeaExperienceScreenState extends State<SeaExperienceScreen> {
  final _formKey = GlobalKey<FormState>();
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
    "watchKeeping": "",
    "willingToAcceptLowerRank": "",
  };

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.profileData.addAll(_seaExperienceData);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UploadResumeScreen(profileData: widget.profileData),
        ),
      );
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextField("Last Vessel Type", "lastVesselType"),
                _buildTextField("Present Rank", "presentRank"),
                _buildTextField("Applied Rank", "appliedRank"),
                _buildExperienceField("Total Sea Experience", "totalSeaExperienceYears", "totalSeaExperienceMonths"),
                _buildExperienceField("Last Rank Experience", "lastRankExperienceYears", "lastRankExperienceMonths"),
                _buildTextField("COC", "coc"),
                _buildTextField("COP", "cop"),
                _buildTextField("Watch Keeping", "watchKeeping"),
                _buildTextField("Willing to accept lower rank", "willingToAcceptLowerRank"),
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

  Widget _buildExperienceField(String label, String keyYears, String keyMonths) {
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