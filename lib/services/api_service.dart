import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://api.rightships.com';

  static Future<bool> sendOTP(String mobileNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/send_otp'),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile_no': mobileNo,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      return responseBody['code'] == 200;
    } else {
      return false;
    }
  }

  static Future<dynamic> verifyOTP(String mobileNo, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/otp/verify_otp'),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile_no': mobileNo,
        'otp': otp,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("verifyOtpRes $responseBody");
      return responseBody;
    } else {
      return {"code":500,"msg":"Unexpected error"};
    }
  }





  static Future<dynamic> login(String mobileNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/login'),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile_no': mobileNo,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);

      // Save data locally
      print("login response $responseBody");
      if (responseBody['code'] == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employeeId', responseBody['employee']['_id']);
        await prefs.setString('employee_data', jsonEncode(responseBody['employee']));
        await prefs.setString('mobileNo', mobileNo);
      }
      return responseBody;
    } else {
      return {"code": 500, "msg": "Login Unsuccessful"};
    }
  }

  static Future<dynamic> register(String mobileNo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/register'),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'mobile_no': mobileNo,
      }),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("registerRes $responseBody");
      // Save data locally
      if (responseBody['code'] == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('employeeId', responseBody['employee']['_id']);
        await prefs.setString('employee_data', jsonEncode(responseBody['employee']));
        await prefs.setString('mobileNo', mobileNo);
      }

      return responseBody;
    } else {
      return {"code": 500, "msg": "Registration failed "};
    }
  }

  static Future<dynamic> updateProfile(Map<String, dynamic> profileData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/employee/update'),
      headers: {
        'Accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(profileData),
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      print("resUpdProfile  $responseBody");
      return responseBody;
    } else {
      return {"code":500,"msg":"Unexpected error"};
    }
  }

 static Future<String?> uploadFile(File file) async {
  var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

  // Determine the MIME type of the file
  String? mimeType = lookupMimeType(file.path);
  if (mimeType == null) {
    return null;
  }
  List<String> mimeTypeParts = mimeType.split('/');

  request.files.add(
    await http.MultipartFile.fromPath(
      'file',
      file.path,
      contentType: MediaType(mimeTypeParts[0], mimeTypeParts[1]),
    ),
  );

  request.headers.addAll({
    'Accept': '*/*',
    'User-Agent': 'Thunder Client (https://www.thunderclient.com)',
  });

  var response = await request.send();

  if (response.statusCode == 200) {
    final responseBody = await response.stream.bytesToString();
    final Map<String, dynamic> jsonResponse = json.decode(responseBody);
    return jsonResponse['file_url']; // Assuming the response contains the file URL in 'file_url'
  } else {
    return null;
  }
}
  static Future<void> logout(BuildContext context) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Clear all stored preferences
    await prefs.clear();

    // Navigate to the login screen
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }
}
