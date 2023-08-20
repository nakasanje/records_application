import 'package:flutter/material.dart';
import '../Services/doctor_auth.dart';
import '../models/doctors.dart';

class DoctorProvider with ChangeNotifier {
  DoctorModel _doctor = DoctorModel(
    email: "",
    doctorId: "",
    username: "",
    photoUrl: "",
    role: "",
  );
  final AuthMethod _authMethod = AuthMethod();

  DoctorModel get getDoctor => _doctor;

  Future<void> refreshDoctor() async {
    DoctorModel doctor = await _authMethod.getDoctorDetails();
    _doctor = doctor;

    notifyListeners();
  }
}
