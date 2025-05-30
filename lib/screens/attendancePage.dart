import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:field_force_management/models/user.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../widgets/checkin_user.dart';

// import 'package:http/http.dart' as http;

class Attendancepage extends StatefulWidget {
  const Attendancepage({super.key});

  @override
  State<Attendancepage> createState() => _AttendancepageState();
}

class _AttendancepageState extends State<Attendancepage>
    with SingleTickerProviderStateMixin {
  String checkin = "--/--";
  String checkout = "--/--";
  String location = " ";

  // Future<String?> getCurrentUserEmail() async {
  //   final User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     return user.email;
  //   } else {
  //     return null;
  //   }
  // }

  // Future<Map<String, dynamic>?> fetchUserDataByEmail(String email) async {
  //   final querySnapshot = await FirebaseFirestore.instance
  //       .collection('Employee Attendance')
  //       .where('email', isEqualTo: email)
  //       .get();

  //   if (querySnapshot.docs.isNotEmpty) {
  //     final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
  //     return userData;
  //   } else {
  //     return null;
  //   }
  // }

  // Future fetchUserName() async {
  //   final email = await getCurrentUserEmail();
  //   UserModel.email = email!;
  //   if (email != null) {
  //     final userData = await fetchUserDataByEmail(email);
  //     // print(user0Data);
  //     return userData;
  //   } else {
  //     return null;
  //   }
  // }

  void getRecord() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Employee Attendance')
          .where('email', isEqualTo: UserModel.email)
          .get();
      // UserModel.id = querySnapshot.docs[0].id;
      final snap = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .doc(querySnapshot.docs[0].id)
          .collection("Record")
          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
          .get();

      setState(() {
        checkin = snap["checkin"];
        checkout = snap["checkout"];
      });
    } catch (e) {
      setState(() {
        checkin = "--/--";
        checkout = "--/--";
      });
    }
  }

  // Throws exception as of 08 Oct 2024
  // void _getLocation() async {
  //   List<Placemark> placemark =
  //       await placemarkFromCoordinates(UserModel.lat, UserModel.long);
  //   setState(() {
  //     location = "${placemark[0].street}";
  //   });
  // }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRecord();
    
    // _getLocation();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  String _month = DateFormat("MMMM").format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
          drawer: DrawerWidget(),
          appBar: AppBar(
            backgroundColor: Colors.purple.shade200,
            bottom: TabBar(
              labelStyle: GoogleFonts.poppins(
                  fontSize: 16, fontWeight: FontWeight.bold),
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              tabs: [
                Tab(
                  icon: Icon(Icons.today),
                  text: "Today",
                ),
                Tab(icon: Icon(Icons.history), text: "History"),
              ],
            ),
            title: Text(
              'Welcome, ${UserModel.username}!',
              style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          body: TabBarView(
            children: [
              CheckinUser(),
              Container(
                margin: EdgeInsets.only(top: 12, right: 12, left: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 12),
                        child: Text(
                          "Track your history",
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Stack(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 12, left: 12),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _month,
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w400),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 12, right: 12),
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () async {
                                final month = await showMonthYearPicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(2024),
                                    lastDate: DateTime(2099),
                                    builder: (context, child) {
                                      return Theme(
                                        child: child!,
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Colors.purple.shade200,
                                            secondary: Colors.purple.shade200,
                                            onSecondary: Colors.white,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                                // backgroundColor:
                                                //     Colors.purple.shade200,
                                                ),
                                          ),
                                          textTheme: TextTheme(
                                            headlineMedium: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal),
                                            headlineLarge: GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold),
                                            headlineSmall: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    });

                                if (month != null) {
                                  print(month);
                                  setState(() {
                                    _month = DateFormat("MMMM").format(month);
                                    print(_month);
                                  });
                                }
                              },
                              child: Text(
                                "Pick a month here",
                                style: GoogleFonts.poppins(
                                    color: Colors.purple.shade200,
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: height - height / 5,
                        child: StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection("Employee Attendance")
                                .doc(UserModel.id)
                                .collection("Record")
                                .snapshots(),
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting)
                                return CupertinoActivityIndicator();
                              else {
                                if (snapshot.hasData) {
                                  final snap = snapshot.data!.docs;
                                  return ListView.builder(
                                      itemCount: snap!.length,
                                      itemBuilder: (context, index) {
                                        return DateFormat("MMMM").format(
                                                    snap[index]["date"]
                                                        .toDate()) ==
                                                _month
                                            ? Container(
                                                margin: EdgeInsets.only(
                                                    top: 12, left: 6, right: 6),
                                                height: height / 5,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.black26,
                                                        offset: Offset(2, 20),
                                                        blurRadius: 10),
                                                  ],
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(15)),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 30),
                                                        child: Text(
                                                          DateFormat("EE dd")
                                                              .format(snap[
                                                                          index]
                                                                      ["date"]
                                                                  .toDate()),
                                                          // snap[index].id.substring(0,2) + " " +snap[index].id.substring(3,6),
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  color: Colors
                                                                      .purple
                                                                      .shade300,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Check In",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                          ),
                                                          Text(
                                                            snap[index]
                                                                ["checkin"],
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            "Check Out",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal),
                                                          ),
                                                          Text(
                                                            snap[index]
                                                                ["checkout"],
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : SizedBox();
                                      });
                                } else {
                                  return Text("No record found");
                                }
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
