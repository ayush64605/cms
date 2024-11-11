import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/change_password.dart';
import 'package:myapp/screens/edit_profile.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/m_transaction.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:myapp/screens/members.dart';
import 'package:myapp/screens/parties.dart';
import 'package:myapp/screens/quotations.dart';
import 'package:myapp/screens/transaction.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MMaterial extends StatefulWidget {
  final String userId;

  const MMaterial({required this.userId});

  @override
  State<MMaterial> createState() => _MMaterialState();
}

class _MMaterialState extends State<MMaterial> {
  int _selectedIndex = 2;
  final _formKey = GlobalKey<FormState>();
  PageController _pageController = PageController();
  int _currentPageIndex = 0; // Track page index
  final TextEditingController _materialNameController = TextEditingController();
  final TextEditingController _rateController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
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

  void dispose() {
    _materialNameController.dispose();
    _rateController.dispose();
    _unitController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _storeMaterialData(
      String materialName, String rate, String unit) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('allmaterial')
          .add({
        'materialName': materialName,
        'rate': rate,
        'unit': unit,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Material data stored successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Material added successfully')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error storing material data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred. Please try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPageIndex = index; // Update current page index
    });
  }

  Stream<QuerySnapshot> _fetchmaterial() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('allmaterial')
        .snapshots();
  }

  Future<void> updateMaterial(
      String materialId, String materialName, String rate, String unit) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('allmaterial')
          .doc(materialId)
          .update({
        'materialName': materialName,
        'rate': rate,
        'unit': unit,
      });
    } catch (e) {
      print("Error updating material: $e");
    }
  }

  Future<void> deleteMaterial(String materialId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('allmaterial')
          .doc(materialId)
          .delete();
    } catch (e) {
      print("Error deleting material: $e");
    }
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
              builder: (context) => Materialside(userId: widget.userId)),
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                              'Material',
                              style: TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 4, 63, 132),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Here add mterial which you have',
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
                          'asset/building.png',
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
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _materialNameController.clear();
                        _rateController.clear();
                        _unitController.clear();
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
                                      Text('Material Information',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          )),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _materialNameController,
                                        decoration: InputDecoration(
                                          labelText: 'Material Name',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a material name';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _rateController,
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Rate',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a rate';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(height: 10),
                                      TextFormField(
                                        controller: _unitController,
                                        decoration: InputDecoration(
                                          labelText: 'Unit',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter a unit';
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
                                            onPressed: _isLoading
                                                ? null
                                                : () {
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
                                          ElevatedButton(
                                            onPressed: _isLoading
                                                ? null
                                                : () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      _storeMaterialData(
                                                        _materialNameController
                                                            .text,
                                                        _rateController.text,
                                                        _unitController.text,
                                                      );
                                                    }
                                                  },
                                            child: _isLoading
                                                ? CircularProgressIndicator(
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
                                                      Colors.white,
                                                    ),
                                                  )
                                                : Text(
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
                        'Add Material',
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
              // PageView for project details
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _fetchmaterial(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(
                                Color.fromRGBO(1, 42, 86, 1)),));
                    }

                    var material = snapshot.data!.docs;
                    if (_searchQuery.isNotEmpty) {
                      material = material.where((material) {
                        var materialName =
                            material['materialName'].toString().toLowerCase();
                        return materialName.contains(_searchQuery);
                      }).toList();
                    }

                    if (material.isEmpty) {
                      return Center(child: Text('No material added.'));
                    }

                    return ListView.builder(
                      itemCount: material.length,
                      itemBuilder: (context, index) {
                        var data = material[index];
                        var materialId = data.id;

                        return Container(
                          width: screenWidth * 0.9,
                          height: screenHeight * 0.10,
                          margin: EdgeInsets.symmetric(
                              vertical: 5, horizontal: 17), // Add some margin
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
                            padding: EdgeInsets.all(10),
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
                                            data['materialName'] ?? 'No Name',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            'Rate: ${data['rate'] ?? 'No Rate'}',
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
                                        // Set the initial values for the text fields
                                        _materialNameController.text = data[
                                            'materialName']; // Replace with actual value
                                        _rateController.text = data[
                                            'rate']; // Replace with actual value
                                        _unitController.text = data[
                                            'unit']; // Replace with actual value

                                        showModalBottomSheet(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Container(
                                              height: screenHeight *
                                                  0.19, // Adjusted height for the modal
                                              padding: EdgeInsets.all(16),
                                              child: Column(
                                                children: <Widget>[
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          25.0)),
                                                        ),
                                                        builder: (BuildContext
                                                            context) {
                                                          return Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom,
                                                            ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      20.0),
                                                              child: Form(
                                                                key: _formKey,
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: <Widget>[
                                                                    Text(
                                                                        'Company name',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w600)),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                    TextFormField(
                                                                      controller:
                                                                          _materialNameController, // Set controller here
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Material Name',
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                        ),
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter a material name';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    TextFormField(
                                                                      controller:
                                                                          _rateController, // Set controller here
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Rate',
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                        ),
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter a rate';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    TextFormField(
                                                                      controller:
                                                                          _unitController, // Set controller here
                                                                      decoration:
                                                                          InputDecoration(
                                                                        labelText:
                                                                            'Unit',
                                                                        border:
                                                                            OutlineInputBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(15),
                                                                        ),
                                                                      ),
                                                                      validator:
                                                                          (value) {
                                                                        if (value ==
                                                                                null ||
                                                                            value.isEmpty) {
                                                                          return 'Please enter a unit';
                                                                        }
                                                                        return null;
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            20),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.of(context).pop(); // Close the bottom sheet
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Cancel',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.white),
                                                                          ),
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor: Color.fromARGB(
                                                                                255,
                                                                                214,
                                                                                10,
                                                                                10),
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(15),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            if (_formKey.currentState!.validate()) {
                                                                              // Process data (e.g., save the new project)
                                                                              // You can access the values like this:
                                                                              String materialId = data.id;
                                                                              String materialName = _materialNameController.text;
                                                                              String rate = _rateController.text;
                                                                              String unit = _unitController.text;
                                                                              print('Material Name: $materialName, Rate: $rate, Unit: $unit');

                                                                              updateMaterial(materialId, materialName, rate, unit);

                                                                              Navigator.of(context).pop();
                                                                              Navigator.of(context).pop();

                                                                              // Close the modal
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'Save',
                                                                            style:
                                                                                TextStyle(fontSize: 16, color: Colors.white),
                                                                          ),
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor: const Color.fromRGBO(
                                                                                1,
                                                                                42,
                                                                                86,
                                                                                1),
                                                                            padding:
                                                                                EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                                                            shape:
                                                                                RoundedRectangleBorder(
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
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          const Color.fromARGB(
                                                              255, 4, 63, 132),
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
                                                        'Edit',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      deleteMaterial(
                                                          materialId);
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
              label: 'Materials',
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
