import 'package:flutter/material.dart';
// import 'package:right_ship/screens/profile_creation_screen.dart';
import 'package:right_ship/screens/profile_page.dart';
import '../services/api_service.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String origin;

  const OTPVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.origin,
  }) : super(key: key);

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 30;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  void _verifyOTP() async {
    setState(() {
      _isLoading = true;
    });

    String otp = _otpControllers.map((controller) => controller.text).join();
    var success = await ApiService.verifyOTP(widget.phoneNumber, otp);

    setState(() {
      _isLoading = false;
    });

    if (success['code'] == 200) {
      var data;
      if (widget.origin == 'register') {
        data = await ApiService.register(widget.phoneNumber);
      } else {
        data = await ApiService.login(widget.phoneNumber);
      }

      print("data is $data");

      if (data != null && data['code'] == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                // ProfileCreationScreen(employeeId: data['employee']['_id']),
                ProfilePage(employeeId: data['employee']['_id'])
          ),
        );
      } else {
        _showErrorToast(data['msg']);
      }
    } else {
      _showErrorToast(success['message']);
    }
  }

  void _resendOTP() async {
    setState(() {
      _isResending = true;
      _resendCountdown = 30;
    });

    bool success = await ApiService.sendOTP(widget.phoneNumber);

    setState(() {
      _isResending = false;
    });

    if (!success) {
      _showErrorToast('Failed to resend OTP. Please try again.');
    } else {
      _startResendCountdown();
    }
  }

  void _startResendCountdown() {
    Future.doWhile(() async {
      if (_resendCountdown > 0) {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _resendCountdown--;
        });
        return true;
      }
      return false;
    });
  }

  void _showErrorToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
            const Text(
              'Verify With OTP',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'OTP sent to ${widget.phoneNumber}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    maxLength: 1,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        FocusScope.of(context).nextFocus();
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).previousFocus();
                      }
                    },
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Verify OTP'),
                  ),
            const SizedBox(height: 16),
            if (_isResending)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _resendCountdown == 0 ? _resendOTP : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  _resendCountdown == 0
                      ? 'Resend OTP'
                      : 'Resend OTP in : $_resendCountdown',
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Change phone number'),
            ),
          ],
        ),
      ),
    );
  }
}
