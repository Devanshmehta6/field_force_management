import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/models/user.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeManagement extends StatefulWidget {
  const EmployeeManagement({super.key});

  @override
  State<EmployeeManagement> createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagement> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String generatePassword(String name) {
    String namePart = name.length >= 3
        ? name.substring(0, 3).toLowerCase()
        : name.toLowerCase();
    int randomNumber =
        Random().nextInt(900) + 100; // Generates a random 3-digit number
    return '$namePart$randomNumber@';
  }

  void _registerEmployee() async {
    String name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Enter employee name",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.normal))),
      );
      return;
    }

    // Generate email & password
    String email = name.toLowerCase().replaceAll(" ", "") + "@company.com";
    String password = generatePassword(name);
    UserModel.email = email;

    try {
      // Create user in Firebase Authentication
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save employee details in Firestore
      await _firestore
          .collection('Employee Attendance')
          .doc(userCredential.user!.uid)
          .set({
        'username': name,
        'email': email,
        'role': 'Employee',
        'phone' : _phoneController.text
      });

      _nameController.clear();
      _showCredentialDialog(email, password);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void _showCredentialDialog(String email, String password) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Employee Registered"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildCopyRow("Email", email),
              SizedBox(height: 10),
              _buildCopyRow("Password", password),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCopyRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            "$label: $value",
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
        IconButton(
          icon: Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: value));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "$label copied!",
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new Employee',
            style: GoogleFonts.poppins(
                fontSize: 18, fontWeight: FontWeight.normal)),
        backgroundColor: Colors.purple.shade200,
      ),
      drawer: DrawerWidget(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InputField(
                hintText: 'Employee Name',
                controller: _nameController,
                isPassword: false,
                isReadOnly: false),
            SizedBox(height: 20),
            InputField(
                hintText: 'Phone Number',
                controller: _phoneController,
                isPassword: false,
                isReadOnly: false),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registerEmployee,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade200,
                foregroundColor: Colors.white,
              ),
              child: Text('Register',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.normal)),
            ),
          ],
        ),
      ),
    );
  }
}
