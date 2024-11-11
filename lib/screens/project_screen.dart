import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/services.dart';
import 'package:myapp/screens/change_password.dart';
import 'package:myapp/screens/edit_profile.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/members.dart';
import 'package:myapp/screens/parties.dart';
import 'package:myapp/screens/quotations.dart';
import 'package:myapp/screens/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectScreen extends StatefulWidget {
  final String userId;

  const ProjectScreen({required this.userId});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  int _selectedIndex = 0;
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  PageController _pageController = PageController();
  int _currentPageIndex = 0;
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _clientNumberController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  bool _isLoading = false;
  String companyName = '';
  String? yourName;

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

  Future<void> _saveProject() async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference userRef =
            FirebaseFirestore.instance.collection('users').doc(widget.userId);

        CollectionReference projectsRef = userRef.collection('projects');

        await projectsRef.add({
          'projectName': _projectNameController.text.trim(),
          'clientName': _clientNameController.text.trim(),
          'clientNumber': _clientNumberController.text.trim(),
          'budget': _budgetController.text.trim(),
          'status': 'Ongoing',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project added successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add project: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<double> _fetchTotalPayments(String projectDocId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('projects')
          .doc(projectDocId)
          .collection('payment')
          .where('status', isEqualTo: 'payment in')
          .get();

      double total = 0.0;

      for (var doc in snapshot.docs) {
        total += doc[
            'amount']; // Assuming the field storing the payment amount is 'amount'
      }

      return total;
    } catch (e) {
      print('Error fetching payments: $e');
      return 0.0; // Return 0.0 in case of an error
    }
  }

  Future<double> _fetchTotalPaymentsOut(String projectDocId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('projects')
          .doc(projectDocId)
          .collection('payment')
          .where('status', isEqualTo: 'payment out')
          .get();

      double total = 0.0;

      for (var doc in snapshot.docs) {
        total += doc[
            'amount']; // Assuming the field storing the payment amount is 'amount'
      }

      return total;
    } catch (e) {
      print('Error fetching payments: $e');
      return 0.0; // Return 0.0 in case of an error
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index; // Update current page index
    });
  }

  Stream<QuerySnapshot> _fetchProjects(String status) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('projects')
        .where('status', isEqualTo: status)
        .snapshots();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ProjectScreen(userId: widget.userId)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => quotationscreen(userId: widget.userId)),
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
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
                        leading: Icon(Icons.person),
                        title: Text('Members'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Members(
                                  userId: widget
                                      .userId), // Make sure Members is imported
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
                              ), // Make sure ChangePassword is imported
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
                              ), // Make sure ChangePassword is imported
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Logout'),
                        onTap: () async {
                          // Clear login state from SharedPreferences
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.setBool(
                              'isLoggedIn', false); // Set 'isLoggedIn' to false
                          await prefs.remove(
                              'userId'); // Optionally, remove 'userId' as well

                          // Redirect to PhoneScreen
                          Navigator.pushReplacement(
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
                              'Projects',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 4, 63, 132),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Create and manage projects',
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
                          'asset/bulding.png',
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
                        _projectNameController.clear();
                        _clientNameController.clear();
                        _clientNumberController.clear();
                        _budgetController.clear();
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
                                        controller: _projectNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Project Name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a project name';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _clientNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Clinet  Name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^[a-zA-Z\s]+$')),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a client name';
                                          }
                                          if (!RegExp(r'^[a-zA-Z\s]+$')
                                              .hasMatch(value)) {
                                            return 'Please enter only characters';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: _clientNumberController,
                                        decoration: InputDecoration(
                                          labelText: 'Client Number',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please enter a client's number";
                                          } else if (value.length != 10) {
                                            return "Client number must be 10 digits";
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _budgetController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Budget',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a budget';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              if (_formKey.currentState!
                                                  .validate()) {
                                                _saveProject();
                                                Navigator.of(context).pop();
                                              }
                                            },
                                            child: Text(
                                              'Save',
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
                        'Add project',
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
              Container(
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
                            _currentPageIndex = 0; // Update selected page index
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
                          'Ongoing',
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
                          _pageController.jumpToPage(1);
                          setState(() {
                            _currentPageIndex = 1; // Update selected page index
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
                          'Completed',
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
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  children: [
                    // Ongoing Projects View
                    StreamBuilder<QuerySnapshot>(
                      stream: _fetchProjects('Ongoing'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                        }

                        var ongoingProjects = snapshot.data!.docs;

                        if (_searchQuery.isNotEmpty) {
                          ongoingProjects = ongoingProjects.where((project) {
                            var projectName =
                                project['projectName'].toString().toLowerCase();
                            return projectName.contains(_searchQuery);
                          }).toList();
                        }

                        if (ongoingProjects.isEmpty) {
                          return Center(child: Text('No ongoing projects.'));
                        }

                        return ListView.builder(
                          itemCount: ongoingProjects.length,
                          itemBuilder: (context, index) {
                            var project = ongoingProjects[index];
                            var projectDocId = project.id;

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Transactionscreen(
                                          userId: widget.userId,
                                          projectDocId: projectDocId,
                                        ),
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    project['projectName'],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    project['clientName'],
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
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              try {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(widget
                                                                        .userId)
                                                                    .collection(
                                                                        'projects')
                                                                    .doc(
                                                                        projectDocId)
                                                                    .update({
                                                                  'status':
                                                                      'completed'
                                                                });

                                                                Navigator.pop(
                                                                    context);
                                                              } catch (e) {
                                                                print(
                                                                    'Error: $e');
                                                              }
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
                                                                'set project status to completed',
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
                                                                        'projects')
                                                                    .doc(
                                                                        projectDocId)
                                                                    .delete();

                                                                Navigator.pop(
                                                                    context);
                                                              } catch (e) {
                                                                print(
                                                                    'Error deleting project: $e');
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
                                            ),
                                          ],
                                        ),
                                        Divider(color: Colors.black26),
                                        FutureBuilder<List<double>>(
                                          future: Future.wait([
                                            _fetchTotalPayments(
                                                projectDocId), // Fetch total "payment in"
                                            _fetchTotalPaymentsOut(
                                                projectDocId), // Fetch total "payment out"
                                          ]),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child: Text('Loading...'));
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
                                ),
                                if (index < ongoingProjects.length - 1)
                                  SizedBox(height: 10), // Divider between items
                              ],
                            );
                          },
                        );
                      },
                    ),

                    StreamBuilder<QuerySnapshot>(
                      stream: _fetchProjects('completed'),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                        }

                        var completedProjects = snapshot.data!.docs;

                        if (_searchQuery.isNotEmpty) {
                          completedProjects =
                              completedProjects.where((project) {
                            var projectName =
                                project['projectName'].toString().toLowerCase();
                            return projectName.contains(_searchQuery);
                          }).toList();
                        }

                        if (completedProjects.isEmpty) {
                          return Center(child: Text('No completed projects.'));
                        }

                        return ListView.builder(
                          itemCount: completedProjects.length,
                          itemBuilder: (context, index) {
                            var project = completedProjects[index];
                            var projectDocId = project.id;

                            return Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Transactionscreen(
                                          userId: widget.userId,
                                          projectDocId: projectDocId,
                                        ),
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    project['projectName'],
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    project['clientName'],
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
                                                            onPressed:
                                                                () async {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              try {
                                                                await FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'users')
                                                                    .doc(widget
                                                                        .userId)
                                                                    .collection(
                                                                        'projects')
                                                                    .doc(
                                                                        projectDocId)
                                                                    .update({
                                                                  'status':
                                                                      'Ongoing'
                                                                });

                                                                Navigator.pop(
                                                                    context);
                                                              } catch (e) {
                                                                print(
                                                                    'Error: $e');
                                                              }
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
                                                                'Reopen project',
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
                                                                        'projects')
                                                                    .doc(
                                                                        projectDocId)
                                                                    .delete();

                                                                Navigator.pop(
                                                                    context);
                                                              } catch (e) {
                                                                print(
                                                                    'Error deleting project: $e');
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
                                            ),
                                          ],
                                        ),
                                        Divider(color: Colors.black26),
                                        FutureBuilder<List<double>>(
                                          future: Future.wait([
                                            _fetchTotalPayments(
                                                projectDocId), // Fetch total "payment in"
                                            _fetchTotalPaymentsOut(
                                                projectDocId), // Fetch total "payment out"
                                          ]),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                  child: Text('Loading...'));
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
                                ),
                                if (index < completedProjects.length - 1)
                                  SizedBox(height: 10), // Divider between items
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
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
