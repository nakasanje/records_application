import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:typed_data';
import '../constants/global_variables.dart';
import '../models/doctors.dart' as model;
import '../models/doctors.dart';
import '../screens/storage_methods.dart';

class AuthMethod {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //get User details
  Future<DoctorModel> getDoctorDetails() async {
    User? currentDoctor = _auth.currentUser;

    if (currentDoctor != null) {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection("doctor").doc(currentDoctor.uid).get();

      if (documentSnapshot.exists) {
        return DoctorModel.fromSnap(documentSnapshot);
      } else {
        throw Exception("Doctor document doesn't exist");
      }
    } else {
      throw Exception("No logged-in doctor");
    }
  }

  Future<String> signUpDoctor({
    required String name,
    required String email,
    required String password,
    required Uint8List file,
    required String role,
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

        model.DoctorModel doctor = model.DoctorModel(
          email: email,
          doctorId: credentials.user!.uid,
          photoUrl: photoUrl,
          username: name,
          role: "doctor",
        );

        //storing user to database
        await _firestore
            .collection("doctor")
            .doc(doctor.doctorId)
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
  Future<String> loginDoctor({
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
