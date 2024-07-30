import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AccountCreatedScreen extends StatelessWidget {
  final Map<String, dynamic> profileData;

  const AccountCreatedScreen({required this.profileData, super.key});

  void _completeProfile(BuildContext context) async {
    bool success = await ApiService.updateProfile(profileData);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your Account Has Been Created',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _completeProfile(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Search Job'),
            ),
          ],
        ),
      ),
    );
  }
}