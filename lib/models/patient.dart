import 'package:cloud_firestore/cloud_firestore.dart';

class PatientModel {
  static const admin = "admin";
  static const patient = "patient";

  final String name;
  final int age;
  final String id;
  final String doctorId;
  final String testName;
  final String results;
  final String doctorName;
  //final String role;

  PatientModel({
    required this.id,
    required this.age,
    required this.name,
    required this.testName,
    required this.doctorId,
    required this.results,
    required this.doctorName,
    //required this.role,
  });

  static fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PatientModel(
      id: snapshot["id"],
      name: snapshot["name"],
      doctorId: snapshot['doctorId'],
      age: snapshot["age"],
      testName: snapshot["testName"],
      results: snapshot["results"],
      doctorName: snapshot["doctorName"],
      //role: snapshot["role"] ?? patient,
    );
  }

  Map<String, dynamic> toJson() => {
        "username": name,
        "id": id,
        "age": age,
        'doctorId': doctorId,
        "testName": testName,
        "results": results,
        "doctorName": doctorName,
        //"role": role,
      };
}
