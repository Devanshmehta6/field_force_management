import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/admin%20pages/attendancePage.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/models/user.dart';
import 'package:field_force_management/screens/attendancePage.dart';
import 'package:field_force_management/screens/login_screen.dart';
import 'package:field_force_management/services/location_service.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void getId() async {
    String? email = "";
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      email = user.email;
    } else {
      return null;
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Employee Attendance')
        .where('email', isEqualTo: email)
        .get();

    UserModel.id = querySnapshot.docs[0].id;
  }

  void _startLocationService() async {
    LocationService().initialize();

    LocationService().getLatitude().then((value) {
      // UserModel.lat = value!;
      setState(() {
        UserModel.lat = value!;
      });
    });

    LocationService().getLongitude().then((value) {
      // UserModel.long = value!;
      setState(() {
        UserModel.long = value!;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getId();
    _startLocationService();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('HomePage', style: GoogleFonts.poppins(fontSize: 16)),
        backgroundColor: Colors.purple.shade300,
      ),
      drawer: DrawerWidget(),
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
                          subtitle:
                              'Check the real-time location of your field employees',
                          buttonLabel: 'Manage →',
                          page: MaterialPageRoute(
                              builder: (context) => HomePage())),
                      FeatureCard(
                        icon: Icons.group,
                        title: 'Attendance',
                        subtitle:
                            'Attendance marking with location & track working hours',
                        buttonLabel: 'Manage →',
                        page: MaterialPageRoute(
                          builder: (context) {
                            if(UserModel.role == "Employee"){
                                return Attendancepage();
                              } else {
                                return AdminAttendance();
                              }
                          }
                        ),
                      ),
                      FeatureCard(
                          icon: Icons.grid_view,
                          title: 'Client Visits',
                          subtitle:
                              'Get Geo-verified client visits, photos & forms',
                          buttonLabel: 'Manage →',
                          page: MaterialPageRoute(
                              builder: (context) => HomePage())),
                      FeatureCard(
                          icon: Icons.grid_view,
                          title: 'Inventory Manager',
                          subtitle:
                              'Manage your inventory across all the stores',
                          buttonLabel: 'Manage →',
                          page: MaterialPageRoute(
                              builder: (context) => HomePage())),
                    ],
                  ),
                ),
              );
            } else {
              // Mobile layout
              return SizedBox(
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      FeatureCard(
                          icon: Icons.location_on,
                          title: 'Location Tracking',
                          subtitle:
                              'Check the real-time location of your field employees',
                          buttonLabel: 'Manage →',
                          page: MaterialPageRoute(
                              builder: (context) => HomePage())),
                      FeatureCard(
                        icon: Icons.group,
                        title: 'Attendance',
                        subtitle:
                            'Attendance marking with location & track working hours',
                        buttonLabel: 'Manage →',
                        page: MaterialPageRoute(
                            builder: (context){
                              if(UserModel.role == "Employee"){
                                return Attendancepage();
                              } else {
                                return AdminAttendance();
                              }
                            }),
                      ),
                      FeatureCard(
                        icon: Icons.grid_view,
                        title: 'Client Visits',
                        subtitle:
                            'Get Geo-verified client visits, photos & forms',
                        buttonLabel: 'Manage →',
                        page:
                            MaterialPageRoute(builder: (context) => HomePage()),
                      ),
                      FeatureCard(
                        icon: Icons.inventory,
                        title: 'Inventory Manager',
                        subtitle: 'Manage your inventory across all the stores',
                        buttonLabel: 'Manage →',
                        page:
                            MaterialPageRoute(builder: (context) => HomePage()),
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
                  Navigator.push(context, page);
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
