import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:field_force_management/models/user.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class Attendancepage extends StatefulWidget {
  const Attendancepage({super.key});

  @override
  State<Attendancepage> createState() => _AttendancepageState();
}

class _AttendancepageState extends State<Attendancepage>
    with SingleTickerProviderStateMixin {
  String checkin = "--/--";
  String checkout = "--/--";

  Future<String?> getCurrentUserEmail() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.email;
    } else {
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchUserDataByEmail(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Employee Attendance')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final userData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return userData;
    } else {
      return null;
    }
  }

  Future fetchUserName() async {
    final email = await getCurrentUserEmail();
    UserModel.email = email!;
    if (email != null) {
      final userData = await fetchUserDataByEmail(email);
      // print(user0Data);
      return userData;
    } else {
      return null;
    }
  }

  void getRecord() async {
    try {
      print("cqguqth");
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Employee Attendance')
          .where('email', isEqualTo: UserModel.email)
          .get();

      final snap = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .doc(querySnapshot.docs[0].id)
          .collection("Record")
          .doc(DateFormat("dd MMMM yyyy").format(DateTime.now()))
          .get();

      print("cehck in ${UserModel.username}");

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserName().then((value) => getRecord());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Scaffold(
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
              title: FutureBuilder(
                  future: fetchUserName(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      final userData = snapshot.data!;
                      final name = userData['username'] as String?;
                      UserModel.username = name!;
                      return Container(
                        margin: EdgeInsets.only(top: 12),
                        child: Column(
                          children: [
                            Text(
                              'Welcome, $name!',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Text('No user is signed in');
                    }
                  })),
          body: TabBarView(
            children: [
              Container(
                margin: EdgeInsets.only(top: 12, right: 12, left: 12),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        // width: constraints.maxWidth,
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 12),
                        // height: isWeb ? height / 3 : height / 4,
                        child: Text("Today's Status",
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Row(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            margin: EdgeInsets.only(top: 12),
                            // height: isWeb ? height / 3 : height / 4,
                            child: Text(
                                DateFormat("dd MMMM yyyy")
                                    .format(DateTime.now()),
                                style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal)),
                          ),
                          StreamBuilder(
                              stream: Stream.periodic(Duration(seconds: 1)),
                              builder: (context, snapshot) {
                                return Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(top: 12),
                                  // height: isWeb ? height / 3 : height / 4,
                                  child: Text(
                                      DateFormat(" hh:mm:ss a")
                                          .format(DateTime.now()),
                                      style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal)),
                                );
                              }),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 12),
                        height: height / 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 20),
                                blurRadius: 10),
                          ],
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Check In",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    checkin,
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Check Out",
                                    style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  Text(
                                    checkout,
                                    style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      checkout == "--/--"
                          ? Container(
                              margin: EdgeInsets.only(top: 12),
                              child: Builder(builder: (context) {
                                final GlobalKey<SlideActionState> key =
                                    GlobalKey();
                                return SlideAction(
                                  innerColor: Colors.white,
                                  outerColor: Colors.purple.shade200,
                                  text: checkin == "--/--"
                                      ? "Slide to Check In"
                                      : "Slide to Check Out",
                                  textStyle: GoogleFonts.poppins(fontSize: 16),
                                  key: key,
                                  onSubmit: () async {
                                    // Future.delayed(Duration(seconds: 1),
                                    //     () => key.currentState!.reassemble());

                                    // key.currentState!.();
                                    final querySnapshot =
                                        await FirebaseFirestore.instance
                                            .collection('Employee Attendance')
                                            .where('email',
                                                isEqualTo: UserModel.email)
                                            .get();
                                    print(querySnapshot.docs[0]['email']);

                                    final snap = await FirebaseFirestore
                                        .instance
                                        .collection("Employee Attendance")
                                        .doc(querySnapshot.docs[0].id)
                                        .collection("Record")
                                        .doc(DateFormat("dd MMMM yyyy")
                                            .format(DateTime.now()))
                                        .get();

                                    if (snap.exists) {
                                      await FirebaseFirestore.instance
                                          .collection("Employee Attendance")
                                          .doc(querySnapshot.docs[0].id)
                                          .collection("Record")
                                          .doc(DateFormat("dd MMMM yyyy")
                                              .format(DateTime.now()))
                                          .update({
                                        "checkout": DateFormat("hh:mm")
                                            .format(DateTime.now()),
                                      });

                                      checkout = DateFormat("hh:mm")
                                          .format(DateTime.now());
                                    } else {
                                      await FirebaseFirestore.instance
                                          .collection("Employee Attendance")
                                          .doc(querySnapshot.docs[0].id)
                                          .collection("Record")
                                          .doc(DateFormat("dd MMMM yyyy")
                                              .format(DateTime.now()))
                                          .set({
                                        "checkin": DateFormat("hh:mm")
                                            .format(DateTime.now()),
                                      });
                                      checkin = DateFormat("hh:mm")
                                          .format(DateTime.now());
                                    }

                                    setState(() {
                                      
                                    });
                                    // if (snap.exists) {
                                    //   print("key 1----------- ${key.currentState!.submitted}");
                                    //   setState(() {
                                    //     checkout = DateFormat("hh:mm")
                                    //         .format(DateTime.now());
                                    //   });
                                    //   print("exists");
                                    //   await FirebaseFirestore.instance
                                    //       .collection("Employee Attendance")
                                    //       .doc(querySnapshot.docs[0].id)
                                    //       .collection("Record")
                                    //       .doc(DateFormat("dd MMMM yyyy")
                                    //           .format(DateTime.now())
                                    //           .toString())
                                    //       .update({
                                    //     "checkout": DateFormat("hh:mm")
                                    //         .format(DateTime.now())
                                    //   });
                                    // } else {
                                    //   print("key ----------- ${key.currentState!.submitted}");
                                    //   setState(() {
                                    //     checkin = DateFormat("hh:mm")
                                    //         .format(DateTime.now());
                                    //   });
                                    //   await FirebaseFirestore.instance
                                    //       .collection("Employee Attendance")
                                    //       .doc(querySnapshot.docs[0].id)
                                    //       .collection("Record")
                                    //       .doc(DateFormat("dd MMMM yyyy")
                                    //           .format(DateTime.now()))
                                    //       .set({
                                    //     "checkin": DateFormat("hh:mm")
                                    //         .format(DateTime.now()),
                                    //   });

                                    // }
                                  },
                                );
                              }),
                            )
                          : Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Text(
                                "Already checked out for today! See you tomorrow",
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              Icon(Icons.directions)
            ],
          ),
        ),
      ),
    );
  }
}
