import 'package:flutter/material.dart';

import 'package:records_application/screens/doctorlogin.dart';

import '../Services/doctor_auth.dart';
import '../constants/custom_button.dart';

class Settings2 extends StatefulWidget {
  const Settings2({super.key});

  @override
  State<Settings2> createState() => _Settings2State();
}

class _Settings2State extends State<Settings2> {
  final AuthMethod _authMethod = AuthMethod();

  Future<void> signOut() async {
    await _authMethod.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const DocLoginPage()));
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
