import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:right_ship/screens/profile_page.dart';
import '../services/api_service.dart';
import 'account_created_screen.dart';

class UploadPhotoScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const UploadPhotoScreen({required this.profileData, super.key});

  @override
  _UploadPhotoScreenState createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _uploadedFileUrl;
  File? _image;
  bool _isLoading = false;

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _image = File(pickedFile.path);
  //     });
  //   }
  // }
  Future<void> _pickImage() async {
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
          _uploadedFileUrl = fileUrl;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Failed to upload profile photo. Please try again.')),
        );
      }
    }
  }

  void _skip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
            profileData: widget.profileData,
            employeeId: widget.profileData['_id']),
      ),
    );
  }

  Future<void> _submit() async {
    if (_uploadedFileUrl != null) {
      setState(() {
        _isLoading = true;
      });

      var success = await ApiService.updateProfile({
        "profile_photo": _uploadedFileUrl,
        "employee_id": widget.profileData['_id']
      });

      setState(() {
        _isLoading = false;
      });
      if (success['code'] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AccountCreatedScreen(profileData: widget.profileData),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to update profile photo. Please try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please upload your profile photo before proceeding.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Text(
              'Upload Photo',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Receive 2x job offers after uploading',
              style: TextStyle(fontSize: 18, color: Color(0xff00861D)),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width:200,
               
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: _image == null
                    ? (_uploadedFileUrl == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.upload, size: 50, color: Colors.grey),
                              SizedBox(height: 10),
                              Text('Upload your photo'),
                            ],
                          )
                        : ClipOval(
                            child: Image.network(
                              _uploadedFileUrl!,
                              fit: BoxFit.cover,
                              width: 150,
                              height: 150,
                            ),
                          ))
                    : ClipOval(
                        child: Image.file(
                          _image!,
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            if (_uploadedFileUrl == null) ...[
              const Text(
                'add your photo to',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontFamily: 'Poppins'),
              ),
              const Text(
                'Profile',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins'),
              ),
            ] else ...[
              Text(
                _uploadedFileUrl!.split('_').last,
                style: TextStyle(color: Color(0xff1F5882), fontSize: 20),
              )
            ],
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
                  child: 
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
                ),
              ],
            ),

            // if (_isLoading)
            //   const SizedBox(height: 20),
            //   const CircularProgressIndicator(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
