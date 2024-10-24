import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:myapp/screens/otp.dart';
import 'package:myapp/screens/more_about.dart'; // Import your MoreAboutScreen
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/sms_service.dart';

class PasswordScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isFromOtp; // A flag to indicate if navigated from OTP screen
  final bool isFromPhoneScreen; // A flag to indicate if navigated from Phone Screen

  PasswordScreen({
    required this.phoneNumber,
    required this.isFromOtp,
    required this.isFromPhoneScreen,
  });

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  late SmsService smsService;
  bool _isLoading = false; // Loading state variable

  @override
  void initState() {
    super.initState();
    smsService = SmsService(
      accountSid: '',
      authToken: '',
      fromNumber: '',
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _storeUserData(String phoneNumber, String password) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(phoneNumber).set({
        'phoneNumber': phoneNumber,
        'password': password,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('User data stored successfully');
    } catch (e) {
      print('Error storing user data: $e');
    }
  }

Future<void> _validatePassword() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.phoneNumber)
        .get();

    if (userDoc.exists) {
      String storedPassword = userDoc['password'];
      String profession = userDoc['profession']; // Retrieve the profession

      if (_passwordController.text == storedPassword) {
        // Navigate based on profession
        if (profession == 'owner') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectScreen(userId: widget.phoneNumber),
            ),
          );
        } else if (profession == 'Material supplier') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Materialside(userId: widget.phoneNumber),
            ),
          );
        } else if (profession == 'Material supplier') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Materialside(userId: widget.phoneNumber),
            ),
          );
        } 
         else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Unknown profession. Please contact support.')),
          );
        }
      } else {
        // Password does not match
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Incorrect password. Please try again.')),
        );
      }
    } else {
      // User does not exist
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not found. Please register.')),
      );
    }
  } catch (e) {
    print('Error validating password: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error occurred. Please try again.')),
    );
  } finally {
    setState(() {
      _isLoading = false; // Set loading state to false after validation
    });
  }
}


  Future<void> _storeLoginWithOtp(String phoneNumber, String otp) async {
    try {
      await FirebaseFirestore.instance.collection('phoneNumbers').doc(phoneNumber).set({
        'phoneNumber': phoneNumber,
        'verificationCode': otp,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Login with OTP data stored successfully');
    } catch (e) {
      print('Error storing login with OTP data: $e');
    }
  }

  Future<void> _sendOtp() async {
    // Generate a random 6-digit OTP
    String verificationCode = (1000 + (9999 - 1000) * (DateTime.now().millisecondsSinceEpoch % 10000) / 10000).toStringAsFixed(0);

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      await smsService.sendSms(widget.phoneNumber, 'Your verification code is $verificationCode');

      // Store phone number and OTP in Firestore
      await _storeLoginWithOtp(widget.phoneNumber, verificationCode);

      // Navigate to the OtpScreen with the verificationId
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            phoneNumber: widget.phoneNumber,
            verificationCode: verificationCode,
            isFromPassword: true, isFromchangepassword: false, isFromPhoneScreen: false,
          ),
        ),
      );
    } catch (e) {
      print('Error sending OTP: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send OTP. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false after sending OTP
      });
    }
  }

  void _submitPassword() {
    if (_passwordController.text.isEmpty ||
        (widget.isFromOtp && _confirmPasswordController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your password.')),
      );
      return;
    }

    if (widget.isFromOtp && _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    setState(() {
      _isLoading = true; // Set loading state to true
    });

    if (widget.isFromPhoneScreen) {
      // If coming from Phone Screen, validate the password
      _validatePassword();
    } else {
      // Store the user data in Firestore
      _storeUserData(widget.phoneNumber, _passwordController.text).then((_) {
        setState(() {
          _isLoading = false; // Set loading state to false after storing user data
        });
        // Navigate to MoreAbout screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MoreAbout(phoneNumber: widget.phoneNumber)),
          (Route<dynamic> route) => false,
        );
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
    final double adjustedImageTopPadding = isKeyboardVisible ? 120.0 : imageTopPadding;
    final double adjustedImageLeftRightPadding = isKeyboardVisible ? screenWidth * 0.15 : imageLeftRightPadding;
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
                  padding: EdgeInsets.only(left: screenWidth * 0.33),
                  child: Text(
                    'Set Password',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: screenWidth * 0.05),
                  child: Text(
                    'Enter your password to secure your account',
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
                  'asset/password.png',
                  width: 200,
                  height: 200,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: bottomPadding,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                ),
                if (widget.isFromOtp)
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: TextField(
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Confirm your password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitPassword, // Disable button if loading
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
                          valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(1, 42, 86, 1)),
                        )
                      : Text(
                          'Submit',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                SizedBox(height: 10),
                if (!widget.isFromOtp)
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendOtp, // Disable button if loading
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromRGBO(1, 42, 86, 1),
                      backgroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(1, 42, 86, 1)),
                          )
                        : Text(
                            'Login with OTP',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
              ],
            ),
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
    );
  }
}
