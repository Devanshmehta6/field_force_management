import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  const InputField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.isPassword});

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isPassword,
      controller: widget.controller,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}
