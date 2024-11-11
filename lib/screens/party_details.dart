import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/add_payment.dart';
import 'package:myapp/screens/parties.dart';

class PartyDetails extends StatefulWidget {
  final String userId;
  final String partyDocId;

  const PartyDetails({required this.userId, required this.partyDocId});

  @override
  State<PartyDetails> createState() => _PartyDetailsState();
}

class _PartyDetailsState extends State<PartyDetails> {
  double totalToReceived = 0;
  double totalToPay = 0;

  void _calculateTotals(List<QueryDocumentSnapshot> payments) {
    totalToReceived = 0; // Reset total for new calculations
    totalToPay = 0; // Reset total for new calculations

    for (var payment in payments) {
      var data = payment.data() as Map<String, dynamic>;
      double amount = double.parse(data['amount'].toString());
      String paymentMethod = data['paymentMethod'] ?? 'N/A';

      // Update totals based on payment method
      if (paymentMethod == 'To Received') {
        totalToReceived += amount;
      } else if (paymentMethod == 'To Pay') {
        totalToPay += amount;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => partiesscreen(userId: widget.userId)),
          (Route<dynamic> route) => false,
        );
        return false;
      },
      child: Scaffold(
        body: Column(
          children: [
            // Fixed header for Party Name and Party Type
            Container(
              color: const Color.fromARGB(255, 4, 63, 132),
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: screenHeight * 0.04),
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
                                    builder: (context) =>
                                        partiesscreen(userId: widget.userId),
                                  ),
                                );
                              },
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Party Name',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Party type',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.06,
                  right: screenWidth * 0.06,
                  top: screenHeight * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPayment(
                              userId: widget.userId,
                              partyDocId: widget.partyDocId),
                        ),
                      ).then((_) {
                        // Rebuild the widget after returning from AddPayment
                        setState(() {});
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 4, 63, 132),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      'Add payment',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),

            // Scrollable payment details section
            Expanded(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.userId)
                            .collection('parties')
                            .doc(widget.partyDocId)
                            .collection('payments')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                          }

                          final payments = snapshot.data!.docs;

                          if (payments.isEmpty) {
                            return Center(child: Text('No payments found.'));
                          }

                          // Calculate totals
                          _calculateTotals(payments);

                          List<Widget> paymentWidgets = [];

                          for (var payment in payments) {
                            var data = payment.data() as Map<String, dynamic>;
                            String paymentFor = data['paymentFor'] ?? 'N/A';
                            String description = data['description'] ?? 'N/A';
                            double amount =
                                double.parse(data['amount'].toString());
                            String paymentMethod =
                                data['paymentMethod'] ?? 'N/A';

                            paymentWidgets.add(
                              Container(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.15,
                                margin: EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromARGB(255, 245, 245, 245),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0, 4),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '$paymentFor',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                description,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.more_vert,
                                                color: Colors.black54),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    height: 100,
                                                    padding: EdgeInsets.all(16),
                                                    child: Column(
                                                      children: <Widget>[
                                                        SizedBox(height: 10),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                  context);
                                                                   ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                    content: Text(
                                                                        'Payment deleted successfully')),
                                                              );
                                                            // Handle delete action
                                                            try {
                                                              // Delete the payment document from Firestore
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'users')
                                                                  .doc(widget
                                                                      .userId)
                                                                  .collection(
                                                                      'parties')
                                                                  .doc(widget
                                                                      .partyDocId)
                                                                  .collection(
                                                                      'payments')
                                                                  .doc(payment
                                                                      .id) // Assuming payment.id is the document ID
                                                                  .delete();

                                                              // Close the modal
                                                              
                                                              // Optionally show a success message
                                                             

                                                              // Refresh the state to update the totals
                                                              setState(() {});
                                                            } catch (e) {
                                                              // Handle any errors
                                                              print(
                                                                  'Error deleting payment: $e');
                                                            }
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    214,
                                                                    10,
                                                                    10),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15),
                                                          ),
                                                          child: Align(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              'Delete',
                                                              style: TextStyle(
                                                                  fontSize: 16,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                      Divider(color: Colors.black26),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Rs. ${amount.toString()}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            paymentMethod,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  paymentMethod == 'To Received'
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          // Summary Container
                          return Column(
                            children: [
                              ...paymentWidgets,
                              SizedBox(
                                  height: 10), // Added spacing before summary
                              // Summary Container
                              Container(
                                width: screenWidth * 0.9,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Color.fromARGB(255, 245, 245, 245),
                                  border: Border.all(
                                    color: Color.fromARGB(255, 4, 63, 132),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'To Received',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'Rs. ${totalToReceived.toString()}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'To Pay',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                        Text(
                                          'Rs. ${totalToPay.toString()}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Total',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Rs. ${totalToReceived - totalToPay}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
