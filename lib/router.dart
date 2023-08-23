import 'dart:js';

import 'package:flutter/material.dart';
import 'package:records_application/pages/edit.dart';
import 'package:records_application/pages/receiverecords.dart';
import 'package:records_application/pages/uploadrecords.dart';
import 'package:records_application/pages/verification.dart';
import 'package:records_application/screens/doctorlogin.dart';
import 'package:records_application/screens/fetch_doctors.dart';
import 'package:records_application/screens/patientsignup.dart';
import 'models/patient.dart';
import 'pages/patientrecords.dart';
import 'pages/sharerecords.dart';

import 'screens/loginpage.dart';
import 'screens/doctor_signup.dart';

Route<dynamic> generateRoute(RouteSettings routeSettings) {
  switch (routeSettings.name) {
    case LoginPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const LoginPage(),
      );

    case DocLoginPage.routeName:
      return MaterialPageRoute(
        builder: (_) => const DocLoginPage(),
      );

    case SignUp.routeName:
      return MaterialPageRoute(
          settings: routeSettings, builder: (_) => const SignUp());

    case PSignUp.routeName:
      return MaterialPageRoute(builder: (_) => const PSignUp());

    case Fetch.routeName:
      return MaterialPageRoute(builder: (_) => const Fetch());

    case ShareRecords.routeName:
      return MaterialPageRoute(builder: (_) => const ShareRecords());

    case ReceivingDoctorPage.routeName:
      return MaterialPageRoute(builder: (_) => const ReceivingDoctorPage());

    case EditPatientDetails.routeName:
      return MaterialPageRoute(builder: (_) => const EditPatientDetails());

    case PatientRecords.routeName:
      return MaterialPageRoute(builder: (_) => const PatientRecords());

    case UploadRecords.routeName:
      return MaterialPageRoute(builder: (_) => const UploadRecords());

    case Verification.routeName:
      return MaterialPageRoute(builder: (_) => const Verification());

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(),
      );
  }
}
