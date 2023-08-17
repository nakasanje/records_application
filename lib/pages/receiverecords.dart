import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../methods/firestore.dart';
import '../models/doctors.dart' as model;
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
  late model.DoctorModel doctor;
  List<PatientModel> patients = [];
  List<PatientModel> filteredPatients = [];

  @override
  void initState() {
    super.initState();
    fetchPatients();
    fetchSharedRecords();
  }

  Future<void> fetchSharedRecords() async {
    try {
      final doctorId = doctor.doctorId;

      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('receivingDoctorId', isEqualTo: doctorId)
          .where('approvalStatus', isEqualTo: 'approved')
          .get();

      final recordsData = snapshot.docs.map<SharedRecordModel>((doc) {
        return SharedRecordModel.fromSnap(doc);
      }).toList();

      setState(() {
        sharedRecords = recordsData;
        // Filter shared records based on the patientId and receivingDoctorId
        sharedRecords = sharedRecords
            .where((record) => patients.any(
                  (patient) =>
                      record.patientId == patient.id &&
                      record.receivingDoctorId == doctorId,
                ))
            .toList();
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPatients() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctor = doctorProvider.getDoctor;

    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('patients').get();

      final patientsData = snapshot.docs.map<PatientModel>((doc) {
        return PatientModel(
          id: doc.id,
          name: doc['name'] ?? 'Unknown Name',
          age: doc['age'] ?? 'Unknown Age',
          testName: doc['testName'] ?? 'Unknown Test',
          doctorName: doc['doctorName'],
          results: doc['results'],
          doctorId: doctor.doctorId,
        );
      }).toList();

      // Filter patients based on the patientIds from shared records

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
