import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/models/user.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../widgets/checkin_user.dart';

class AdminAttendance extends StatefulWidget {
  const AdminAttendance({super.key});

  @override
  State<AdminAttendance> createState() => _AdminAttendanceState();
}

class _AdminAttendanceState extends State<AdminAttendance>
    with SingleTickerProviderStateMixin {
  String checkin = "--/--";
  String checkout = "--/--";
  String location = " ";
  TextEditingController employeeEmailCont = TextEditingController();
  List<Map<String, dynamic>> _records = [];
  bool methodCalled = false;
  late Future toHoldMethodCall;

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

  Future<List<Map<String, dynamic>>> fetchRecordsById() async {
    String email = employeeEmailCont.text.trim();
    if (email.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text('Please enter an email'),
      // ));
      return _records;
    }

    try {
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .where("email", isEqualTo: email)
          .get();

      // if (employeeSnapshot.docs.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text('No employee found with this email.'),
      //   ));
      //   return _records;
      // }
      String? _employeeId;
      _employeeId = employeeSnapshot.docs.first.id;

      QuerySnapshot recordSnapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .doc(_employeeId)
          .collection("Record")
          .get();

      _records = recordSnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {});
      // print(_records);
    } catch (e) {
      print("Error fetching records: $e");
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text('Error fetching records: $e'),
      //   ));
      // }
    }
    return _records;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getRecord();
  }

  Widget showFutureBuilder(height) {
    try {
      return FutureBuilder(
          future: toHoldMethodCall,
          builder: (context, snapshot) {
            print(snapshot.data);
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return Text('none');
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.active:
                return Text('active');
              case ConnectionState.done:
                if (snapshot.data!.isEmpty) {
                  return Center(
                    child: Text("No data available",
                        style: GoogleFonts.poppins(fontSize: 16)),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                      itemCount: _records.length,
                      itemBuilder: (context, index) {
                        return DateFormat("MMMM").format(
                                    snapshot.data[index]["date"].toDate()) ==
                                _month
                            ? Container(
                                margin:
                                    EdgeInsets.only(top: 12, left: 6, right: 6),
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
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: EdgeInsets.only(left: 30),
                                        child: Text(
                                          DateFormat("EE dd").format(snapshot
                                              .data![index]["date"]
                                              .toDate()),
                                          // snap[index].id.substring(0,2) + " " +snap[index].id.substring(3,6),
                                          style: GoogleFonts.poppins(
                                              color: Colors.purple.shade300,
                                              fontSize: 16,
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Check In",
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          Text(
                                            snapshot.data![index]["checkin"],
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Check Out",
                                            style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal),
                                          ),
                                          Text(
                                            snapshot.data![index]["checkout"],
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold),
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
                  return SizedBox();
                }
            }
          });
    } catch (e) {
      print("catch");
    }
    return SizedBox();
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
                  text: "My Attendance",
                ),
                Tab(icon: Icon(Icons.history), text: "Check Attendance"),
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
                width: isWeb ? width / 4 : width / 1.2,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(
                            top: 12, left: 12, right: 12, bottom: 12),
                        child: InputField(
                          hintText: "Enter employee email",
                          controller: employeeEmailCont,
                          isPassword: false,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 12),
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  textStyle: GoogleFonts.poppins(fontSize: 16),
                                  backgroundColor: Colors.purple.shade200,
                                  foregroundColor: Colors.white),
                              onPressed: () async {
                                toHoldMethodCall = fetchRecordsById();
                                methodCalled = true;
                              },
                              child: Text("Fetch for $_month",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400)),
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
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                      methodCalled == false
                          ? Container(
                              height: height - height / 2,
                              child: Center(
                                child: Text("Enter an email to see history!",
                                    style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.normal)),
                              ),
                            )
                          : Container(
                              height: height - height / 5,
                              child: showFutureBuilder(height))
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
