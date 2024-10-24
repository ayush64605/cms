import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/file.dart';
import 'package:myapp/screens/material.dart';
import 'package:myapp/screens/payment_in.dart';
import 'package:myapp/screens/payment_out.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/task.dart';
import "package:intl/intl.dart";

class Transactionscreen extends StatefulWidget {
  final String userId;
  final String projectDocId;

  const Transactionscreen({required this.userId, required this.projectDocId});

  @override
  State<Transactionscreen> createState() => _TransactionscreenState();
}

class _TransactionscreenState extends State<Transactionscreen> {
  String activeButton = 'Transaction';

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    // assert(widget.userId.isNotEmpty, 'userId should not be empty');
    // assert(widget.projectDocId.isNotEmpty, 'projectDocId should not be empty');

    // Optionally print to console for debugging
    print('UserId: ${widget.userId}');
    print('ProjectDocId: ${widget.projectDocId}');

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => ProjectScreen(userId: widget.userId)),
          (Route<dynamic> route) => false,
        );
        return true;
      },
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(0),
          child: Column(
            children: [
              Container(
                color: Color.fromARGB(255, 4, 63, 132),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.05, left: screenWidth * 0.00),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            color: Colors.white,
                            onPressed: () {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProjectScreen(userId: widget.userId),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            },
                          ),
                          Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.20)),
                          const Text(
                            'Transaction',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              activeButton = 'Transaction';
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: activeButton == 'Transaction'
                                ? Color.fromRGBO(1, 42, 86, 1)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'asset/transaction.png',
                                width: 25,
                                height: 25,
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TaskScreen(
                                    userId: widget.userId,
                                    projectDocId: widget.projectDocId),
                              ),
                            );
                            setState(() {
                              activeButton = 'Task';
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: activeButton == 'Task'
                                ? Color.fromRGBO(1, 42, 86, 1)
                                : Colors.transparent,
                          ),
                          child: Image.asset(
                            'asset/task logo.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Materialscreen(
                                  userId: widget.userId,
                                  projectDocId: widget.projectDocId,
                                ),
                              ),
                            );
                            setState(() {
                              activeButton = 'Material';
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: activeButton == 'Material'
                                ? Color.fromRGBO(1, 42, 86, 1)
                                : Colors.transparent,
                          ),
                          child: Image.asset(
                            'asset/material.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FileScreen(
                                  userId: widget.userId,
                                  projectDocId: widget.projectDocId,
                                ),
                              ),
                            );
                            setState(() {
                              activeButton = 'File';
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: activeButton == 'File'
                                ? Color.fromRGBO(1, 42, 86, 1)
                                : Colors.transparent,
                          ),
                          child: Image.asset(
                            'asset/file.png',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentInPage(
                                userId: widget.userId,
                                projectDocId: widget.projectDocId),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 29, 142, 33),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Payment In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentOutPage(
                              userId: widget.userId,
                              projectDocId: widget.projectDocId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 169, 23, 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: Text(
                        'Payment Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: screenWidth * 0.9,
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('projects')
                      .doc(widget.projectDocId)
                      .collection('payment')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final paymentDocs = snapshot.data!.docs;

                    // Initialize totals
                    double totalIn = 0;
                    double totalOut = 0;

                    // Calculate totals based on status
                    for (var doc in paymentDocs) {
                      final paymentData = doc.data() as Map<String, dynamic>;
                      final status = paymentData['status'];
                      final amount = paymentData['amount']?.toDouble() ?? 0;

                      if (status == 'payment in') {
                        totalIn += amount;
                      } else if (status == 'payment out') {
                        totalOut += amount;
                      }
                    }

                    // Calculate total balance
                    double totalBalance = totalIn - totalOut;

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 4, 63, 132),
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${totalIn.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 80),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Total Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 4, 63, 132),
                                    ),
                                  ),
                                  Text(
                                    'Rs. ${totalOut.toStringAsFixed(2)} Out',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Colors.black26),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Balance',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 4, 63, 132),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Rs. ${totalBalance.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.userId)
                      .collection('projects')
                      .doc(widget.projectDocId)
                      .collection('payment')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final paymentDocs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: paymentDocs.length,
                      itemBuilder: (context, index) {
                        final paymentData =
                            paymentDocs[index].data() as Map<String, dynamic>;
                        final paymentDocId = paymentDocs[index]
                            .id; // Get the document ID for deletion

                        final paymentFrom =
                            paymentData['payment_from'] ?? 'N/A';
                        final paymentTo = paymentData['payment_to'] ?? 'N/A';
                        final amount = paymentData['amount'] != null
                            ? '${paymentData['amount']}'
                            : 'N/A';
                        final description =
                            paymentData['description'] ?? 'No description';
                        final paymentMethod =
                            paymentData['payment_method'] ?? 'N/A';
                        final status = paymentData['status'];
                        final method = paymentData['payment_method'];
                        final timestamp =
                            paymentData['timestamp'] as Timestamp?;

                        String formattedDate = 'N/A';

                        // Check if timestamp is not null and convert to formatted date
                        if (timestamp != null) {
                          final dateTime = timestamp.toDate();
                          formattedDate = DateFormat('dd MMM').format(dateTime);
                        }

                        // Long press gesture to show bottom sheet
                        return GestureDetector(
                          onLongPress: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  width: screenWidth * 1,
                                  padding: EdgeInsets.all(10),
                                  height:
                                      100, // Set the height of the bottom sheet
                                  child: Column(
                                    children: [
                                      SizedBox(height: 17),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          // Delete the transaction from Firestore
                                          await FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(widget.userId)
                                              .collection('projects')
                                              .doc(widget.projectDocId)
                                              .collection('payment')
                                              .doc(paymentDocId)
                                              .delete();
                                          // Close the bottom sheet
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Color.fromARGB(255, 214, 10, 10),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Delete',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: screenWidth * 0.9,
                            margin: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 17),
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: status == 'payment in'
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    status == 'payment in'
                                        ? Icons.arrow_downward
                                        : Icons.arrow_upward,
                                    color: status == 'payment in'
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        status == 'payment in'
                                            ? paymentFrom
                                            : paymentTo,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: status == 'payment in'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      Text(description),
                                      Text(formattedDate),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Rs. $amount',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: status == 'payment in'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      method,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: status == 'payment in'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
