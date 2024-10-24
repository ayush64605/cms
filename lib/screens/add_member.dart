import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/material.dart';
import 'package:myapp/screens/members.dart';
import 'package:myapp/screens/task.dart';

class AddMember extends StatefulWidget {
  final String userId;

  const AddMember({super.key, required this.userId});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedMemberType;
  String? _selectedProject;
  List<String> _projects = [];

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    try {
      // Fetch projects from Firestore where userId is the document ID in the 'users' collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('projects')
          .get();

      // Extract project names from the query snapshot
      final projects = querySnapshot.docs.map((doc) => doc['projectName'].toString()).toList();

      // Update the state with the fetched projects
      setState(() {
        _projects = projects;
      });
    } catch (e) {
      // Handle errors appropriately, e.g., log them or show a message to the user
      print('Error fetching projects: $e');
    }
  }

  Future<void> _saveMember() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('members')
          .add({
        'memberName': _taskNameController.text,
        'phoneNumber': _priceController.text,
        'memberType': _selectedMemberType,
        'project': _selectedProject,
      });

      // Navigate back or show a success message
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Members(userId: widget.userId),
        ),
      );
    } catch (e) {
      // Handle errors appropriately, e.g., log them or show a message to the user
      print('Error saving member: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
              builder: (context) => Members(userId: widget.userId)),
          (Route<dynamic> route) => false,
        );
        return true;
      },
      child: Scaffold(
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
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Members(userId: widget.userId),
                                    ),
                                  );
                                },
                              ),
                              const Text(
                                'Add Member',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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
                    // Member Name field
                    TextFormField(
                      controller: _taskNameController,
                      decoration: InputDecoration(
                        labelText: 'Member Name',
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
                    // Phone no. field
                    TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Phone no.',
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
                    // Member Type dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedMemberType,
                      decoration: InputDecoration(
                        labelText: 'Member Type',
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
                      items: ['Client', 'Employee', 'Material Supplier']
                          .map((memberType) => DropdownMenuItem<String>(
                                value: memberType,
                                child: Text(memberType),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedMemberType = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    // Project dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedProject,
                      decoration: InputDecoration(
                        labelText: 'Project',
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
                      items: _projects
                          .map((project) => DropdownMenuItem<String>(
                                value: project,
                                child: Text(project),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedProject = newValue;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
      
              // Save Button
              Padding(
                padding: EdgeInsets.only(top: screenHeight * 0.40),
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveMember,
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
      ),
    );
  }
}
