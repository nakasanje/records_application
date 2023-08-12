import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../methods/firestore.dart';
import '../models/doctors.dart';
import '../models/share.dart';
import '../providers/doctor_provider.dart';

class ReceivingDoctorsScreen extends StatefulWidget {
  final String currentPatientId;

  const ReceivingDoctorsScreen({Key? key, required this.currentPatientId})
      : super(key: key);

  @override
  _ReceivingDoctorsScreenState createState() => _ReceivingDoctorsScreenState();
}

class _ReceivingDoctorsScreenState extends State<ReceivingDoctorsScreen> {
  List<DoctorModel> receivingDoctors = [];
  List<SharedRecordModel> sharedRecords = [];
  FirestoreMethods firestore = FirestoreMethods();
  late DoctorModel doctor;

  List<DoctorModel> filteredDoctor = [];

  getUser() async {
    var snap = await firestore.doctorCollection.doc(firestore.doctor).get();
    doctor = DoctorModel.fromSnap(snap);

    fetchSharedRecords();
  }

  @override
  void initState() {
    super.initState();
    getUser();
    fetchDoctorDetails();
    fetchReceivingDoctors();
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

  Future<void> fetchDoctorDetails() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctor = doctorProvider.getDoctor;
  }

  Future<void> fetchReceivingDoctors() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('SharedRecords')
          .where('receivingDoctorId', isEqualTo: doctor.doctorId)
          .get();

      final receivingDoctorsData = snapshot.docs
          .map<DoctorModel>((doc) {
            return DoctorModel(
              doctorId: '',
              username: 'Unknown Name',
              email: 'Unknown Email',
              photoUrl: '',
              // Other properties of the receiving doctor
            );
          })
          .toSet() // Remove duplicates
          .toList();

      filteredDoctor = receivingDoctorsData
          .where((doctor) => sharedRecords
              .any((record) => record.receivingDoctorId == doctor.doctorId))
          .toList();

      setState(() {
        receivingDoctors = receivingDoctorsData;
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
                  itemCount: filteredDoctor.length,
                  itemBuilder: (context, index) {
                    final record = sharedRecords[index];
                    final matchingDoctor = receivingDoctors.firstWhere(
                      (doctor) => doctor.doctorId == record.receivingDoctorId,
                    );

                    if (matchingDoctor == null) {
                      return ListTile(
                        title: const Text('Unknown Patient'),
                        subtitle:
                            Text('Patient ID: ${record.receivingDoctorId}'),
                      );
                    }
                    return ListTile(
                      title: Text('Doctor Name: ${matchingDoctor.username}'),
                      subtitle: Text('Doctor Email: ${matchingDoctor.email}'),
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void _revokeAccess(DoctorModel doctor) async {
    // Implement the logic to revoke access here
  }
}
