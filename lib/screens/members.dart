import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/screens/add_member.dart';
import 'package:myapp/screens/project_screen.dart';

class Members extends StatefulWidget {
  final String userId;

  const Members({required this.userId});

  @override
  State<Members> createState() => _MembersState();
}

class _MembersState extends State<Members> {
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      // Fetch members from Firestore where userId is the document ID in the 'users' collection
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('members')
          .get();

      // Extract member data from the query snapshot
      final members = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // Store document ID for deletion
          'memberName': doc['memberName'],
          'phoneNumber': doc['phoneNumber'],
          'memberType': doc['memberType'],
          'project': doc['project'],
        };
      }).toList();

      // Update the state with the fetched members
      setState(() {
        _members = members;
      });
    } catch (e) {
      // Handle errors appropriately, e.g., log them or show a message to the user
      print('Error fetching members: $e');
    }
  }

  Future<void> _deleteMember(String memberId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('members')
          .doc(memberId)
          .delete();

      // Remove the member from the local list and update the state
      setState(() {
        _members.removeWhere((member) => member['id'] == memberId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Member deleted successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete member: $e'),
        ),
      );
      print('Error deleting member: $e');
    }
  }

  void _showDeleteBottomSheet(String memberId) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 90,
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteMember(memberId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 214, 10, 10),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Delete',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
              builder: (context) => ProjectScreen(userId: widget.userId)),
          (Route<dynamic> route) => false,
        );
        return true;
      },
      child: Scaffold(
        body: Column(
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
                                    builder: (context) => ProjectScreen(userId:widget.userId),
                                  ),
                                );
                              },
                            ),
                            const Text(
                              'Members',
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
      
            // Members List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  final member = _members[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                    child: ListTile(
                      title: Text(member['memberName']),
                      subtitle: Text(
                          'Phone: ${member['phoneNumber']}\nType: ${member['memberType']}\nProject: ${member['project']}'),
                      isThreeLine: true,
                      trailing: IconButton(
                        padding: EdgeInsets.only(top: screenHeight*0.04, left: screenWidth*0.06),
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          _showDeleteBottomSheet(member['id']);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
      
            // Add Member Button
            Padding(
              padding: EdgeInsets.only(bottom: screenHeight*0.04),
              child: SizedBox(
                width: screenWidth * 0.8,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddMember(userId: widget.userId),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(1, 42, 86, 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'Add member',
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
