import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Company extends StatefulWidget {
  final String phoneNumber;
  final String profession;

  const Company({required this.phoneNumber, required this.profession});

  @override
  _CompanyState createState() => _CompanyState();
}

class _CompanyState extends State<Company> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;

    final double imageTopPadding = 140.0;
    final double imageLeftRightPadding = screenWidth * 0.10;
    final double adjustedImageTopPadding =
        isKeyboardVisible ? 20.0 : imageTopPadding;
    final double adjustedImageLeftRightPadding =
        isKeyboardVisible ? screenWidth * 0.15 : imageLeftRightPadding;
    final double imageScale = isKeyboardVisible ? 0.5 : 1.0;
    final double bottomPadding = isKeyboardVisible ? keyboardHeight + 5 : 100;

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
                  padding: EdgeInsets.only(left: screenWidth * 0.28),
                  child: Text(
                    'Company details',
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
                    "Please enter your company's details",
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
                  'asset/company.png',
                  width: 300,
                  height: 300,
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
                  child: Column(
                    children: [
                      TextField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Company name',
                          prefixIcon: Icon(Icons.business),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(1, 42, 86, 1),
                              width: 2.0), // Change to your preferred color
                        ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _mobileNumberController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Mobile number',
                          prefixIcon: Icon(Icons.call),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(1, 42, 86, 1),
                              width: 2.0), // Change to your preferred color
                        ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _cityController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_on),
                          focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color.fromRGBO(1, 42, 86, 1),
                              width: 2.0), // Change to your preferred color
                        ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _storeCompanyDetails();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    minimumSize: Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 5,
                  ),
                  child: Text(
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
    );
  }

  Future<void> _storeCompanyDetails() async {
    if (_companyNameController.text.isEmpty ||
        _mobileNumberController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _mobileNumberController.text.length != 10) {
      // Show an error message if any field is empty or mobile number is not 10 digits
      String errorMessage='';
      if (_companyNameController.text.isEmpty ||
          _mobileNumberController.text.isEmpty ||
          _cityController.text.isEmpty) {
        errorMessage = 'Please fill in all fields';
      } else if (_mobileNumberController.text.length != 10) {
        errorMessage = 'Mobile number must be 10 digits';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    try {
      // Create a new document in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.phoneNumber)
          .update({
        'companyName': _companyNameController.text.trim(),
        'companyNumber': _mobileNumberController.text.trim(),
        'city': _cityController.text.trim(),
      });

      // Save login state and user ID to shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userId', widget.phoneNumber);

      // Navigate based on profession
      if (widget.profession == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => ProjectScreen(userId: widget.phoneNumber)),
        );
      } else if (widget.profession == 'Material supplier') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Materialside(userId: widget.phoneNumber)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save company details: $e')),
      );
    }
  }
}
