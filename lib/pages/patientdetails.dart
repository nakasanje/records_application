import 'package:flutter/material.dart';
import 'package:records_application/constants/space.dart';
import '../constants/custom_button.dart';
import '../models/patient.dart';
import 'edit.dart';

class PatientDetails extends StatelessWidget {
  const PatientDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final PatientModel patient =
        ModalRoute.of(context)!.settings.arguments as PatientModel;

    print('Received argument type: ${patient.runtimeType}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name: ${patient.name}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Age: ${patient.age}'),
            const SizedBox(height: 10),
            Text('Test Name: ${patient.testName}'),
            const SizedBox(height: 10),
            Text('Doctor Name: ${patient.doctorName}'),
            const SizedBox(height: 10),
            Text('Results: ${patient.results}'),
            const SizedBox(height: 20),
            const Space(),
            CustomButton(
              label: 'Edit',
              onTap: () {
                Navigator.pushNamed(
                  context,
                  EditPatientDetails.routeName,
                  arguments: patient, // Pass the patient to the edit page
                );
              },
            ),
          ],
          // You can add more patient-related information here
        ),
      ),
    );
  }
}
