import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../methods/firestore.dart';
import '../models/patient.dart';
import '../models/patient_user.dart' as model;
import '../models/share.dart';
import '../providers/patient_user_provider.dart';

class ReceivingDoctorsScreen extends StatefulWidget {
  const ReceivingDoctorsScreen({super.key});

  @override
  State<ReceivingDoctorsScreen> createState() => _ReceivingDoctorsScreenState();
}

class _ReceivingDoctorsScreenState extends State<ReceivingDoctorsScreen> {
  List<SharedRecordModel> sharedRecords = [];
  FirestoreMethods firestore = FirestoreMethods();
  late model.PatientUser patientuser;

  @override
  void initState() {
    super.initState();
    fetchSharedRecords();
  }

  Future<void> fetchSharedRecords() async {
    try {
      final patientuserProvider =
          Provider.of<PatientUserProvider>(context, listen: false);
      patientuser = patientuserProvider.getPatientUser;
      final patientId = patientuser.patientId;

      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('id', isEqualTo: patientId)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Doctors')),
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

                  return ListTile(
                    title:
                        Text(' Sharing Doctor : ${record.sharingDoctorName}'),
                    subtitle:
                        Text('Receiving Doctor: ${record.receivingDoctorName}'),
                    onTap: () {
                      // Implement your logic for tapping on a record here
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
