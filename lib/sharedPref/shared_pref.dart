import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> getAppliedJobsList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? appliedJobsJson = prefs.getString('appliedJobs');
  return appliedJobsJson != null
      ? List<Map<String, dynamic>>.from(jsonDecode(appliedJobsJson))
      : [];
}

Future<void> setAppliedJobsList(List<Map<String, dynamic>> appliedJobsList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('appliedJobs', jsonEncode(appliedJobsList));
}

Future<List<Map<String, dynamic>>> getSavedJobsList() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? saveJobsJson = prefs.getString('saveJobs');
  return saveJobsJson != null
      ? List<Map<String, dynamic>>.from(jsonDecode(saveJobsJson))
      : [];
}

Future<void> setSavedJobsList(List<Map<String, dynamic>> saveJobsList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('saveJobs', jsonEncode(saveJobsList));
}



