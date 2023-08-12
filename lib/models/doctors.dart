import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String username;
  final String email;
  final String photoUrl;
  final String doctorId;

  DoctorModel({
    required this.email,
    required this.doctorId,
    required this.photoUrl,
    required this.username,
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
      );
    }

    return DoctorModel(
      email: data["email"] ?? "",
      doctorId: data["doctorId"] ?? "",
      username: data["username"] ?? "",
      photoUrl: data["photoUrl"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "doctorId": doctorId,
        "email": email,
        'photoUrl': photoUrl,
      };
}
