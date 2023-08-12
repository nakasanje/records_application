//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:records_application/models/patient.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/doctors.dart';
import '../models/patient_user.dart';
import '../models/user.dart';

class FirestoreMethods {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String uid = FirebaseAuth.instance.currentUser != null
      ? FirebaseAuth.instance.currentUser!.uid
      : '';

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference doctorCollection =
      FirebaseFirestore.instance.collection('doctor');
  final CollectionReference patientCollection =
      FirebaseFirestore.instance.collection('patients');
  final CollectionReference patientuserCollection =
      FirebaseFirestore.instance.collection('patientuser');
  final CollectionReference sharedrecordsCollection =
      FirebaseFirestore.instance.collection('SharedRecords');

  // final CollectionReference abcCollection =
  //     FirebaseFirestore.instance.collection('abc');

  final String doctor = 'doctor';
  final String patient = 'patient';
  final String user = 'users';
  final String patientuser = 'patientuser';

  createUser({required UserModel model}) async {
    await userCollection.doc(model.uid).set(model.toJson());
  }

  updateUser({required Map<String, dynamic> data, required String id}) async {
    await userCollection.doc(id).update(data);
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return await userCollection.doc(id).get();
  }

  deleteUser(String id) async {
    await userCollection.doc(id).delete();
  }

  createPatientUser({required PatientUser model}) async {
    await patientuserCollection.doc(model.patientId).set(model.toJson());
  }

  updatePatientUser(
      {required Map<String, dynamic> data, required String patientId}) async {
    await patientuserCollection.doc(patientId).update(data);
  }

  Future<DocumentSnapshot> getPatientUser(String patientId) async {
    return await patientuserCollection.doc(patient).get();
  }

  deletePatientUser(String patientId) async {
    await patientuserCollection.doc(patientId).delete();
  }

  void createDoctorDocument(String doctorId, DoctorModel doctor) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctor.doctorId)
          .set(doctor.toJson());
      // ignore: avoid_print
      print('Doctor document created successfully');
    } catch (e) {
      // ignore: avoid_print
      print('Error creating doctor document: $e');
    }
  }

  createDoctor({required DoctorModel model}) async {
    await doctorCollection.doc(model.doctorId).set(model.toJson());
  }

  updateDoctor(
      {required Map<String, dynamic> data, required String doctorId}) async {
    await doctorCollection.doc(doctorId).update(data);
  }

  Future<DocumentSnapshot> getDoctor(String doctorId) async {
    return await doctorCollection.doc(doctor).get();
  }

  deleteDoctor(String id) async {
    await doctorCollection.doc(id).delete();
  }

  createPatient({required PatientModel model}) async {
    await patientCollection.doc(model.id).set(model.toJson());
  }

  updatePatient(
      {required Map<String, dynamic> data, required String id}) async {
    await patientCollection.doc(id).update(data);
  }

  Future<void> addPatient(PatientModel patient) async {
    await patientCollection.add({
      'name': patient.name,
      'id': patient.id,
      'testName': patient.testName,
      'age': patient.age,
      'doctorName': patient.doctorName,
      'results': patient.results,
    });
  }

  Future<DocumentSnapshot> getPatient(String id) async {
    return await patientCollection.doc(id).get();
  }

  deletePatient(String id) async {
    await patientCollection.doc(id).delete();
  }
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> sendNotification(
      {required String title,
      required String body,
      required String token}) async {
    await _firebaseMessaging.sendMessage(
      to: token,
      data: {
        title: 'title',
        body: 'body',
        token: 'token',
      },
    );
  }
}
