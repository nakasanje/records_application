import 'package:cloud_firestore/cloud_firestore.dart';

class PatientUser {
  static const admin = "admin";
  static const patient = "patient";

  final String username;
  final String patientId;
  final String email;
  final String photoUrl;

  PatientUser({
    required this.email,
    required this.patientId,
    required this.photoUrl,
    required this.username,
  });

  factory PatientUser.fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?;

    if (data == null) {
      // If data is null, return a default DoctorModel
      return PatientUser(
        email: "",
        patientId: "",
        username: "",
        photoUrl: "",
      );
    }

    return PatientUser(
      email: data["email"] ?? "",
      patientId: data["patientId"] ?? "",
      username: data["username"] ?? "",
      photoUrl: data["photoUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": patientId,
        "email": email,
        "photoUrl": photoUrl,
      };
}
