import 'package:flutter/material.dart';
import '../constants/custom_button.dart';
import '../constants/space.dart';
import '../methods/firestore.dart';
import '../models/patient.dart';

class EditPatientDetails extends StatefulWidget {
  static const routeName = '/editPatientDetails';

  final PatientModel patient;

  const EditPatientDetails({required this.patient});

  @override
  _EditPatientDetailsState createState() => _EditPatientDetailsState();
}

class _EditPatientDetailsState extends State<EditPatientDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController testNameController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController resultsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with existing patient details
    nameController.text = widget.patient.name;
    ageController.text = widget.patient.age.toString();
    testNameController.text = widget.patient.testName;
    doctorNameController.text = widget.patient.doctorName;
    resultsController.text = widget.patient.results;
  }

  void _updatePatient() async {
    if (_formKey.currentState!.validate()) {
      final updatedPatient = PatientModel(
        id: widget.patient.id,
        name: nameController.text,
        age: int.parse(ageController.text),
        testName: testNameController.text,
        doctorName: doctorNameController.text,
        results: resultsController.text,
        doctorId: widget.patient.doctorId,
      );

      await FirestoreMethods().updatePatient(updatedPatient);

      Navigator.pop(context); // Navigate back to patient details screen
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    testNameController.dispose();
    doctorNameController.dispose();
    resultsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: testNameController,
              decoration: const InputDecoration(labelText: 'Test Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: doctorNameController,
              decoration: const InputDecoration(labelText: 'Doctor Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: resultsController,
              decoration: const InputDecoration(labelText: 'Results'),
              maxLines: 3,
            ),
            const Space(),
            CustomButton(
              onTap: _updatePatient,
              label: 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }
}
