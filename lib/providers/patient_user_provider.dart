import 'package:flutter/material.dart';
import 'package:records_application/Services/patient_auth.dart';

import '../models/patient_user.dart';

class PatientUserProvider with ChangeNotifier {
  PatientUser _patientuser = PatientUser(
    email: "",
    patientId: "",
    username: "",
    photoUrl: "",
  );
  final AuthMethods _authMethods = AuthMethods();

  PatientUser get getPatientUser => _patientuser;

  Future<void> refreshPatientUser() async {
    PatientUser patientuser = await _authMethods.getPatientUserDetails();
    _patientuser = patientuser;

    notifyListeners();
  }
}
