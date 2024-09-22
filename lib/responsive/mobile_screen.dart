import 'package:field_force_management/screens/homepage.dart';
import 'package:field_force_management/screens/login_screen.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _checkLoginStatus();
  }

  // Future<void> _checkLoginStatus() async {
  //   final FirebaseAuth auth = FirebaseAuth.instance;
  //   final User? user = auth.currentUser;

  //   if (user != null) {
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
  //   } else {
  //     // User is not logged in, navigate to login page
  //     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    return user != null ? HomePage() : LoginScreen() ;
  }
}
