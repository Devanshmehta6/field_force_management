import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:field_force_management/constants.dart';
import 'package:field_force_management/widgets/checkin_user.dart';
import 'package:field_force_management/widgets/drawer.dart';
import 'package:field_force_management/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScheduleVisit extends StatefulWidget {
  const ScheduleVisit({super.key});

  @override
  State<ScheduleVisit> createState() => _ScheduleVisitState();
}

class _ScheduleVisitState extends State<ScheduleVisit> {
  final _formKey = GlobalKey<FormState>();
  List<String> _checkedInEmployees = [];
  String? _selectedEmployee;

  Future<void> _fetchCheckedInEmployees() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection("Employee Attendance")
          .get();

      List<String> checkedInEmployees = [];

      for (var employeeDoc in snapshot.docs) {
        checkedInEmployees.add(employeeDoc['username']);
      }
      // print(checkedInEmployees);
      setState(() {
        _checkedInEmployees = checkedInEmployees;
      });
    } catch (e) {
      print("Error fetching checked-in employees: $e");
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCheckedInEmployees();
  }

  // Controllers for form fields
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _employeeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime? selectedDateTime;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
        selectedDateTime = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
        selectedDateTime = DateTime(
          selectedDateTime!.year,
          selectedDateTime!.month,
          selectedDateTime!.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Future<bool> saveData() async {
    try {
      await FirebaseFirestore.instance.collection('Client Visits').add({
        "name": _clientNameController.text.trim(),
        "assigned_to": _selectedEmployee,
        "location": _locationController.text.trim(),
        "date_time": DateFormat("MMMM d, y 'at' h:mm:ss a 'UTC'Z")
            .format(selectedDateTime!),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        backgroundColor: Colors.purple.shade200,
        title: Text(
          'Schedule your visit here',
          style: GoogleFonts.poppins(fontSize: 16),
        ),
      ),
      body: Center(
        child: SizedBox(
          width: isWeb ? width / 4 : width / 2,
          height: isWeb ? height / 1.2 : height / 1.5,
          child: Center(
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  InputField(
                    isReadOnly: false,
                    controller: _clientNameController,
                    hintText: "Client Name",
                    isPassword: false,
                  ),
                  SizedBox(height: 16),
                  InputField(
                    isReadOnly: true,
                    controller: _dateController,
                    icon: IconButton(
                      onPressed: () => _selectDate(context),
                      icon: Icon(Icons.calendar_today),
                    ),
                    hintText: "Pick date",
                    isPassword: false,
                  ),
                  SizedBox(height: 16),
                  InputField(
                    isReadOnly: true,
                    controller: _timeController,
                    hintText: "Select time",
                    icon: IconButton(
                      icon: Icon(Icons.access_time),
                      onPressed: () => _selectTime(context),
                    ),
                    isPassword: false,
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedEmployee,
                    items: _checkedInEmployees.map((String role) {
                      return DropdownMenuItem<String>(
                        value: role,
                        child: Text(role,
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.normal)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedEmployee = newValue;
                      });
                    },
                    onTap: () async {
                      _checkedInEmployees.isEmpty
                          ? CupertinoActivityIndicator()
                          : await _fetchCheckedInEmployees();
                    },
                    decoration: InputDecoration(
                      labelText: 'Assign Employee',
                      fillColor: Colors.grey.shade100,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  InputField(
                    isReadOnly: false,
                    controller: _locationController,
                    hintText: "Enter a location",
                    isPassword: false,
                  ),
                  SizedBox(height: 32),
                  Container(
                    height: height / 15,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade200,
                          foregroundColor: Colors.white),
                      onPressed: () async {
                        bool res = await saveData();
                        if (res) {
                          _clientNameController.clear();
                          _dateController.clear();
                          _timeController.clear();
                          _employeeController.clear();
                          _locationController.clear();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Successfully scheduled!',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                              'An error occured at the backend. Please retry!',
                              style: GoogleFonts.poppins(fontSize: 16),
                            )),
                          );
                        }
                        // if (_formKey.currentState!.validate()) {
                        //   // Process the data (e.g., save to a database or submit to a server)
                        // }
                      },
                      child: Text("Submit",
                          style: GoogleFonts.poppins(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
