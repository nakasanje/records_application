import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:records_application/Admin/admindashboard.dart';
import 'package:records_application/screens/patient_dashboard.dart';

class PatVerification extends StatefulWidget {
  const PatVerification({Key? key}) : super(key: key);

  @override
  State<PatVerification> createState() => _PatVerificationState();
}

class _PatVerificationState extends State<PatVerification> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    patientuserModeCheck();
  }

  patientuserModeCheck() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('patientuser')
              .doc(user.uid)
              .get();

      final data = snapshot.data();

      setState(() {
        userRole = data?["role"] as String;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == "admin") {
      return const AdminDashboard();
    } else {
      return const PatientDashboard();
    }
  }
}
