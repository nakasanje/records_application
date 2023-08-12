import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  static const admin = "admin";
  static const doctor = "doctor";

  final String username;
  final String uid;
  final String email;
  final String photoUrl;
  final String role;

  UserModel({
    required this.email,
    required this.uid,
    required this.photoUrl,
    required this.username,
    required this.role,
  });

  static fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      email: snapshot["email"],
      uid: snapshot["uid"],
      photoUrl: snapshot["photoUrl"],
      username: snapshot["username"],
      role: snapshot["role"] ?? doctor,
    );
  }

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "role": role,
      };
}
