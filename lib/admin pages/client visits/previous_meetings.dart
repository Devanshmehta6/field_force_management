import 'package:field_force_management/screens/client_visits.dart';
import 'package:flutter/cupertino.dart';

class PreviousMeetings extends StatefulWidget {
  const PreviousMeetings({super.key});

  @override
  State<PreviousMeetings> createState() => _PreviousMeetingsState();
}

class _PreviousMeetingsState extends State<PreviousMeetings> {
  @override
  Widget build(BuildContext context) {
    return EmployeeClientVisits();
  }
}