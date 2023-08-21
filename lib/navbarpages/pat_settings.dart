import 'package:flutter/material.dart';

//import 'package:records_application/screens/doctorlogin.dart';

import '../Services/patient_auth.dart';
import '../constants/custom_button.dart';
import '../screens/loginpage.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final AuthMethods _authMethods = AuthMethods();

  Future<void> signOut() async {
    await _authMethods.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 79, 112, 87),
        title: const Text('Settings'),
      ),
      body: Center(
        child: CustomButton(
          onTap: signOut,
          label: "signout",
        ),
      ),
    );
  }
}
