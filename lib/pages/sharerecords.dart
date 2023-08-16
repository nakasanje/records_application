import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:records_application/constants/space.dart';

import '../constants/custom_button.dart';

import '../models/doctors.dart';
import '../models/doctors.dart' as model;
import '../models/patient.dart';
import '../models/patient_user.dart';
import '../models/share.dart';
import 'package:http/http.dart' as http;
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
          await FirebaseFirestore.instance.collection('patient').get();

      final patientuser = snapshot.docs.map<PatientUser>((doc) {
        return PatientUser(
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

  Future<void> sendMessage(String token, String title, String body) async {
    final message = {
      'notification': {
        'title': title,
        'body': body,
      },
      'to': token,
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer your_server_key_here',
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print('Message sent successfully');
    } else {
      print('Failed to send message: ${response.body}');
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
    const approvalStatus = 'pending';

    final sharedRecord = SharedRecordModel(
      patientId: selectedPatient!.id,
      sharingDoctorId: sharingDoctorId,
      receivingDoctorId: selectedReceivingDoctor!.doctorId,
      approvalStatus: approvalStatus,
      id: selectedpatientsToApprove!.patientId,
    );

    try {
      await FirebaseFirestore.instance
          .collection('SharedRecords')
          .add(sharedRecord.toJson());

      // Get the patient's FCM token from your data
      String patientToken = ''; // Replace with actual token

      await sendMessage(
        patientToken,
        'Record Shared',
        'Your doctor has shared your records.',
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Patient Records')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<PatientModel>(
              value: selectedPatient,
              onChanged: (patient) {
                setState(() {
                  selectedPatient = patient;
                });
              },
              items: patients.map<DropdownMenuItem<PatientModel>>(
                (PatientModel patient) {
                  return DropdownMenuItem<PatientModel>(
                    value: patient,
                    child: Text(patient.name),
                  );
                },
              ).toList(),
              hint: const Text('Select patient records '),
            ),

            const Space(),

            DropdownButton<DoctorModel>(
              value: selectedReceivingDoctor,
              onChanged: (doctor) {
                setState(() {
                  selectedReceivingDoctor = doctor;
                });
              },
              items: receivingDoctor.map<DropdownMenuItem<DoctorModel>>(
                (DoctorModel doctor) {
                  return DropdownMenuItem<DoctorModel>(
                    value: doctor,
                    child: Text(doctor.email),
                  );
                },
              ).toList(),
              hint: const Text('Select receiving doctor'),
            ),

            const Space(),

            DropdownButton<PatientUser>(
              value: selectedpatientsToApprove,
              onChanged: (patientuser) {
                setState(() {
                  selectedpatientsToApprove = patientuser;
                });
              },
              items: patientsToApprove.map<DropdownMenuItem<PatientUser>>(
                (PatientUser patientuser) {
                  return DropdownMenuItem<PatientUser>(
                    value: patientuser,
                    child: Text(patientuser.email),
                  );
                },
              ).toList(),
              hint: const Text('Select patient to approve'),
            ),

            //

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
}
