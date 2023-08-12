import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:records_application/models/patient_user.dart';
import 'package:records_application/models/patient_user.dart' as model;
import '../constants/global_variables.dart';

import '../screens/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get User details
  Future<PatientUser> getPatientUserDetails() async {
    User? currentPatientUser = _auth.currentUser;

    if (currentPatientUser != null) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection("patient")
          .doc(currentPatientUser.uid)
          .get();

      if (documentSnapshot.exists) {
        return PatientUser.fromSnap(documentSnapshot);
      } else {
        throw Exception("Patient document doesn't exist");
      }
    } else {
      throw Exception("No logged-in patient");
    }
  }

  Future<String> signUpPatientUser({
    required String name,
    required String email,
    required String password,
    required Uint8List file,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        UserCredential credentials = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        String photoUrl = await StorageMethods()
            .uploadImageToStorage('profilePics', file, false);

        model.PatientUser doctor = model.PatientUser(
          email: email,
          patientId: credentials.user!.uid,
          photoUrl: photoUrl,
          username: name,
        );

        //storing user to database
        await _firestore
            .collection("patient")
            .doc(doctor.patientId)
            .set(doctor.toJson());

        res = "success";
        //await sendEmailVerification()
        Fluttertoast.showToast(
          msg: "Account created Successfully",
          gravity: ToastGravity.CENTER,
          backgroundColor: GlobalVariables.primaryColor,
        );
      } else {
        res = "Please Enter all fields";
      }
    } on FirebaseException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.message}",
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[800],
      );
    }
    return res;
  }

  // logging in user
  Future<String> loginPatientUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error Occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(
        msg: "${e.message}",
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red[800],
      );
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
