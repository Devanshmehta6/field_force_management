// import 'd/art:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/models/user.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateReports extends StatefulWidget {
  const GenerateReports({super.key});

  @override
  State<GenerateReports> createState() => _GenerateReportsState();
}

class _GenerateReportsState extends State<GenerateReports> {
  TextEditingController employeeEmailCont = TextEditingController();
  bool wantsEmployee = false;

  List<Map<String, dynamic>> _records = [];
  Map<String, double> _dayWiseHours = {};
  Map<int, double> _weeklyHours = {};

  Map<String, Map<int, double>> _employeeWeeklyHours = {};
  Map<String, Map<int, int>> _employeeDaysWorked = {};
  Map<String, String> _employeeUsernames = {};

  Future<void> _fetchRecords() async {
    try {
      DateTime now = DateTime.now();
      DateTime firstDayOfPrevMonth = DateTime(now.year, now.month - 1, 1);
      DateTime lastDayOfPrevMonth = DateTime(now.year, now.month, 0);

      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .where("email", isEqualTo: employeeEmailCont.text)
          .get();

      String? _employeeId;
      _employeeId = employeeSnapshot.docs.first.id;

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .doc(_employeeId) // Replace with actual employee ID
          .collection("Record")
          .where('date', isGreaterThanOrEqualTo: firstDayOfPrevMonth)
          .where('date', isLessThanOrEqualTo: lastDayOfPrevMonth)
          .get();

      _processRecords(snapshot.docs);
    } catch (e) {
      print("Error fetching records: $e");
    }
  }

  void _processRecords(List<QueryDocumentSnapshot> records) {
    DateTime now = DateTime.now();
    DateTime firstDayOfPrevMonth = DateTime(now.year, now.month - 1, 1);

    for (var record in records) {
      DateTime date = record['date'].toDate();
      String checkInTime = record["checkin"];
      List<String> timeParts = checkInTime.split(":");
      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);
      double checkInTimeInHours = hours + (minutes / 60);

      String checkoutTime = record["checkout"];
      List<String> timeParts2 = checkoutTime.split(":");
      int hours2 = int.parse(timeParts2[0]);
      int minutes2 = int.parse(timeParts2[1]);
      double checkOutTimeInHours = hours2 + (minutes2 / 60);

      double totalHours = checkOutTimeInHours - checkInTimeInHours;

      // Calculate day-wise total hours
      _dayWiseHours[date.day.toString()] =
          (_dayWiseHours[date.day.toString()] ?? 0) + totalHours;

      // // Calculate weekly total hours
      int weekNumber = ((date.day - 1) ~/ 7) + 1;
      _weeklyHours[weekNumber] = (_weeklyHours[weekNumber] ?? 0) + totalHours;
    }

    setState(() {});
  }

  Future<pw.Document> _generatePDF() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text('Attendance Report - Previous Month',
                  style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text('Day-wise Total Hours:',
                  style: pw.TextStyle(fontSize: 20)),
              ..._dayWiseHours.entries.map(
                (entry) => pw.Text('Day ${entry.key}: ${entry.value} hours',
                    style: pw.TextStyle(fontSize: 16)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Weekly Total Hours:', style: pw.TextStyle(fontSize: 20)),
              ..._weeklyHours.entries.map(
                (entry) => pw.Text('Week ${entry.key}: ${entry.value} hours',
                    style: pw.TextStyle(fontSize: 16)),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  void _fetchAllEmployeeRecords() async {
    DateTime now = DateTime.now();
    DateTime firstDayOfPrevMonth = DateTime(now.year, now.month - 1, 1);
    DateTime lastDayOfPrevMonth = DateTime(now.year, now.month, 0);

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .get();

      for (var employeeDoc in snapshot.docs) {
        String username = employeeDoc['username'];
        _employeeUsernames[employeeDoc.id] = username;

        QuerySnapshot recordSnapshot = await FirebaseFirestore.instance
            .collection("Employee Attendance")
            .doc(employeeDoc.id)
            .collection("Record")
            .where('date', isGreaterThanOrEqualTo: firstDayOfPrevMonth)
            .where('date', isLessThanOrEqualTo: lastDayOfPrevMonth)
            .get();

        _processEmployeeRecords(employeeDoc.id, recordSnapshot.docs);
      }

      setState(() {});
    } catch (e) {
      print("Error fetching records: $e");
    }
  }

  Map<int, double> _initializeWeeklyHours() {
    return {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0};
  }

  Map<int, int> _initializeWeeklyDays() {
    return {1: 0, 2: 0, 3: 0, 4: 0};
  }

  void _processEmployeeRecords(
      String employeeId, List<QueryDocumentSnapshot> records) {
    Map<int, double> weeklyHours = _initializeWeeklyHours();
    Map<int, int> daysWorked = _initializeWeeklyDays();

    for (var record in records) {
      DateTime date = record['date'].toDate();

      String checkInTime = record["checkin"];
      List<String> timeParts = checkInTime.split(":");
      int hours = int.parse(timeParts[0]);
      int minutes = int.parse(timeParts[1]);
      double checkInTimeInHours = hours + (minutes / 60);

      String checkoutTime = record["checkout"];
      List<String> timeParts2 = checkoutTime.split(":");
      int hours2 = int.parse(timeParts2[0]);
      int minutes2 = int.parse(timeParts2[1]);
      double checkOutTimeInHours = hours2 + (minutes2 / 60);

      double totalHours = checkOutTimeInHours - checkInTimeInHours;

      // Calculate week number (1st week, 2nd week, etc.)
      int weekNumber = ((date.day - 1) ~/ 7) + 1;

      // Add hours and days worked for this employee in the given week
      weeklyHours[weekNumber] = (weeklyHours[weekNumber] ?? 0) + totalHours;
      daysWorked[weekNumber] = (daysWorked[weekNumber] ?? 0) + 1;
    }

    _employeeWeeklyHours[employeeId] = weeklyHours;
    _employeeDaysWorked[employeeId] = daysWorked;

    print(_employeeWeeklyHours);
  }

  Widget _buildEmployeeHoursChart(String employeeId) {
    final weeklyHours = _employeeWeeklyHours[employeeId];

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              // tooltipBgColor: Colors.blueGrey,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                String week = 'Week ${group.x.toInt()}';
                return BarTooltipItem(
                  '$week\n${rod.toY.toStringAsFixed(1)} hours',
                  TextStyle(color: Colors.white),
                );
              },
            ),
          ),
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 1:
                      return Text('Week 1');
                    case 2:
                      return Text('Week 2');
                    case 3:
                      return Text('Week 3');
                    case 4:
                      return Text('Week 4');
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barGroups: weeklyHours!.entries
              .map((entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        color: Colors.blue,
                        width: 20,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildEmployeeDaysChart(String employeeId) {
    final daysWorked = _employeeDaysWorked[employeeId];

    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 28),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) {
                  switch (value.toInt()) {
                    case 1:
                      return Text('Week 1');
                    case 2:
                      return Text('Week 2');
                    case 3:
                      return Text('Week 3');
                    case 4:
                      return Text('Week 4');
                  }
                  return Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: true),
          barGroups: daysWorked!.entries
              .map((entry) => BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value.toDouble(),
                        color: Colors.green,
                        width: 20,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.purple.shade200,
        title: Text(
          'Welcome, ${UserModel.username}!',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 12, left: 12),
              alignment: Alignment.topLeft,
              child: Text(
                "Whose report you want?",
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 12, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      setState(() {
                        wantsEmployee = !wantsEmployee;
                      });
                    },
                    child: Text(
                      "An Employee",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.purple.shade200,
                        foregroundColor: Colors.white),
                    onPressed: () {
                      _fetchAllEmployeeRecords();
                      setState(() {
                        // wantsEmployee = !wantsEmployee;
                      });
                    },
                    child: Text(
                      "Everybody",
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            wantsEmployee
                ? Column(
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
                      TextButton(
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.purple.shade200,
                            foregroundColor: Colors.white),
                        onPressed: () async {
                          await _fetchRecords();
                          final pdf = await _generatePDF();

                          // Display the PDF on the screen
                          await Printing.layoutPdf(
                              onLayout: (PdfPageFormat format) async =>
                                  pdf.save());
                        },
                        child: Text(
                          "Generate",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: _employeeWeeklyHours.keys.map((employeeId) {
                        String username = _employeeUsernames[employeeId] ??
                            "Unknown Employee";

                        return Column(
                          children: [
                            Text(
                              'Employee: $username',
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 20),
                            Text('Total Hours Worked per Week',
                                style: GoogleFonts.poppins(fontSize: 16)),
                            _buildEmployeeHoursChart(employeeId),
                            SizedBox(height: 20),
                            Text('Days Worked per Week',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                )),
                            _buildEmployeeDaysChart(employeeId),
                            SizedBox(height: 40),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
