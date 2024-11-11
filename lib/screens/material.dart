import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/add_material.dart';
import 'package:myapp/screens/file.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/task.dart';
import 'package:myapp/screens/transaction.dart';

class Materialscreen extends StatefulWidget {
  final String userId;
  final String projectDocId;

  const Materialscreen({required this.userId, required this.projectDocId});
  @override
  State<Materialscreen> createState() => _MaterialscreenState();
}

class _MaterialscreenState extends State<Materialscreen> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  PageController _pageController = PageController();
  int _currentPageIndex = 0; // Track page index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Handle navigation logic based on the selected index
      // For example, navigate to different screens
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index; // Update current page index
    });
  }

  String activeButton = 'Material';
  String activeSubButton = 'Requested'; // New state variable

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
        body: Column(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProjectScreen(userId: widget.userId,), // Make sure OTPScreen is imported
                              ),
                            );
                          },
                        ),
                        Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.20)),
                        const Text(
                          'Material',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01), // Space between rows

                  // Second Row: Transaction, Task, Material, File
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  Transactionscreen(userId: widget.userId, projectDocId: widget.projectDocId,), // Make sure OTPScreen is imported
                            ),
                          );
                          setState(() {
                            activeButton = 'Transaction';
                          });
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: activeButton == 'Transaction'
                              ? Color.fromRGBO(1, 42, 86, 1)
                              : Colors.transparent,
                        ),
                        child: Image.asset(
                          'asset/transaction.png',
                          width: 25,
                          height: 25,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskScreen(
                                userId: widget.userId,
                                projectDocId: widget.projectDocId,
                              ), // Make sure OTPScreen is imported
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
                              ), // Make sure OTPScreen is imported
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('projects')
                    .doc(widget.projectDocId)
                    .collection('materials')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No materials found."));
                  }

                  var materials = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      var material = materials[index];
                      final timestamp = material['timestamp'] as Timestamp?;

                      String formattedDate = 'N/A';
                      String formattedMonth = 'N/A';

                      // Check if timestamp is not null and convert to formatted date
                      if (timestamp != null) {
                        final dateTime = timestamp.toDate();
                        formattedDate = DateFormat('dd').format(dateTime);
                        formattedMonth = DateFormat('MMM').format(dateTime);
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                            top: screenHeight * 0.02,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05),
                        child: Container(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.13,
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 245, 245, 245),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                // Sample ongoing project
                                Row(
                                  children: [
                                    Container(
                                      width:
                                          40, // Set the width of the container
                                      height:
                                          60, // Set the height of the container
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color:
                                              Color.fromARGB(255, 4, 63, 132),
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 4, 63, 132),
                                            ),
                                          ),
                                          Text(
                                            formattedMonth,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color.fromARGB(
                                                  255, 4, 63, 132),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                        width:
                                            10), // Add spacing between the container and the text
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            material['materialName'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Qty: ${material['quantity']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Status: ${material['status']}',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.more_vert,
                                          color: Colors.black54),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: 150,
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                children: <Widget>[
                                                  if (material['status'] ==
                                                      'Requested') ...[
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(widget.userId)
                                                            .collection(
                                                                'projects')
                                                            .doc(widget
                                                                .projectDocId)
                                                            .collection(
                                                                'materials')
                                                            .doc(material.id)
                                                            .update({
                                                          'status': 'Received'
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the modal
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            const Color
                                                                .fromARGB(255,
                                                                4, 63, 132),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Received',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ] else if (material[
                                                          'status'] ==
                                                      'Received') ...[
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await FirebaseFirestore
                                                            .instance
                                                            .collection('users')
                                                            .doc(widget.userId)
                                                            .collection(
                                                                'projects')
                                                            .doc(widget
                                                                .projectDocId)
                                                            .collection(
                                                                'materials')
                                                            .doc(material.id)
                                                            .update({
                                                          'status': 'Used'
                                                        });
                                                        Navigator.pop(
                                                            context); // Close the modal
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Color.fromARGB(255,
                                                                214, 10, 10),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                vertical: 15),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                          'Used',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                  SizedBox(height: 10),
                                                  ElevatedButton(
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('users')
                                                          .doc(widget.userId)
                                                          .collection(
                                                              'projects')
                                                          .doc(widget
                                                              .projectDocId)
                                                          .collection(
                                                              'materials')
                                                          .doc(material.id)
                                                          .delete();
                                                      Navigator.pop(
                                                          context); // Close the modal
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Color.fromARGB(
                                                              255, 214, 10, 10),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 15),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                    ),
                                                    child: Align(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Text(
                                                        'Delete',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.04),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMaterial(
                          userId: widget.userId,
                          projectDocId: widget.projectDocId,
                        ), // Make sure OTPScreen is imported
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(1, 42, 86, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Add Material',
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
