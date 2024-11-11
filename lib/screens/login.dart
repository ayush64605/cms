import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:myapp/screens/otp.dart';
import 'package:myapp/screens/sms_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/password.dart'; // Ensure this path is correct

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  late SmsService smsService;
  String _countryCode = '+91'; // Default country code
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    smsService = SmsService(
      accountSid: '',
      authToken: '',
      fromNumber: '',
    );
  }

  Future<void> _storePhoneNumber(
      String phoneNumber, String verificationCode) async {
    try {
      await FirebaseFirestore.instance
          .collection('phoneNumbers')
          .doc(phoneNumber)
          .set({
        'phoneNumber': phoneNumber,
        'verificationCode': verificationCode,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Phone number stored successfully');
    } catch (e) {
      print('Error storing phone number: $e');
    }
  }

  Future<bool> _checkIfPhoneNumberExists(String phoneNumber) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .get();
      return querySnapshot.exists;
    } catch (e) {
      print('Error checking phone number: $e');
      return false;
    }
  }

  String _generateVerificationCode() {
    final random = Random();
    return (1000 + random.nextInt(9000)).toString(); // Generates a 4-digit code
  }

  Future<void> _handleSubmit() async {
    final phoneNumber = _phoneController.text.trim();

    // Validate phone number format
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid phone number.')),
      );
      return;
    }

    final fullPhoneNumber = _countryCode + phoneNumber;
    setState(() {
      _isLoading = true;
    });

    try {
      final exists = await _checkIfPhoneNumberExists(fullPhoneNumber);

      if (exists) {
        // Store login state and user ID
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', fullPhoneNumber);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PasswordScreen(
              phoneNumber: fullPhoneNumber,
              isFromOtp: false,
              isFromPhoneScreen: true,
            ), // Redirect to PasswordScreen
          ),
        );
      } else {
        final verificationCode = _generateVerificationCode();
        await _storePhoneNumber(fullPhoneNumber, verificationCode);

        try {
          await smsService.sendSms(
              fullPhoneNumber, 'Your verification code is $verificationCode');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                  phoneNumber: fullPhoneNumber,
                  verificationCode: verificationCode,
                  isFromPassword: false,
                  isFromchangepassword: false,
                  isFromPhoneScreen: true),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send SMS: $e')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
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
                    padding: EdgeInsets.only(left: screenWidth * 0.25),
                    child: Text(
                      'Continue with phone',
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
                      'Please confirm your mobile number',
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
                    'asset/phone.png',
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
                    child: IntlPhoneField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Enter your phone number',
                        prefixIcon: Icon(Icons.phone),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(1, 42, 86, 1),
                              width: 2.0), // Change to your preferred color
                        ),
                      ),
                      initialCountryCode: 'IN', // Initial country code
                      onChanged: (phone) {
                        setState(() {
                          _countryCode = phone.countryCode;
                        });
                      },
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),
                          )
                        : Text(
                            'Next',
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
      ),
    );
  }
}
