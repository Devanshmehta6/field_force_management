import 'package:field_force_management/admin%20pages/client%20visits/employee_history.dart';
import 'package:field_force_management/admin%20pages/client%20visits/previous_meetings.dart';
import 'package:field_force_management/admin%20pages/client%20visits/schedule_visit.dart';
import 'package:field_force_management/models/user.dart';
import 'package:field_force_management/screens/homepage.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/feature_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminClientVisits extends StatefulWidget {
  const AdminClientVisits({super.key});

  @override
  State<AdminClientVisits> createState() => _AdminClientVisitsState();
}

class _AdminClientVisitsState extends State<AdminClientVisits> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.purple.shade200,
        title: Text(
          'Client Visits',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                        icon: Icons.schedule,
                        title: 'Schedule a visit',
                        subtitle: 'Plan your next meeting with a client',
                        buttonLabel: 'Schedule now →',
                        page: MaterialPageRoute(
                          builder: (context) => ScheduleVisit(),
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.meeting_room,
                        title: 'Previous Meetings',
                        subtitle: 'Check-up on your previous meetings',
                        buttonLabel: 'Track Now →',
                        page: MaterialPageRoute(
                          builder: (context) => PreviousMeetings(),
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.track_changes,
                        title: 'Track an employee',
                        subtitle:
                            'See completed and on-going visits of your employees',
                        buttonLabel: 'Check Now →',
                        page: MaterialPageRoute(
                          builder: (context) => EmployeeHistory(),
                        ),
                      ),
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
                        icon: Icons.schedule,
                        title: 'Schedule a visit',
                        subtitle: 'Plan your next meeting with a client',
                        buttonLabel: 'Schedule now →',
                        page: MaterialPageRoute(
                          builder: (context) => ScheduleVisit(),
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.meeting_room,
                        title: 'Previous Meetings',
                        subtitle: 'Check-up on your previous meetings',
                        buttonLabel: 'Track Now →',
                        page: MaterialPageRoute(
                          builder: (context) => PreviousMeetings(),
                        ),
                      ),
                      FeatureCard(
                        icon: Icons.track_changes,
                        title: 'Track an employee',
                        subtitle:
                            'See completed and on-going visits of your employees',
                        buttonLabel: 'Check Now →',
                        page: MaterialPageRoute(
                          builder: (context) => EmployeeHistory(),
                        ),
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
