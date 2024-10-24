import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:myapp/screens/company.dart';
import 'package:myapp/screens/project_screen.dart';

class MoreAbout extends StatefulWidget {
  final String phoneNumber; // Add phoneNumber parameter

  const MoreAbout({required this.phoneNumber}); // Add required phoneNumber

  @override
  State<MoreAbout> createState() => _MoreAboutState();
}

class _MoreAboutState extends State<MoreAbout> {
  String? _profession;

  Future<void> _storeProfession(String phoneNumber, String profession) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(phoneNumber)
          .update({
        'profession': profession,
      });
      print('Profession stored successfully');
    } catch (e) {
      print('Error storing profession: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardVisible = keyboardHeight > 0;
    final double bottomPadding = isKeyboardVisible ? 10 : 30;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(
            top: screenHeight * 0.08,
            left: screenWidth * 0.05,
            right: screenWidth * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Profession',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                Row(
                  
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 16.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _profession = 'owner';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _profession == 'owner'
                                    ? Color.fromARGB(255, 3, 22, 118)
                                    : Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'asset/employee.png', // Replace with your image asset
                                height: 80,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
                                    value: 'owner',
                                    groupValue: _profession,
                                    onChanged: (value) {
                                      setState(() {
                                        _profession = value;
                                      });
                                    },
                                  ),
                                  Text('Contractor'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(width: 16.0),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _profession = 'Material supplier';
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: _profession == 'Material supplier'
                                    ? Color.fromARGB(255, 3, 22, 118)
                                    : Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                            children: [
                              Image.asset(
                                'asset/supplier.png', // Replace with your image asset
                                height: 80,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Radio<String>(
                                    value: 'Material supplier',
                                    groupValue: _profession,
                                    onChanged: (value) {
                                      setState(() {
                                        _profession = value;
                                      });
                                    },
                                  ),
                                  Text('Material supplier',
                                  style:TextStyle(
                                    fontSize: 11,
                                  ), 
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(bottom: bottomPadding),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_profession != null) {
                      await _storeProfession(widget.phoneNumber, _profession!);
                      if (_profession == 'owner' || _profession == 'Material supplier') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Company(
                              phoneNumber: widget.phoneNumber,
                              profession: _profession!,
                            ),
                          ),
                        );
                      } 
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a profession.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
