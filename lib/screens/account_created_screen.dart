import 'package:flutter/material.dart';
import 'package:right_ship/screens/profile_page.dart';

class AccountCreatedScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const AccountCreatedScreen({required this.profileData, super.key});

  @override
  _AccountCreatedScreenState createState() => _AccountCreatedScreenState();
}

class _AccountCreatedScreenState extends State<AccountCreatedScreen> {
  void _submit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          profileData: widget.profileData,
          employeeId: widget.profileData['_id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: const Text(
                'Your Account Has Been ',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
              ),
            ),
            Center(
              child: const Text(
                'Created ',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w500,fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 40),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey,
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: const Color(0xff2E5C99),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Center(
                  child: Text(
                    'Search job',
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
    );
  }
}