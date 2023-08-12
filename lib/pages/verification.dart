import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:records_application/Admin/admindashboard.dart';
import 'package:records_application/screens/doctor_dashboard.dart';

class Verification extends StatefulWidget {
  static const routeName = "/verification";
  const Verification({Key? key}) : super(key: key);

  @override
  State<Verification> createState() => _VerificationState();
}

class _VerificationState extends State<Verification> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    doctorModeCheck();
  }

  doctorModeCheck() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('doctor')
              .doc(user.uid)
              .get();

      final data = snapshot.data();

      if (data != null && data.containsKey("role")) {
        setState(() {
          userRole = data["role"] as String;
        });
      } else {
        setState(() {
          userRole =
              "role"; // Replace with the appropriate default role or handle it accordingly
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userRole == "admin") {
      return const AdminDashboard();
    } else {
      return const Dashboard();
    }
  }
}
