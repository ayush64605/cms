import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/add_task.dart';
import 'package:myapp/screens/file.dart';
import 'package:myapp/screens/material.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/transaction.dart';

class TaskScreen extends StatefulWidget {
  final String userId;
  final String projectDocId;

  const TaskScreen({required this.userId, required this.projectDocId});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String activeButton = 'Task';
  int notStartedCount = 0;
  int ongoingCount = 0;
  int completedCount = 0;
  List<DocumentSnapshot> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('projects')
          .doc(widget.projectDocId)
          .collection('tasks')
          .get();

      setState(() {
        tasks = querySnapshot.docs;
        notStartedCount =
            tasks.where((task) => task['status'] == 'Not started').length;
        ongoingCount =
            tasks.where((task) => task['status'] == 'Ongoing').length;
        completedCount =
            tasks.where((task) => task['status'] == 'Completed').length;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
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
                    // First Row: Project Name
                    Padding(
                      padding: EdgeInsets.only(top: screenHeight * 0.05),
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
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.28)),
                          const Text(
                            'Task',
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
                                  builder: (context) => Transactionscreen(
                                        userId: widget.userId,
                                        projectDocId: widget.projectDocId,
                                      ) // Make sure OTPScreen is imported
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
                                ), // Make sure OTPScreen is imported
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
              // Container divided into three parts with dividers
              Container(
                width: screenWidth * 0.9,
                margin: EdgeInsets.all(20.0),
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // First part: Not Started
                      Column(
                        children: [
                          Text(
                            'Not Started',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 63, 132),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$notStartedCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Divider
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                        width: 20,
                        indent: 10,
                        endIndent: 10,
                      ),
                      // Second part: Ongoing
                      Column(
                        children: [
                          Text(
                            'Ongoing',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 63, 132),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$ongoingCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      // Divider
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                        width: 20,
                        indent: 10,
                        endIndent: 10,
                      ),
                      // Third part: Completed
                      Column(
                        children: [
                          Text(
                            'Completed',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 4, 63, 132),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            '$completedCount',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              width: screenWidth * 1,
                              padding: EdgeInsets.all(10),
                              height: 100, // Set the height of the bottom sheet
                              child: Column(
                                children: [
                                  SizedBox(height: 17),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Delete the transaction from Firestore
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.userId)
                                          .collection('projects')
                                          .doc(widget.projectDocId)
                                          .collection('tasks')
                                          .doc(task.id)
                                          .delete();
                                      Navigator.pop(context);
                                      _fetchTasks();

                                      // Close the bottom sheet
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 214, 10, 10),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Align(
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
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
                        margin: EdgeInsets.only(
                            top: screenWidth * 0.05,
                            left: screenWidth * 0.05,
                            right: screenWidth * 0.05),
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.only(left: screenWidth * 0.02),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['taskName'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 4, 63, 132),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    '${task['startDate']} - ${task['endDate']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Column(
                              children: [
                                if (task['status'] != 'Completed')
                                  ElevatedButton(
                                    onPressed: () async {
                                      String newStatus;
                                      if (task['status'] == 'Not started') {
                                        newStatus = 'Ongoing';
                                      } else if (task['status'] == 'Ongoing') {
                                        newStatus = 'Completed';
                                      } else {
                                        return; // Do nothing if the status is not 'Not Started' or 'Ongoing'
                                      }

                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('users')
                                            .doc(widget.userId)
                                            .collection('projects')
                                            .doc(widget.projectDocId)
                                            .collection('tasks')
                                            .doc(task.id)
                                            .update({'status': newStatus});

                                        // Refresh the task list
                                        _fetchTasks();
                                      } catch (e) {
                                        print('Error updating task status: $e');
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromRGBO(1, 42, 86, 1),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      task['status'] == 'Not started'
                                          ? 'Start'
                                          : task['status'] == 'Ongoing'
                                              ? 'Complete'
                                              : 'View',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.05),
                child: SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddTask(
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
                      'Add Task',
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
