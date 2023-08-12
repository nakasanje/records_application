import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../methods/firestore.dart';
import '../models/doctors.dart';

import '../models/patient.dart';
import '../models/share.dart';
import '../providers/doctor_provider.dart'; // Import the DoctorProvider
// Import the SharedRecordsProvider

class ReceivingDoctorPage extends StatefulWidget {
  static const String routeName = '/receivingDoctor';

  const ReceivingDoctorPage({Key? key}) : super(key: key);

  @override
  State<ReceivingDoctorPage> createState() => _ReceivingDoctorPageState();
}

class _ReceivingDoctorPageState extends State<ReceivingDoctorPage> {
  List<SharedRecordModel> sharedRecords = [];
  FirestoreMethods firestore = FirestoreMethods();
  late DoctorModel doctor;
  List<PatientModel> patients = [];
  List<PatientModel> filteredPatients = [];

  getUser() async {
    var snap = await firestore.doctorCollection.doc(firestore.doctor).get();
    doctor = DoctorModel.fromSnap(snap);

    fetchSharedRecords();
  }

  @override
  void initState() {
    super.initState();
    getUser();
    fetchPatients();
    addData();
    fetchSharedRecords();
  }

  @override
  void dispose() {
    super.dispose();
  }

  addData() async {
    DoctorProvider doctorProvider =
        Provider.of<DoctorProvider>(context, listen: false);
    await doctorProvider.refreshDoctor();
  }

  Future<void> fetchSharedRecords() async {
    try {
      final doctorId = doctor.doctorId;

      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('receivingDoctorId', isEqualTo: doctorId)
          .get();

      final recordsData = snapshot.docs.map<SharedRecordModel>((doc) {
        return SharedRecordModel.fromSnap(doc);
      }).toList();

      setState(() {
        sharedRecords = recordsData;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPatients() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      final patientsData = snapshot.docs.map<PatientModel>((doc) {
        return PatientModel(
          id: doc.id,
          name: doc['name'] ?? 'Unknown Name',
          age: doc['age'] ?? 'Unknown Age',
          testName: doc['testName'] ?? 'Unknown Test',
          doctorName: '',
          results: '',
        );
      }).toList();

      // Filter patients based on the patientIds from shared records
      filteredPatients = patientsData
          .where((patient) =>
              sharedRecords.any((record) => record.patientId == patient.id))
          .toList();

      setState(() {
        patients = patientsData;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Receive Your Records')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display shared records
            Expanded(
              child: ListView.builder(
                itemCount: sharedRecords.length,
                itemBuilder: (context, index) {
                  final record = sharedRecords[index];
                  final matchingPatient = patients.firstWhere(
                    (patient) => patient.id == record.patientId,
                  );

                  if (matchingPatient == null) {
                    return ListTile(
                      title: const Text('Unknown Patient'),
                      subtitle: Text('Patient ID: ${record.patientId}'),
                    );
                  }

                  return ListTile(
                      title: Text('PATIENT NAME: ${matchingPatient.name}'),
                      subtitle: Text('Patient ID: ${record.patientId}'),
                      onTap: () {
                        _showPatientDetailsDialog(matchingPatient);
                      });
                },
              ),
            ),
          ],
        ),
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
