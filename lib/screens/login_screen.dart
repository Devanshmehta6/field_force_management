import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/screens/homepage.dart';
import 'package:field_force_management/screens/signup_screen.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();
  late SharedPreferences sharedPreferences;

  Future loginIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailCont.text.trim(), password: passCont.text.trim());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String error = "";
      if (e.code == 'user-not-found') {
        error = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        error = 'Wrong password provided.';
      } else {
        error = 'Error: ${e.code}';
      }
      // String error = e.toString();
      // print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: isWeb ? width / 4 : width / 1.2,
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        "Welcome!",
                        style: GoogleFonts.poppins(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Login Here",
                        style: GoogleFonts.poppins(
                            fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 25),
                      InputField(
                          hintText: "Email",
                          controller: emailCont,
                          isPassword: false),
                      SizedBox(height: 25),
                      InputField(
                        hintText: "Password",
                        controller: passCont,
                        isPassword: true,
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                          child: Text("Login",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            loginIn();
                          },
                          style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 20),
                              textStyle: TextStyle(fontSize: 16),
                              backgroundColor: Colors.blue))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("New user?",
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.normal)),
                      TextButton(
                          child: Text("Sign Up here",
                              style: GoogleFonts.poppins(
                                  fontSize: 16, fontWeight: FontWeight.normal)),
                          onPressed: () {
                            
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => SignUpScreen(),
                              ),
                            );
                          })
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
