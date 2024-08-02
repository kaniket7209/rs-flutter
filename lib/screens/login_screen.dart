import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:right_ship/screens/otp_verification_screen.dart';
import 'package:right_ship/screens/profile_creation_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import 'package:right_ship/screens/sea_experience_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _sendOTP() async {
    setState(() {
      _isLoading = true;
    });
    bool success = await ApiService.sendOTP(_phoneController.text);
    setState(() {
      _isLoading = false;
    });
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            phoneNumber: _phoneController.text,
            origin: 'login',
          ),
        ),
      );
    } else {
      _showErrorToast('Failed to send OTP. Please try again.');
    }
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 100),
          child: Padding(
            padding: EdgeInsets.only(
              top: 10,
              left: 30.0,
              right: 30.0,
              bottom: MediaQuery.of(context).viewInsets.bottom + 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter phone number',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Poppins'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your registered phone number here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xff1F5882)),
                      ),
                      fillColor: Color(0xffFBF8F8),
                      hintText: 'Enter Phone number ',
                      hintStyle:
                          TextStyle(color: Colors.black.withOpacity(0.4))),
                ),
                const SizedBox(height: 25),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                        onTap: _sendOTP,
                        child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.8,
                            padding: EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Color(0xff2E5C99),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Center(
                                child: const Text(
                              'Send OTP',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ))),
                      ),
                const SizedBox(height: 40),
                Divider(),
                const SizedBox(height: 40),
                GestureDetector(
                  onTap: () {
                    // Navigate to Register Screen
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Container(
                      width: MediaQuery.sizeOf(context).width * 0.8,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Color(0xff2E5C99),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                          child: const Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ))),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
