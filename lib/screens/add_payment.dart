import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/party_details.dart';
import 'package:myapp/screens/transaction.dart';

class AddPayment extends StatefulWidget {
  final String userId;
  final String partyDocId;

  const AddPayment({required this.userId, required this.partyDocId});

  @override
  State<AddPayment> createState() => _AddPaymentState();
}

class _AddPaymentState extends State<AddPayment> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentForController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPaymentMethod = 'To Received'; // Default selected value

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
                    padding: EdgeInsets.only(
                        top: screenHeight * 0.04, left: screenWidth * 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios),
                              color: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            const Text(
                              'Add payment',
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.10),
                          child: Image.asset(
                            'asset/payment_out.png', // Replace with your image asset path
                            width: 100,
                            height: 60,
                          ),
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
                  // Payment From field
                  TextFormField(
                    controller: _paymentForController,
                    decoration: InputDecoration(
                      labelText: 'Payment For',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Amount Received field
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16),

                  // Description field
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 16),

                  // Payment method selection
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Column(
                    children: [
                      RadioListTile<String>(
                        title: const Text('To Received'),
                        value: 'To Received',
                        activeColor: Color.fromARGB(255, 4, 63, 132),
                        groupValue: _selectedPaymentMethod,
                        // Use state variable
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod =
                                value!; // Update state on selection
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('To Pay'),
                        value: 'To Pay',
                        activeColor: Color.fromARGB(255, 4, 63, 132),

                        groupValue:
                            _selectedPaymentMethod, // Use state variable
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Save Button
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.23),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    // Handle save action
                    String amount = _amountController.text;
                    String paymentFor = _paymentForController.text;
                    String description = _descriptionController.text;

                    if (amount.isEmpty ||
                        paymentFor.isEmpty ||
                        description.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields'),
                        ),
                      );
                      return;
                    }

                    // Create payment data
                    Map<String, dynamic> paymentData = {
                      'amount': amount,
                      'paymentFor': paymentFor,
                      'description': description,
                      'paymentMethod': _selectedPaymentMethod,
                      'timestamp': FieldValue.serverTimestamp(),
                    };

                    // Save to Firestore
                    Navigator.pop(context); // Go back to previous screen

                    try {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(widget.userId)
                          .collection('parties')
                          .doc(widget.partyDocId)
                          .collection('payments')
                          .add(paymentData);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment added successfully'),
                        ),
                      );
                    } catch (e) {
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Error adding payment: $e'),
                      //   ),
                      // );
                    }
                  },
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
          ],
        ),
      ),
    );
  }
}
