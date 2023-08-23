import 'package:flutter/material.dart';
import '../constants/custom_button.dart';
import '../constants/space.dart';
import '../methods/firestore.dart';
import '../models/patient.dart';
import '../models/patient_user.dart';

class EditPatientDetails extends StatefulWidget {
  static const routeName = '/editPatientDetails';

  const EditPatientDetails({
    super.key,
  });

  @override
  _EditPatientDetailsState createState() => _EditPatientDetailsState();
}

class _EditPatientDetailsState extends State<EditPatientDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController testNameController = TextEditingController();
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController resultsController = TextEditingController();

  final FirestoreMethods firestore = FirestoreMethods();
  List<PatientUser> patientsToApprove = [];
  String _doctorId = ''; // Make _id non-nullable
  String _name = '';
  int _age = 0;
  String _testName = '';
  String _results = '';
  String _date = '';
  String _doctorName = '';
  String _id = '';

  @override
  void initState() {
    super.initState();
  }

  // Navigate back to patient details screen
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      PatientModel patient = PatientModel(
        date: _date,
        id: _id,
        name: nameController.text, // Use the controller's text
        age: int.parse(ageController.text), // Parse the text to an int
        testName: testNameController.text, // Use the controller's text
        results: resultsController.text, // Use the controller's text
        doctorName: doctorNameController.text, // Use the controller's text
        doctorId: _doctorId,
      );

      await firestore.updatePatient(patient);

      // Clear the text fields
      nameController.clear();
      ageController.clear();
      dateController.clear();
      testNameController.clear();
      doctorNameController.clear();
      resultsController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient details updated successfully')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    dateController.dispose();
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
              controller: dateController,
              decoration: const InputDecoration(labelText: 'Date'),
            ),
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
              onTap: _submitForm,
              label: 'Save Changes',
            ),
          ],
        ),
      ),
    );
  }
}
