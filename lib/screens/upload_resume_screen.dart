import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';
import 'upload_photo_screen.dart';
import 'package:right_ship/services/api_service.dart';

class UploadResumeScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const UploadResumeScreen({required this.profileData, super.key});

  @override
  _UploadResumeScreenState createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _uploadedFileUrl;
  bool _isLoading = false;
  final Map<String, dynamic> resumeDetails = {"resume": ""};

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
        setState(() {
          _isLoading = false;
          _uploadedFileUrl = fileUrl;
          widget.profileData['resume'] = fileUrl;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to upload file. Please try again.')),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_uploadedFileUrl != null) {
      setState(() {
        _isLoading = true;
      });

      var success = await ApiService.updateProfile({"resume":_uploadedFileUrl,"employee_id":widget.profileData['_id']});

      setState(() {
        _isLoading = false;
      });
      if (success['code'] == 200) {
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadPhotoScreen(profileData: widget.profileData),
        ),
      );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update details. Please try again.')),
        );
      }
     
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please upload your resume before proceeding.')),
      );
    }
  }
  void _skip() {
    
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              UploadPhotoScreen(profileData: widget.profileData),
        ),
      );
  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Upload your Resume!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold,fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Receive 2x job offers after uploading',
                style: TextStyle(fontSize: 18, color: Color(0xff00861D)),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: _selectAndUploadFile,
                child: Container(
                  // height: 250,
                  width: double.infinity,
                 
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _isLoading
                          ? const CircularProgressIndicator()
                          : Image.asset(
                              'assets/images/folder.png',
                              height: 200,
                              width: 200,
                            ),
                      const SizedBox(height: 10),
                      if(_uploadedFileUrl == null)...[const Text(
                        'Upload .pdf & .docx file only',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const Text(
                        'max file size 5MB only',
                        style: TextStyle(color: Colors.red),
                      ),]
                      else...[
                          Text(
                        _uploadedFileUrl!.split('_').last,
                        style: TextStyle(color: Color(0xff1F5882),fontSize: 20),
                      )
                      ]
                      
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Unlock jobs from top companies faster.\nGet jobs specifically suited for your rank.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20,height: 1.7),
              ),
              const Spacer(),
              Row(
                children: [
                 Expanded(
                   child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.8,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Center(
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: Color(0xff1F5882),
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                 ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
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
                  ),
                ],
              ),
           
            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
