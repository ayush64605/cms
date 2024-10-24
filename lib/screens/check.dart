import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class FirebaseCheckScreen extends StatefulWidget {
  @override
  _FirebaseCheckScreenState createState() => _FirebaseCheckScreenState();
}

class _FirebaseCheckScreenState extends State<FirebaseCheckScreen> {
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkFirebaseConnection();
  }

  void _checkFirebaseConnection() async {
    try {
      await FirebaseFirestore.instance.collection('test').doc('testDoc').set({'testField': 'testValue'});
      setState(() {
        _isConnected = true;
      });
    } catch (e) {
      print('Failed to connect to Firebase: $e');
      setState(() {
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Firebase Connection Test')),
      body: Center(
        child: _isConnected
            ? Text('Connected to Firebase', style: TextStyle(color: Colors.green, fontSize: 24))
            : Text('Failed to connect to Firebase', style: TextStyle(color: Colors.red, fontSize: 24)),
      ),
    );
  }
}
