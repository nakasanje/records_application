import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/custom_button.dart';
import '../models/patient.dart';
import '../models/doctors.dart' as model;
import '../providers/doctor_provider.dart';
import 'add.dart';

class PatientRecords extends StatefulWidget {
  static const String routeName = '/PatientRecords';

  const PatientRecords({Key? key}) : super(key: key);

  @override
  State<PatientRecords> createState() => _PatientRecordsState();
}

class _PatientRecordsState extends State<PatientRecords> {
  List<PatientModel> patients = [];
  List<PatientModel> filteredPatients = [];
  late model.DoctorModel doctor;

  @override
  void initState() {
    super.initState();
    fetchPatients();
    fetchDoctorDetails();
  }

  Future<void> fetchPatients() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctor = doctorProvider.getDoctor;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('id', isEqualTo: doctor.doctorId) // Filter by doctor's ID
          .get();

      final patientsData = snapshot.docs.map<PatientModel>((doc) {
        return PatientModel(
          id: doctor.doctorId,
          name: doc['name'] ?? 'Unknown Name',
          age: doc['age'] ?? 'Unknown Age',
          testName: doc['testName'] ?? 'Unknown Test',
          doctorName: doc['doctorName'],
          results: doc['results'],
        );
      }).toList();

      setState(() {
        patients = patientsData;
        filteredPatients = patientsData;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchDoctorDetails() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctor = doctorProvider.getDoctor;
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      filteredPatients = patients
          .where((patient) =>
              patient.name.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 79, 112, 87),
        title: Text('Welcome Doctor, ${doctor.username}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchTextChanged,
              decoration: const InputDecoration(
                hintText: 'Search Patients',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          CustomButton(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPatientPage(),
                ),
              );
            },
            label: 'Add Patient',
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPatients.length,
              itemBuilder: (context, index) {
                final patient = filteredPatients[index];
                return ListTile(
                  title: Text(patient.name),
                  subtitle: Text('Age: ${patient.age}'),
                  onTap: () {
                    _showPatientDetailsDialog(patient);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientDetailsDialog(PatientModel patient) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // ... other dialog content
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/PatientDetails',
                  arguments: patient, // Pass the selected patient
                );
              },
              child: const Text('Show Details'),
            ),
          ],
        );
      },
    );
  }
}
