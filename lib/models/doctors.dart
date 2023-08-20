import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  static const admin = "admin";
  static const doctor = "doctor";

  final String username;
  final String email;
  final String photoUrl;
  final String doctorId;
  final String role;

  DoctorModel({
    required this.email,
    required this.doctorId,
    required this.photoUrl,
    required this.username,
    required this.role,
  });

  factory DoctorModel.fromSnap(DocumentSnapshot snap) {
    Map<String, dynamic>? data = snap.data() as Map<String, dynamic>?;

    if (data == null) {
      // If data is null, return a default DoctorModel
      return DoctorModel(
        email: "",
        doctorId: "",
        username: "",
        photoUrl: "",
        role: "",
      );
    }

    return DoctorModel(
      email: data["email"] ?? "",
      doctorId: data["doctorId"] ?? "",
      username: data["username"] ?? "",
      photoUrl: data["photoUrl"] ?? "",
      role: data["role"] ?? doctor,
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "doctorId": doctorId,
        "email": email,
        'photoUrl': photoUrl,
        "role": role,
      };
}
