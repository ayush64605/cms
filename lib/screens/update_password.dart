import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:myapp/screens/otp.dart';
import 'package:myapp/screens/more_about.dart'; // Import your MoreAboutScreen
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/sms_service.dart';

class UpdatePassword extends StatefulWidget {
  final String phoneNumber;

  UpdatePassword({
    required this.phoneNumber,
  });

  @override
  _UpdatePasswordState createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isLoading = false; // Loading state variable

  Future<void> _updatePassword() async {
    final String newPassword = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phoneNumber)
          .update({'password': newPassword});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password updated successfully')),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneScreen(),
        ),
      );
      // Optionally, navigate back or clear fields
      _passwordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update password: $e')),
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
                    'Update Password',
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
                    'Update your password to secure your account',
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
                  onPressed: _isLoading
                      ? null
                      : _updatePassword, // Disable button if loading
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
                          'Submit',
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
