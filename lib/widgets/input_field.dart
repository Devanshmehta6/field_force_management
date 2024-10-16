import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final IconButton? icon;
  final bool isReadOnly;
  const InputField(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.isPassword,
      this.icon,
      required this.isReadOnly
      });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.isReadOnly,
      obscureText: widget.isPassword,
      controller: widget.controller,
      style: GoogleFonts.poppins(fontSize: 16),
      decoration: InputDecoration(
          suffixIcon: widget.icon,
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: widget.hintText,
          hintStyle: GoogleFonts.poppins(fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
    );
  }
}
