import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/custom_button.dart';
import '../methods/firestore.dart';
import '../models/patient.dart';
import '../models/patient_user.dart';
import '../providers/doctor_provider.dart';
import '../providers/patient_user_provider.dart';

class AddPatientPage extends StatefulWidget {
  const AddPatientPage({Key? key}) : super(key: key);

  @override
  State<AddPatientPage> createState() => _AddPatientPageState();
}

class _AddPatientPageState extends State<AddPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreMethods firestore = FirestoreMethods();
  List<PatientUser> patientsToApprove = [];
  late String _doctorId; // Make _id non-nullable
  String _name = '';
  int _age = 0;
  String _testName = '';
  String _results = '';
  String _doctorName = '';
  late String _id;

  @override
  void initState() {
    super.initState();
    fetchPatientsToApprove();
    _doctorId =
        Provider.of<DoctorProvider>(context, listen: false).getDoctor.doctorId;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      PatientModel patient = PatientModel(
        id: _id,
        name: _name,
        age: _age,
        testName: _testName,
        results: _results,
        doctorName: _doctorName,
        doctorId: _doctorId,
      );

      await firestore.addPatient(patient);

      _formKey.currentState!.reset();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient added successfully')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Patient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _name = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an age';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid age';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _age = int.tryParse(value) ?? 0;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Test Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter test names';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _testName = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Results'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter results';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _results = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Doctor Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter doctor's name";
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _doctorName = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              CustomButton(
                onTap: _submitForm,
                label: 'Add Patient',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
