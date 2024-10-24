import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/add_quotation.dart';
import 'package:myapp/screens/change_password.dart';
import 'package:myapp/screens/edit_profile.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/members.dart';
import 'package:myapp/screens/party_details.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/quotations.dart';
import 'package:myapp/screens/transaction.dart';

class partiesscreen extends StatefulWidget {
  final String userId;

  const partiesscreen({required this.userId});
  @override
  State<partiesscreen> createState() => partiesscreenState();
}

class partiesscreenState extends State<partiesscreen> {
  int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  PageController _pageController = PageController();
  int _currentPageIndex = 2; // Track page index
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyNumberController = TextEditingController();
  String companyName = ''; // Declare companyName as a class-level variable
  final TextEditingController _searchController = TextEditingController();
    String _searchQuery = '';


  Future<String?> _saveparty() async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(widget.userId);

        CollectionReference partyRef = userRef.collection('parties');

        DocumentReference docRef = await partyRef.add({
          'partyName': _partyNameController.text.trim(),
          'partyNumber': _partyNumberController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('party added successfully!')),
        );

        return docRef.id; // Returning the document ID
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add party: $e')),
        );
        return null;
      }
    }
    return null;
  }


  Future<double> _fetchTotalPayments(String partyDocId) async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('parties')
        .doc(partyDocId)
        .collection('payments')
        .where('paymentMethod', isEqualTo: 'To Received')
        .get();

    double total = 0.0;

    for (var doc in snapshot.docs) {
      // Check if 'amount' is a String, then convert it to double
      String amountString = doc['amount'] ?? '0.0'; // Default to '0.0' if null
      double amount = double.tryParse(amountString) ?? 0.0; // Convert to double

      total += amount; // Add to total
    }

    return total;
  } catch (e) {
    print('Error fetching payments: $e');
    return 0.0; // Return 0.0 in case of an error
  }
}


  Future<double> _fetchTotalPaymentsOut(String partyDocId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('parties')
          .doc(partyDocId)
          .collection('payments')
          .where('paymentMethod', isEqualTo: 'To Pay')
          .get();

      double total = 0.0;

      for (var doc in snapshot.docs) {
      // Check if 'amount' is a String, then convert it to double
      String amountString = doc['amount'] ?? '0.0'; // Default to '0.0' if null
      double amount = double.tryParse(amountString) ?? 0.0; // Convert to double

      total += amount; // Add to total
    }

      return total;
    } catch (e) {
      print('Error fetching payments: $e');
      return 0.0; // Return 0.0 in case of an error
    }
  }

  Stream<QuerySnapshot> _fetchItemData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('parties')
        .snapshots();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index; // Update current page index
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProjectScreen(
                    userId: widget.userId,
                  )),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => quotationscreen(
                    userId: widget.userId,
                  )),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => partiesscreen(
                    userId: widget.userId,
                  )),
        );
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCompanyName();
    fetchUserName();
     _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

 
  Future<void> fetchCompanyName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          companyName = userDoc['companyName'];
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching company name: $e');
    }
  }

  String? yourName;

  void fetchUserName() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          yourName = userDoc['yourName'];
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        key: _scaffoldKey,
        drawer: Drawer(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight * 0.09),
            child: Column(
              children: [
                Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'asset/logo1.png',
                          width: 140,
                          height: 90,
                        ),
                      ),
                    ),
                    Text(
                      yourName ?? 'Loading...',
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
                Container(
                  width: screenWidth * 0.7, // Set the width of the divider
                  child: Divider(
                    color: Color.fromARGB(255, 4, 63, 132),
                    thickness:
                        1.0, // Optional: Set the thickness of the divider
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero, // Remove default padding
                    children: [
                      ListTile(
                        leading: Icon(Icons.person),
                        title: Text('Members'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Members(
                                userId: widget.userId,
                              ), // Make sure OTPScreen is imported
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Profile'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfile(
                                userId: widget.userId,
                              ), // Make sure OTPScreen is imported
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.lock),
                        title: Text('Change Password'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChangePassword(
                                userId: widget.userId,
                              ), // Make sure OTPScreen is imported
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PhoneScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: screenHeight * 0.00),
          child: Column(
            children: [
              Container(
                color: Color.fromARGB(255, 4, 63, 132),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: screenHeight * 0.05, left: screenWidth * 0.02),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.menu, color: Colors.white),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer();
                            },
                          ),
                          Text(
                            companyName.isNotEmpty ? companyName : 'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.15,
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
                child: Padding(
                  padding: EdgeInsets.only(
                      left: screenWidth * 0.04, top: screenHeight * 0.01),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Party Balance',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 4, 63, 132),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Here is your all party payments',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            )
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          'asset/party balance.png',
                          width: 140,
                          height: 90,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.only(
                    left: screenWidth * 0.03, right: screenWidth * 0.05),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            hintText: 'Search',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 20),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _partyNameController.clear();
                        _partyNumberController.clear();
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(25.0),
                            ),
                          ),
                          builder: (BuildContext context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(companyName,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          )),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _partyNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Party Name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a Party name';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _partyNumberController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Party  Number',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a Party number';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              Navigator.of(context).pop();
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                String? partyDocId =
                                                    await _saveparty();
                                                // Close the current screen
                                              }
                                            },
                                            child: Text(
                                              'Create',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromRGBO(
                                                      1, 42, 86, 1),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the bottom sheet
                                            },
                                            child: Text(
                                              'Cancel',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                            ),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Color.fromARGB(
                                                  255, 214, 10, 10),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 20, vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ),
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
                      child: Text(
                        'New party',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 4, 63, 132),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _fetchItemData(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var party = snapshot.data!.docs;
                    if (_searchQuery.isNotEmpty) {
                          party = party.where((party) {
                            var partyName =
                                party['partyName'].toString().toLowerCase();
                            return partyName.contains(_searchQuery);
                          }).toList();
                        }

                    if (party.isEmpty) {
                      return Center(child: Text('No party created.'));
                    }

                    return ListView.builder(
                      itemCount: party.length,
                      itemBuilder: (context, index) {
                        var parties = party[index];
                        var partyDocId = parties.id;

                        return Column(
                          children: [
                            InkWell(
                              onTap: () async {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => PartyDetails(
                                            userId: widget.userId,
                                            partyDocId: partyDocId,
                                          )), // Replace 'AnotherPage' with your target page
                                );
                              },
                              child: Container(
                                width: screenWidth * 0.9,
                                height: screenHeight * 0.15,
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
                                child: PageView(
                                  controller: _pageController,
                                  onPageChanged: _onPageChanged,
                                  children: [
                                    // Ongoing Projects View
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          // Example ongoing project
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      parties['partyName'],
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    SizedBox(height: 5),
                                                    Text(
                                                      parties['partyNumber'],
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
                                                    builder:
                                                        (BuildContext context) {
                                                      return Container(
                                                        height: 90,
                                                        padding:
                                                            EdgeInsets.all(16),
                                                        child: Column(
                                                          children: <Widget>[
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                Navigator.pop(
                                                                    context);
                                                                // Get the reference to the quotation document to be deleted
                                                                final quotationDoc = FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(widget
                                                                        .userId)
                                                                    .collection(
                                                                        'parties')
                                                                    .doc(
                                                                        partyDocId);

                                                                try {
                                                                  // Delete the quotation document
                                                                  await quotationDoc
                                                                      .delete();

                                                                  // Optionally, show a success message to the user
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                          'party deleted successfully'),
                                                                    ),
                                                                  );

                                                                  // Navigate back or to a specific screen after deletion
                                                                } catch (e) {
                                                                  // Handle any errors during deletion
                                                                  print(
                                                                      'Error deleting party: $e');
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    SnackBar(
                                                                      content: Text(
                                                                          'Error deleting quotation: $e'),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                backgroundColor:
                                                                    Color
                                                                        .fromARGB(
                                                                            255,
                                                                            214,
                                                                            10,
                                                                            10),
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            15),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                ),
                                                              ),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: Text(
                                                                  'Delete',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            )
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
                                        FutureBuilder<List<double>>(
                                          future: Future.wait([
                                            _fetchTotalPayments(
                                                partyDocId), // Fetch total "payment in"
                                            _fetchTotalPaymentsOut(
                                                partyDocId), // Fetch total "payment out"
                                          ]),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child:
                                                      Text('Loading...'));
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else {
                                              double totalIn =
                                                  snapshot.data![0];
                                              double totalOut =
                                                  snapshot.data![1];

                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Rs. ${totalIn.toStringAsFixed(2)} in',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rs. ${totalOut.toStringAsFixed(2)} out',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Only add a Divider if it's not the last item
                            if (index < party.length - 1)
                              SizedBox(height: 10), // Divider between parties
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.work,
                color: _selectedIndex == 0
                    ? Color.fromARGB(255, 4, 63, 132)
                    : Colors.grey,
              ),
              label: 'Project',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.description,
                color: _selectedIndex == 1
                    ? Color.fromARGB(255, 4, 63, 132)
                    : Colors.grey,
              ),
              label: 'Quotation',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.group,
                color: _selectedIndex == 2
                    ? Color.fromARGB(255, 4, 63, 132)
                    : Colors.grey,
              ),
              label: 'Parties',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color.fromARGB(255, 4, 63, 132),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
