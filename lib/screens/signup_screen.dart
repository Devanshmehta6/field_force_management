import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/screens/homepage.dart';
import 'package:field_force_management/screens/login_screen.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailCont = TextEditingController();
  final TextEditingController passCont = TextEditingController();
  final TextEditingController userNameCont = TextEditingController();
  final TextEditingController phoneCont = TextEditingController();

  Future signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCont.text.trim(), password: passCont.text.trim());
      addDetails();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } catch (e) {
      String error = e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.substring(error.indexOf(']') + 1)),
        ),
      );
    }
  }

  Future addDetails() async{
    await FirebaseFirestore.instance.collection('Employee Attendance').add({
      "username" : userNameCont.text.trim(),
      "email" : emailCont.text.trim(),
      "phone" : phoneCont.text.trim()
    });
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
                        "Welcome! New User",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Sign Up Here",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.normal),
                      ),
                      SizedBox(height: 25),
                      InputField(
                        hintText: "Email",
                        controller: emailCont,
                        isPassword: false,
                      ),
                      SizedBox(height: 25),
                      InputField(
                        hintText: "Password",
                        controller: passCont,
                        isPassword: true,
                      ),
                      SizedBox(height: 25),
                      InputField(
                        hintText: "UserName",
                        controller: userNameCont,
                        isPassword: false,
                      ),
                      SizedBox(height: 25),
                      // InputField(
                      //   hintText: "Phone Number",
                      //   controller: phoneCont,
                      //   isPassword: false,
                      // ),
                      TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 10,
                        controller: phoneCont,
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade100,
                          filled: true,
                          hintText: "Phone Number",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))
                        ),
                      ),
                      SizedBox(height: 25),
                      ElevatedButton(
                          child: Text("Sign Up"),
                          onPressed: () {
                            signup();
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
                      Text("Already signed in?"),
                      TextButton(
                          child: Text("Login here"),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
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
