import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/add_material.dart';
import 'package:myapp/screens/add_quotation.dart';
import 'package:myapp/screens/change_password.dart';
import 'package:myapp/screens/edit_profile.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/m_material.dart';
import 'package:myapp/screens/m_transaction.dart';
import 'package:myapp/screens/material.dart';
import 'package:myapp/screens/material_details.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:myapp/screens/members.dart';
import 'package:myapp/screens/parties.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/transaction.dart';

class MTransaction extends StatefulWidget {
  final String userId;

  const MTransaction({required this.userId});

  @override
  State<MTransaction> createState() => _MTransactionState();
}

class _MTransactionState extends State<MTransaction> {
  int _selectedIndex = 1;
  final _formKey = GlobalKey<FormState>();
  PageController _pageController = PageController();
  int _currentPageIndex = 0; // Track page index
  final TextEditingController _ReceivedDateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String companyName = '';
  String? yourName;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchUserName();
    fetchCompanyName();
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

  Stream<QuerySnapshot> _fetchpaymentlist(String status, String paymentstatus) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('orders')
        .where('status', isEqualTo: status)
        .where('paymentstatus', isEqualTo: paymentstatus)
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
              builder: (context) => Materialside(
                    userId: widget.userId,
                  )),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MTransaction(
                    userId: widget.userId,
                  )),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MMaterial(
                    userId: widget.userId,
                  )),
        );
        break;
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    bool _isLoading = false;
    Future<void> _selectDate(
        BuildContext context, TextEditingController controller) async {
      final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null) {
        setState(() {
          controller.text = "${pickedDate.toLocal()}".split(' ')[0];
        });
      }
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => Materialside(userId: widget.userId)),
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
                      yourName ?? 'Your Name',
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
                          )
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
                  padding: EdgeInsets.symmetric(
                      vertical: screenHeight * 0.02,
                      horizontal: screenWidth * 0.05),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Payments',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 4, 63, 132),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Here is all order which you get',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Image.asset(
                          'asset/m_payment.png',
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
                        padding: EdgeInsets.symmetric(horizontal: 10),
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
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.02),
                child: Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.06,
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
                  child: Row(
                    children: [
                      // Ongoing button
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(0);
                            setState(() {
                              _currentPageIndex =
                                  0; // Update selected page index
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _currentPageIndex == 0
                                ? Colors.white
                                : Color.fromARGB(255, 4, 63, 132),
                            backgroundColor: _currentPageIndex == 0
                                ? Color.fromARGB(255, 4, 63, 132)
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Payment left',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // Completed button

                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            _pageController.jumpToPage(2);
                            setState(() {
                              _currentPageIndex =
                                  1; // Update selected page index
                            });
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: _currentPageIndex == 1
                                ? Colors.white
                                : Color.fromARGB(255, 4, 63, 132),
                            backgroundColor: _currentPageIndex == 1
                                ? Color.fromARGB(255, 4, 63, 132)
                                : Colors.transparent,
                          ),
                          child: Text(
                            'Payment Received',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                  child: PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: _fetchpaymentlist('Delivered', 'payment left'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var Requestedorders = snapshot.data!.docs;
                        if (_searchQuery.isNotEmpty) {
                          Requestedorders = Requestedorders.where((Requestedorders) {
                            var RequestedordersName =
                                Requestedorders['clientName'].toString().toLowerCase();
                            return RequestedordersName.contains(_searchQuery);
                          }).toList();
                        }

                        if (Requestedorders.isEmpty) {
                          return Center(child: Text('No payments left.'));
                        }

                        return ListView.builder(
                          itemCount: Requestedorders.length,
                          itemBuilder: (context, index) {
                            var Requested = Requestedorders[index];
                            var RequestedordersDocId = Requested.id;
                            final timestamp =
                                Requested['timestamp'] as Timestamp?;

                            String formattedDate = 'N/A';
                            String formattedMonth = 'N/A';

                            // Check if timestamp is not null and convert to formatted date
                            if (timestamp != null) {
                              final dateTime = timestamp.toDate();
                              formattedDate = DateFormat('dd').format(dateTime);
                              formattedMonth =
                                  DateFormat('MMM').format(dateTime);
                            }

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    //Handle navigation to another page here
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MaterialDetails(
                                            userId: widget.userId,
                                            materialorderDocId:
                                                RequestedordersDocId, // Replace with your target page
                                          ),
                                        ));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 15),
                                    padding: EdgeInsets.all(10),
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
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Color.fromARGB(
                                                        255, 4, 63, 132),
                                                  )),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    Requested['materialName'],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    Requested['clientName'],
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
                                                      height: 150,
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      child: Column(
                                                        children: <Widget>[
                                                          ElevatedButton(
                                                            onPressed: () {
                                                              showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            25.0),
                                                                  ),
                                                                ),
                                                                builder:
                                                                    (BuildContext
                                                                        context) {
                                                                  return Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom,
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          20.0),
                                                                      child:
                                                                          Form(
                                                                        key:
                                                                            _formKey,
                                                                        child:
                                                                            Column(
                                                                          mainAxisSize:
                                                                              MainAxisSize.min,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            SizedBox(height: 10),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text('Client Name',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                    )),
                                                                                Text(Requested['clientName']),
                                                                              ],
                                                                            ),
                                                                            SizedBox(height: 10),
                                                                            TextFormField(
                                                                              controller: _amountController,
                                                                              keyboardType: TextInputType.number,
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Total amount',
                                                                                border: OutlineInputBorder(
                                                                                  borderRadius: BorderRadius.circular(0),
                                                                                ),
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value == null || value.isEmpty) {
                                                                                  return 'Please enter Total amount';
                                                                                }
                                                                                return null;
                                                                              },
                                                                            ),
                                                                            SizedBox(height: 10),
                                                                            TextFormField(
                                                                              controller: _ReceivedDateController,
                                                                              readOnly: true,
                                                                              onTap: () => _selectDate(context, _ReceivedDateController),
                                                                              decoration: InputDecoration(
                                                                                labelText: 'Received date',
                                                                                border: OutlineInputBorder(),
                                                                                focusedBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                                                                                ),
                                                                                enabledBorder: OutlineInputBorder(
                                                                                  borderSide: BorderSide(color: Color.fromARGB(255, 4, 63, 132)),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(height: 20),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                ElevatedButton(
                                                                                  onPressed: () async {
                                                                                    if (_formKey.currentState!.validate()) {
                                                                                      if (widget.userId != null && RequestedordersDocId != null) {
                                                                                        try {
                                                                                          await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('orders').doc(RequestedordersDocId).update({
                                                                                            'paymentstatus': 'payment received',
                                                                                            'amount': _amountController.text,
                                                                                            'receiveddate': _ReceivedDateController.text
                                                                                          });

                                                                                          // Show a success message using the global key
                                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                                            SnackBar(
                                                                                              content: Text('Accepted succesfully'),
                                                                                            ),
                                                                                          );
                                                                                          Navigator.pop(context);
                                                                                        } catch (e) {
                                                                                          // Show an error message using the global key
                                                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                                                            SnackBar(
                                                                                              content: Text('Failed to Accept order: $e'),
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      } else {
                                                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                                                          SnackBar(
                                                                                            content: Text('User ID or Project Document ID is null.'),
                                                                                          ),
                                                                                        );
                                                                                      }
                                                                                      // Process data (e.g., save the new project)
                                                                                      Navigator.of(context).pop();
                                                                                    }
                                                                                  },
                                                                                  child: Text(
                                                                                    'Save',
                                                                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                  ),
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: const Color.fromRGBO(1, 42, 86, 1),
                                                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(15),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                ElevatedButton(
                                                                                  onPressed: () {
                                                                                    Navigator.of(context).pop(); // Close the bottom sheet
                                                                                  },
                                                                                  child: Text(
                                                                                    'Cancel',
                                                                                    style: TextStyle(fontSize: 16, color: Colors.white),
                                                                                  ),
                                                                                  style: ElevatedButton.styleFrom(
                                                                                    backgroundColor: Color.fromARGB(255, 214, 10, 10),
                                                                                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                                    shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius.circular(15),
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
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      4,
                                                                      63,
                                                                      132),
                                                              // Button background color
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
                                                                'Received',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(height: 10),
                                                          ElevatedButton(
                                                            onPressed:
                                                                () async {
                                                              try {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(widget
                                                                        .userId)
                                                                    .collection(
                                                                        'orders')
                                                                    .doc(
                                                                        RequestedordersDocId)
                                                                    .delete();

                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                        'payment deleted successfully.'),
                                                                  ),
                                                                );

                                                                Navigator.pop(
                                                                    context); // Close the modal after deletion
                                                              } catch (e) {
                                                                // Show an error message
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                        'Failed to delete payment: $e'),
                                                                  ),
                                                                );
                                                                print(
                                                                    'Error deleting payment: $e'); // Log the error
                                                              } finally {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    _isLoading =
                                                                        false;
                                                                  });
                                                                }
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
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
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
                                      ],
                                    ),
                                  ),
                                ),
                                // Only add a Divider if it's not the last item
                                if (index < Requestedorders.length - 1)
                                  SizedBox(height: 10), // Divider between items
                              ],
                            );
                          },
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          _fetchpaymentlist('Delivered', 'payment received'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        var Acceptedorder = snapshot.data!.docs;
                        if (_searchQuery.isNotEmpty) {
                          Acceptedorder = Acceptedorder.where((Acceptedorder) {
                            var AcceptedorderName =
                                Acceptedorder['clientName'].toString().toLowerCase();
                            return AcceptedorderName.contains(_searchQuery);
                          }).toList();
                        }


                        if (Acceptedorder.isEmpty) {
                          return Center(child: Text('No received payments.'));
                        }

                        return ListView.builder(
                          itemCount: Acceptedorder.length,
                          itemBuilder: (context, index) {
                            var Accepted = Acceptedorder[index];
                            var AcceptedorderDocId = Accepted.id;
                            final timestamp =
                                Accepted['timestamp'] as Timestamp?;

                            String formattedDate = 'N/A';
                            String formattedMonth = 'N/A';

                            // Check if timestamp is not null and convert to formatted date
                            if (timestamp != null) {
                              final dateTime = timestamp.toDate();
                              formattedDate = DateFormat('dd').format(dateTime);
                              formattedMonth =
                                  DateFormat('MMM').format(dateTime);
                            }

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    // Handle navigation to another page here
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MaterialDetails(
                                          userId: widget.userId,
                                          materialorderDocId:
                                              AcceptedorderDocId,
                                        ), // Replace 'Transactionscreen' with your target page
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 15),
                                    padding: EdgeInsets.all(10),
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
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Color.fromARGB(
                                                        255, 4, 63, 132),
                                                  )),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    formattedDate,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                    Accepted['materialName'],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    Accepted['clientName'],
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black54,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                if (index < Acceptedorder.length - 1)
                                  SizedBox(
                                      height: 20), // Add space between items
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ])),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(
                Icons.shopping_cart,
                color: _selectedIndex == 0
                    ? Color.fromARGB(255, 4, 63, 132)
                    : Colors.grey,
              ),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.payment,
                color: _selectedIndex == 1
                    ? Color.fromARGB(255, 4, 63, 132)
                    : Colors.grey,
              ),
              label: 'Payments',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.category,
                color: _selectedIndex == 2
                    ? Color.fromARGB(255, 4, 63, 132)
                    : Colors.grey,
              ),
              label: 'Material',
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
