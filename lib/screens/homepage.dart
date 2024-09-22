import 'package:field_force_management/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage', style: GoogleFonts.poppins(fontSize: 16)),
        backgroundColor: Colors.purple.shade200,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            if (constraints.maxWidth > 600) {
              // Desktop layout
              return SizedBox(
                width: constraints.maxWidth,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FeatureCard(
                        icon: Icons.location_on,
                        title: 'Location Tracking',
                        subtitle: 'Check the real-time location of your field employees',
                        buttonLabel: 'Learn More →',
                        color: Colors.blue,
                      ),
                      FeatureCard(
                        icon: Icons.group,
                        title: 'Attendance',
                        subtitle: 'Attendance marking with location & track working hours',
                        buttonLabel: 'Learn More →',
                        color: Colors.green,
                      ),
                      FeatureCard(
                        icon: Icons.grid_view,
                        title: 'Client Visits',
                        subtitle: 'Get Geo-verified client visits, photos & forms',
                        buttonLabel: 'Learn More →',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // Mobile layout
              return SizedBox(
                height:constraints.maxHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FeatureCard(
                        icon: Icons.location_on,
                        title: 'Location Tracking',
                        subtitle: 'Check the real-time location of your field employees',
                        buttonLabel: 'Learn More →',
                        color: Colors.blue,
                      ),
                      FeatureCard(
                        icon: Icons.group,
                        title: 'Attendance',
                        subtitle: 'Attendance marking with location & track working hours',
                        buttonLabel: 'Learn More →',
                        color: Colors.green,
                      ),
                      FeatureCard(
                        icon: Icons.grid_view,
                        title: 'Client Visits',
                        subtitle: 'Get Geo-verified client visits, photos & forms',
                        buttonLabel: 'Learn More →',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color color;
  const FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    
    return  Container(
        height: isWeb ? height / 2.5 : height / 3,
        width: isWeb ? width / 4 : width / 1.2,
        
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon, 
                  size: 48.0,
                  color: Colors.blue,
                ),
                SizedBox(height: isWeb ? 8 : 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isWeb ? 8 : 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: isWeb ? 8 : 2),
                ElevatedButton(
                  onPressed: () {
                    // Implement button action here
                  },
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
        ),
    );
  }
}