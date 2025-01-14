import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/transaction.dart';

class PaymentOutPage extends StatefulWidget {
  final String userId;
  final String projectDocId;

  const PaymentOutPage({required this.userId, required this.projectDocId, Key? key}) : super(key: key);

  @override
  State<PaymentOutPage> createState() => _PaymentOutPageState();
}

class _PaymentOutPageState extends State<PaymentOutPage> {
  final TextEditingController _paymentToController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPaymentMethod = 'Cash'; // Default selected value

  Future<void> _savePayment() async {

    String paymentfrom = _paymentToController.text;
    String amount = _amountController.text;
    String description = _descriptionController.text;
    if (paymentfrom.isEmpty || amount.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('projects')
          .doc(widget.projectDocId)
          .collection('payment')
          .add({
        'payment_to': _paymentToController.text,
        'amount': double.parse(_amountController.text),
        'description': _descriptionController.text,
        'payment_method': _selectedPaymentMethod,
        'status': 'payment out',
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment saved successfully!')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Transactionscreen(userId: widget.userId, projectDocId: widget.projectDocId),
        ),
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
                              'Payment Out',
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
                  // Payment To field
                  TextFormField(
                    controller: _paymentToController,
                    decoration: InputDecoration(
                      labelText: 'Payment To',
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

                  // Amount Given field
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount Given',
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
              padding: EdgeInsets.only(top: screenHeight * 0.15),
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
