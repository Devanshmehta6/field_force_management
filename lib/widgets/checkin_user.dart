import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';

class CheckinUser extends StatefulWidget {
  const CheckinUser({super.key});

  @override
  State<CheckinUser> createState() => _CheckinUserState();
}

class _CheckinUserState extends State<CheckinUser> {
  String checkin = "--/--";
  String checkout = "--/--";
  String location = " ";

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getRecord();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Container(
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
                  child: Text(DateFormat("dd MMMM yyyy").format(DateTime.now()),
                      style: GoogleFonts.poppins(
                          fontSize: 18, fontWeight: FontWeight.normal)),
                ),
                StreamBuilder(
                    stream: Stream.periodic(Duration(seconds: 1))
                        .asBroadcastStream(),
                    builder: (context, snapshot) {
                      return Container(
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(top: 12),
                        // height: isWeb ? height / 3 : height / 4,
                        child: Text(
                            DateFormat(" HH:mm:ss a").format(DateTime.now()),
                            style: GoogleFonts.poppins(
                                fontSize: 18, fontWeight: FontWeight.normal)),
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
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          checkin,
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold),
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
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          checkout,
                          style: GoogleFonts.poppins(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            checkout == "--/--"
                ? Container(
                    margin: EdgeInsets.only(top: 20, bottom: 12),
                    child: Builder(builder: (context) {
                      final GlobalKey<SlideActionState> key = GlobalKey();
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
                          if (UserModel.lat != 0) {
                            // _getLocation();

                            final querySnapshot = await FirebaseFirestore
                                .instance
                                .collection('Employee Attendance')
                                .where('email', isEqualTo: UserModel.email)
                                .get();

                            final snap = await FirebaseFirestore.instance
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
                                "date": Timestamp.now(),
                                "checkout":
                                    DateFormat("HH:mm").format(DateTime.now()),
                                "location": location
                              });

                              checkout =
                                  DateFormat("HH:mm").format(DateTime.now());
                            } else {
                              await FirebaseFirestore.instance
                                  .collection("Employee Attendance")
                                  .doc(querySnapshot.docs[0].id)
                                  .collection("Record")
                                  .doc(DateFormat("dd MMMM yyyy")
                                      .format(DateTime.now()))
                                  .set({
                                "date": Timestamp.now(),
                                "checkin":
                                    DateFormat("HH:mm").format(DateTime.now()),
                                "checkout": "--/--",
                                "location": location
                              });
                              checkin =
                                  DateFormat("HH:mm").format(DateTime.now());
                            }

                            setState(() {});
                          } else {
                            Timer(Duration(seconds: 5), () async {
                              // _getLocation();

                              final querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection('Employee Attendance')
                                  .where('email', isEqualTo: UserModel.email)
                                  .get();

                              final snap = await FirebaseFirestore.instance
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
                                  "date": Timestamp.now(),
                                  "checkout": DateFormat("HH:mm")
                                      .format(DateTime.now()),
                                  "location": location
                                });

                                checkout =
                                    DateFormat("HH:mm").format(DateTime.now());
                              } else {
                                await FirebaseFirestore.instance
                                    .collection("Employee Attendance")
                                    .doc(querySnapshot.docs[0].id)
                                    .collection("Record")
                                    .doc(DateFormat("dd MMMM yyyy")
                                        .format(DateTime.now()))
                                    .set({
                                  "date": Timestamp.now(),
                                  "checkin": DateFormat("HH:mm")
                                      .format(DateTime.now()),
                                  "checkout": "--/--",
                                  "location": location
                                });
                                checkin =
                                    DateFormat("HH:mm").format(DateTime.now());
                              }

                              setState(() {});
                            });
                          }
                        },
                      );
                    }),
                  )
                : Container(
                    margin: EdgeInsets.only(top: 25, bottom: 12),
                    child: Text(
                      "Already checked out for today! See you tomorrow",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
            location != " "
                ? Container(
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(top: 12),
                    child: Text("Location" + location,
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}
