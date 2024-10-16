import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/models/user.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EmployeeClientVisits extends StatefulWidget {
  const EmployeeClientVisits({super.key});

  @override
  State<EmployeeClientVisits> createState() => _EmployeeClientVisitsState();
}

class _EmployeeClientVisitsState extends State<EmployeeClientVisits> {
  DateTimeRange? selectedDateRange;
  final DateFormat _dateFormatter = DateFormat('dd MMMM yyyy');

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDateRange) {
      setState(() {
        selectedDateRange = picked;
      });
      _fetchVisitsBetweenRange();
    }
  }

  void _setPreviousWeek() {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    setState(() {
      selectedDateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
    });
    _fetchVisitsBetweenRange();
  }

  void _setPreviousMonth() {
    DateTime now = DateTime.now();
    DateTime startOfMonth = DateTime(now.year, now.month - 1, 1);
    DateTime endOfMonth = DateTime(now.year, now.month, 0);

    setState(() {
      selectedDateRange = DateTimeRange(start: startOfMonth, end: endOfMonth);
    });
    _fetchVisitsBetweenRange();
  }

  Stream<QuerySnapshot> _fetchVisitsBetweenRange() {
    if (selectedDateRange != null) {
      DateTime startDate = selectedDateRange!.start;
      DateTime endDate = selectedDateRange!.end;

      // Replace this with actual query to fetch visits between date ranges for current employee
      return FirebaseFirestore.instance
          .collection('Client Visits')
          .where('assigned_to', isEqualTo: UserModel.username)
          .snapshots();
    }
    return Stream.empty();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        title: Text('Check your visits',
            style:
                GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.purple.shade200,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (selectedDateRange != null)
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(top: 12, left: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'From: ',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          _dateFormatter.format(selectedDateRange!.start),
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    // SizedBox(height: 15),
                    Row(
                      children: [
                        Text(
                          'To: ',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        Text(
                          _dateFormatter.format(selectedDateRange!.end),
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            Container(
              alignment: Alignment.topLeft,
              margin: EdgeInsets.only(top: 12, left: 12),
              child: isWeb
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade200,
                              foregroundColor: Colors.white),
                          onPressed: () => _selectDateRange(context),
                          child: Text(
                            'Pick Date Range',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade200,
                              foregroundColor: Colors.white),
                          onPressed: _setPreviousWeek,
                          child: Text(
                            'Previous Week',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade200,
                              foregroundColor: Colors.white),
                          onPressed: _setPreviousMonth,
                          child: Text(
                            'Previous Month',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade200,
                              foregroundColor: Colors.white),
                          onPressed: () => _selectDateRange(context),
                          child: Text(
                            'Pick Date Range',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade200,
                              foregroundColor: Colors.white),
                          onPressed: _setPreviousWeek,
                          child: Text(
                            'Previous Week',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 30),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple.shade200,
                              foregroundColor: Colors.white),
                          onPressed: _setPreviousMonth,
                          child: Text(
                            'Previous Month',
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
            ),
            Container(
              height: height,
              child: StreamBuilder<QuerySnapshot>(
                  stream: _fetchVisitsBetweenRange(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final snap = snapshot.data!.docs;
                      return ListView.builder(
                          itemCount: snap!.length,
                          itemBuilder: (context, index) {
                            // print(snap[index]['date_time'].toDate().runtimeType);
                            DateFormat dateFormat =
                                DateFormat("MMMM d, y 'at' h:mm:ss a z");
                            DateTime formatted_datetime =
                                dateFormat.parse(snap[index]['date_time']);
                            return formatted_datetime
                                        .isAfter(selectedDateRange!.start) &&
                                    formatted_datetime
                                        .isBefore(selectedDateRange!.end)
                                ? Card(
                                    elevation: 4.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 15.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Text(snap[index]['name'],
                                                style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            subtitle: Text(
                                              'Visited on: ${_dateFormatter.format(formatted_datetime)}',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade700),
                                            ),
                                            trailing: Icon(Icons.person,
                                                color: Colors.blue, size: 30.0),
                                          ),
                                          SizedBox(height: 10),
                                          Text('Visit Location:',
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold)),
                                          SizedBox(height: 5),
                                          Text(snap[index]['location'],
                                              style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  color: Colors.grey.shade700)),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container();
                          });
                    }
                    return Container();
                  }),
            )
          ],
        ),
      ),
    );
  }
}
