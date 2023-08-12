import 'package:flutter/material.dart';
import 'package:records_application/screens/patientsignup.dart';
import 'package:records_application/screens/doctor_signup.dart';

import 'constants/custom_button.dart';

class SelectionPage extends StatelessWidget {
  const SelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signup Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignUp()),
                );
              },
              label: 'Signup as Doctor',
            ),
            const SizedBox(height: 20),
            CustomButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PSignUp()),
                );
              },
              label: 'Signup as Patient',
            ),
          ],
        ),
      ),
    );
  }
}
