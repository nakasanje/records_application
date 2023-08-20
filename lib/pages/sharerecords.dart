// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:search_choices/search_choices.dart';

import '../constants/custom_button.dart';

import '../models/doctors.dart';
import '../models/doctors.dart' as model;
import '../models/patient.dart';
import '../models/patient_user.dart';
import '../models/share.dart';
import '../providers/doctor_provider.dart';
// Import the DoctorProvider
// Import the DoctorModel

class ShareRecords extends StatefulWidget {
  static const String routeName = '/shareRecords';

  const ShareRecords({Key? key}) : super(key: key);

  @override
  State<ShareRecords> createState() => _ShareRecordsState();
}

class _ShareRecordsState extends State<ShareRecords> {
  PatientModel? selectedPatient;
  List<PatientModel> patients = [];
  DoctorModel?
      selectedReceivingDoctor; // Use DoctorModel instead of ReceivingDoctorModel
  List<DoctorModel> receivingDoctor = [];
  PatientUser? selectedpatientsToApprove;
  List<PatientUser> patientsToApprove = [];
  late model.DoctorModel doctor;

  TextEditingController patientSearchController = TextEditingController();
  TextEditingController doctorSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatients();
    fetchReceivingDoctors();
    fetchPatientsToApprove(); // Fetch the list of patients to approve
  }

  Future<void> fetchPatientsToApprove() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('patientuser').get();

      final patientuser = snapshot.docs.map<PatientUser>((doc) {
        return PatientUser(
          role: doc['role'],
          patientId: doc.id,
          username: doc['username'] ?? 'Unknown Name',
          email: doc['email'] ?? 'Unknown Email',
          photoUrl: '',
          // Other properties of the receiving doctor
        );
      }).toList();

      setState(() {
        patientsToApprove = patientuser;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchPatients() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctor = doctorProvider.getDoctor;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('patients')
          .where('doctorId',
              isEqualTo: doctor.doctorId) // Filter by doctor's ID
          .get();

      final patientsData = snapshot.docs.map<PatientModel>((doc) {
        return PatientModel(
          id: doc.id,
          doctorId: doctor.doctorId,
          name: doc['name'] ?? 'Unknown Name',
          age: doc['age'] ?? 'Unknown Age',
          testName: doc['testName'] ?? 'Unknown Test',
          doctorName: doc['doctorName'],
          results: doc['results'],
        );
      }).toList();

      setState(() {
        patients = patientsData;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchReceivingDoctors() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('doctor').get();

      final doctorsData = snapshot.docs.map<DoctorModel>((doc) {
        return DoctorModel(
          doctorId: doc.id,
          username: doc['username'] ?? 'Unknown Name',
          email: doc['email'] ?? 'Unknown Email',
          photoUrl: '',
          role: "doctor",
          // Other properties of the receiving doctor
        );
      }).toList();

      setState(() {
        receivingDoctor = doctorsData;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _shareRecord() async {
    if (selectedPatient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a patient to share')),
      );
      return;
    }
    if (selectedReceivingDoctor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the receiving doctor')),
      );
      return;
    }

    // Fetch the receiving doctor's details from DoctorProvider
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final DoctorModel sharingDoctor = doctorProvider.getDoctor;

    final sharingDoctorId = sharingDoctor.doctorId;
    final sharingDoctorName = sharingDoctor.username;
    const approvalStatus = 'pending';

    final sharedRecord = SharedRecordModel(
      receivingDoctorName: selectedReceivingDoctor!.username,
      patientId: selectedPatient!.id,
      sharingDoctorId: sharingDoctorId,
      receivingDoctorId: selectedReceivingDoctor!.doctorId,
      approvalStatus: approvalStatus,
      id: selectedpatientsToApprove!.patientId,
      sharingDoctorName: sharingDoctorName,
    );

    try {
      await FirebaseFirestore.instance
          .collection('SharedRecords')
          .add(sharedRecord.toJson());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record sharing request sent')),
      );

      setState(() {
        selectedPatient = null;
        selectedReceivingDoctor = null;
        selectedpatientsToApprove = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sharing record: $error')),
      );
    }
  }

  void _onSearchTextChanged(String searchText) {
    setState(() {
      // Use the filter functions here or any other logic you prefer
      selectedPatient = patients.firstWhere(
        (patient) =>
            patient.name.toLowerCase().contains(searchText.toLowerCase()),
      );
      selectedReceivingDoctor = receivingDoctor.firstWhere(
        (doctor) =>
            doctor.email.toLowerCase().contains(searchText.toLowerCase()),
      );
      selectedpatientsToApprove = patientsToApprove.firstWhere(
        (patientUser) =>
            patientUser.email.toLowerCase().contains(searchText.toLowerCase()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Patient Records')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
// Inside _ShareRecordsState class

            SearchChoices.single(
              value: selectedPatient,
              items: patients.map((PatientModel patient) {
                return DropdownMenuItem(
                  value: patient,
                  child: Text(patient.name),
                );
              }).toList(),
              onChanged: _onSearchTextChanged,
              displayClearIcon: false, // Optionally remove the clear icon
              hint: "Select patient records",
            ),

            SearchChoices.single(
              value: selectedReceivingDoctor,
              items: receivingDoctor.map((DoctorModel doctor) {
                return DropdownMenuItem(
                  value: doctor,
                  child: Text(doctor.email),
                );
              }).toList(),
              onChanged: _onSearchTextChanged,
              displayClearIcon: false, // Optionally remove the clear icon
              hint: "Select receiving doctor",
            ),

            SearchChoices.single(
              value: selectedpatientsToApprove,
              items: patientsToApprove.map((PatientUser patientuser) {
                return DropdownMenuItem(
                  value: patientuser,
                  child: Text(patientuser.email),
                );
              }).toList(),
              onChanged: _onSearchTextChanged,
              displayClearIcon: false, // Optionally remove the clear icon
              hint: "Select patient to approve",
            ),

            const SizedBox(height: 16),
            CustomButton(
              onTap: _shareRecord,
              label: 'Share Patient Record',
            ),
          ],
        ),
      ),
    );
  }

  List<PatientModel> _filterPatients(String query) {
    return patients.where((patient) {
      final name = patient.name.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
  }

  List<DoctorModel> _filterDoctors(String query) {
    return receivingDoctor.where((doctor) {
      final email = doctor.email.toLowerCase();
      return email.contains(query.toLowerCase());
    }).toList();
  }
}
