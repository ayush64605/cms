import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/otp.dart';
import 'dart:math';
import 'package:myapp/screens/sms_service.dart';

class ChangePassword extends StatefulWidget {
  final String userId; // Add this to receive the user ID

  const ChangePassword({super.key, required this.userId});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  late SmsService smsService;
  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Define _firestore here

  String _currentPassword = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentPassword();
    smsService = SmsService(
      accountSid: '',
      authToken: '',
      fromNumber: '',
    );
  }

  Future<void> _fetchCurrentPassword() async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        setState(() {
          _currentPassword = userDoc['password']; // Replace 'password' with your field name
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch password: ${e.toString()}')),
      );
    }
  }

  Future<void> _changePassword() async {
    String oldPassword = _oldPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('New password and confirm password do not match')),
      );
      return;
    }

    if (oldPassword != _currentPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Old password is incorrect')),
      );
      return;
    }

    try {
      // Update the password in Firestore
      await _firestore.collection('users').doc(widget.userId).update({
        'password': newPassword, // Ensure this is handled securely
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );

      // Optionally, clear the form or navigate back
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: ${e.toString()}')),
      );
    }
  }

  String _generateVerificationCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Generates a 4-digit code
  }

  Future<void> _sendOtp() async {
    final verificationCode = _generateVerificationCode();
    try {
      await smsService.sendSms(widget.userId, 'Your verification code is $verificationCode');
      await FirebaseFirestore.instance.collection('phoneNumbers').doc(widget.userId).update({
        'verificationCode': verificationCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OTP sent to ${widget.userId}')),
      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => OTPScreen(phoneNumber: widget.userId, isFromPassword: false, verificationCode: verificationCode, isFromchangepassword:true, isFromPhoneScreen: false,)),
        );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP: $e')),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Container with the row containing arrow, text, and image
            Container(
              color: const Color.fromARGB(255, 4, 63, 132),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.04, left: screenWidth * 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              color: Colors.white,
                              onPressed: () {
                                // Handle back navigation
                              },
                            ),
                            const Text(
                              'Change password',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Form fields
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Old Password field
                  TextFormField(
                    controller: _oldPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Old Password',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  // New Password field
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'New Password',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                  // Confirm Password field
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),

            // Save Button
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: _changePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20), // Add some space before the next button
            // Try Another Way Button
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.01),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Reset by otp',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
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
