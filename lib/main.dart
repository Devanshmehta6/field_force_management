import 'package:field_force_management/admin%20pages/client%20visits/employee_history.dart';
import 'package:field_force_management/admin%20pages/client%20visits/schedule_visit.dart';
import 'package:field_force_management/admin%20pages/client_visits.dart';
import 'package:field_force_management/admin%20pages/employee_management.dart';
import 'package:field_force_management/firebase_options.dart';
import 'package:field_force_management/responsive/mobile_screen.dart';
import 'package:field_force_management/responsive/responsive.dart';
import 'package:field_force_management/responsive/web_screen.dart';
import 'package:field_force_management/screens/Inventory%20Manager/inventoryManager.dart';
import 'package:field_force_management/screens/client_visits.dart';
import 'package:field_force_management/screens/products.dart';
import 'package:field_force_management/screens/signup_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';
// import 'package:flutter_fire_cli/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Responsive(
        // mobileScreen: MobileScreen(),
        // webScreen: WebScreen(),
        mobileScreen: EmployeeManagement(),
        webScreen: EmployeeManagement(),
      ),
      localizationsDelegates: [
        MonthYearPickerLocalizations.delegate
      ],
    );
  }
}


