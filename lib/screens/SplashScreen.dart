import 'package:flutter/material.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(vsync: this);

    // Delay for 2 seconds before checking login status
    Future.delayed(Duration(seconds: 2), _checkLoginStatus);
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    String? userId = prefs.getString('userId');

    if (isLoggedIn && userId != null) {
      // Fetch the user's profession from Firestore
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (userDoc.exists) {
          // Safely cast the data to Map<String, dynamic>
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          
          String profession = userData['profession'] ?? '';
          if (profession == 'Material supplier') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Materialside(userId: userId,),
              ),
            );
          } else if (profession == 'owner') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProjectScreen(userId: userId),
              ),
            );
          } else {
            // Handle other professions or default screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PhoneScreen(),
              ),
            );
          }
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PhoneScreen(),
            ),
          );
        }
      } catch (e) {
        print('Error fetching user data: $e');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PhoneScreen(),
          ),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PhoneScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300, // Set the desired width
              height: 300, // Set the desired height
              child: Lottie.asset(
                'asset/Animation.json',
                controller: _controller,
                onLoaded: (composition) {
                  _controller
                    ..duration = composition.duration
                    ..forward();
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Effortless Site Management for Modern Builders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
