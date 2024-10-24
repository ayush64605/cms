import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myapp/screens/a.dart';
import 'package:myapp/screens/add_material.dart';
import 'package:myapp/screens/add_quotation.dart';
import 'package:myapp/screens/add_task.dart';
import 'package:myapp/screens/b.dart';
import 'package:myapp/screens/check.dart';
import 'package:myapp/screens/client_project.dart';
import 'package:myapp/screens/ex.dart';
import 'package:myapp/screens/file.dart';
import 'package:myapp/screens/firstscreen.dart';
import 'package:myapp/screens/item_details.dart';
import 'package:myapp/screens/login.dart';
import 'package:myapp/screens/material.dart';
import 'package:myapp/screens/materialside.dart';
import 'package:myapp/screens/members.dart';
import 'package:myapp/screens/more_about.dart';
import 'package:myapp/screens/otp.dart';
import 'package:myapp/screens/parties.dart';
import 'package:myapp/screens/password.dart';
import 'package:myapp/screens/payment_in.dart';
import 'package:myapp/screens/payment_out.dart';
import 'package:myapp/screens/project_screen.dart';
import 'package:myapp/screens/quotations.dart';
import 'package:myapp/screens/task.dart';
import 'package:myapp/screens/transaction.dart';
import 'package:myapp/screens/try.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseAuth.instance.setLanguageCode('en');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PhoneScreen(),
    );
  }
}