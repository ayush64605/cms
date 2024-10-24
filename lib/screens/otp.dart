import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:myapp/screens/password.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/update_password.dart';
import 'package:myapp/screens/materialside.dart'; // Add this import for the MaterialSide screen

class OTPScreen extends StatefulWidget {
  final String phoneNumber; // Pass the phone number to this screen
  final bool isFromPassword; // New parameter to check the origin screen
  final String verificationCode;
  final bool isFromPhoneScreen; // New parameter to check the origin screen
  final bool isFromchangepassword; // New parameter to check the origin screen

  OTPScreen({
    required this.phoneNumber,
    required this.isFromPassword,
    required this.verificationCode,
    required this.isFromPhoneScreen,
    required this.isFromchangepassword,
  });

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String? verificationCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchOtpFromFirebase(); // Fetch the OTP from Firebase
  }

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _fetchOtpFromFirebase() async {
    try {
      print('Fetching OTP for phone number: ${widget.phoneNumber}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('phoneNumbers') // Ensure this is your correct collection name
          .where('phoneNumber', isEqualTo: widget.phoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        verificationCode = doc['verificationCode'];
        print('Verification code fetched from Firestore: $verificationCode');
      } else {
        print('No document found for the provided phone number.');
      }
    } catch (e) {
      print('Error fetching verification code: $e');
    }
  }

  void _onOtpChanged(String value) {
    if (value.length == 4) {
      _otpFocusNode.unfocus();
    }
  }

  void _verifyOtp() async {
    setState(() {
      _isLoading = true;
    });

    print('User entered OTP: ${_otpController.text}');
    print('Verification code fetched: $verificationCode');

    if (_otpController.text.trim() == verificationCode?.trim()) {
      if (widget.isFromPassword) {
        // If the user came from PasswordScreen, fetch profession and redirect accordingly
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.phoneNumber)
            .get();

        if (userDoc.exists) {
          final profession = userDoc['profession'];
          if (profession == 'owner') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectScreen(
                  userId: widget.phoneNumber,
                ),
              ),
            );
          } else if (profession == 'Material supplier') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Materialside(
                  userId: widget.phoneNumber,
                ),
              ),
            );
          } 
        } else {
          print('No user document found for the provided phone number.');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not found')),
          );
        }
      } else if (widget.isFromchangepassword) {
        // Otherwise, redirect to UpdatePassword
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdatePassword(
              phoneNumber: widget.phoneNumber,
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordScreen(
              phoneNumber: widget.phoneNumber,
              isFromOtp: true,
              isFromPhoneScreen: false,
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP')),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;

    final double imageTopPadding = 240.0;
    final double imageLeftRightPadding = screenWidth * 0.10;
    final double adjustedImageTopPadding =
        isKeyboardVisible ? 120.0 : imageTopPadding;
    final double adjustedImageLeftRightPadding =
        isKeyboardVisible ? screenWidth * 0.15 : imageLeftRightPadding;
    final double imageScale = isKeyboardVisible ? 0.5 : 1.0;
    final double bottomPadding = isKeyboardVisible ? keyboardHeight + 20 : 100;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.08,
            left: 0,
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.36),
                  child: Text(
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.15),
                  child: Text(
                    'Enter the OTP sent to your phone',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: adjustedImageTopPadding,
            left: adjustedImageLeftRightPadding,
            right: adjustedImageLeftRightPadding,
            child: Transform.scale(
              scale: imageScale,
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 800),
                child: Image.asset(
                  'asset/otp.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: bottomPadding,
            left: screenWidth * 0.10,
            right: screenWidth * 0.10,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter OTP',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    onChanged: _onOtpChanged,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      //borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Verify',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
