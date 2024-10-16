import 'package:field_force_management/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final MaterialPageRoute page;
  const FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Container(
      height: isWeb ? height / 2.5 : height / 3,
      width: isWeb ? width / 4 : width / 1.2,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 48.0,
                color: Colors.purple.shade200,
              ),
              SizedBox(height: isWeb ? 8 : 2),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: isWeb ? 8 : 2),
              Text(subtitle,
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.normal)),
              SizedBox(height: isWeb ? 8 : 2),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, page);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade200,
                  foregroundColor: Colors.white,
                ),
                child: Text(buttonLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}