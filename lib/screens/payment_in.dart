import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/transaction.dart';

class PaymentInPage extends StatefulWidget {
  final String userId;
  final String projectDocId;

  const PaymentInPage({required this.userId, required this.projectDocId});
  @override
  State<PaymentInPage> createState() => _PaymentInPageState();
}

class _PaymentInPageState extends State<PaymentInPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paymentFromController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPaymentMethod = 'Cash'; // Default selected value

  Future<void> _savePayment() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Transactionscreen(
          userId: widget.userId,
          projectDocId: widget.projectDocId,
        ),
      ),
    );
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId) // Replace with the actual user ID
          .collection('projects')
          .doc(widget.projectDocId) // Replace with the actual project ID
          .collection('payment')
          .add({
        'payment_from': _paymentFromController.text,
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'payment_method': _selectedPaymentMethod,
        'status': 'payment in',
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving payment: $e')),
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
            //Container with the row containing arrow, text, and image
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Transactionscreen(
                                        userId: widget.userId,
                                        projectDocId: widget.projectDocId),
                                  ),
                                );
                              },
                            ),
                            const Text(
                              'Payment In',
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
                            'asset/payment_in.png',
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
                    controller: _paymentFromController,
                    decoration: InputDecoration(
                      labelText: 'Payment From',
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
                      labelText: 'Amount Received',
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
                        title: const Text('Cash'),
                        value: 'Cash',
                        activeColor: Color.fromARGB(255, 4, 63, 132),
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Cheque'),
                        value: 'Cheque',
                        activeColor: Color.fromARGB(255, 4, 63, 132),
                        groupValue: _selectedPaymentMethod,
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentMethod = value!;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('Bank Transfer'),
                        value: 'Bank Transfer',
                        activeColor: Color.fromARGB(255, 4, 63, 132),
                        groupValue: _selectedPaymentMethod,
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
              padding: EdgeInsets.only(top:screenHeight * 0.14),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: _savePayment,
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
