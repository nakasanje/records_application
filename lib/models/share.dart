import 'package:cloud_firestore/cloud_firestore.dart';

class SharedRecordModel {
  final String patientId;
  final String id;
  final String sharingDoctorId;
  final String receivingDoctorId;
  final String receivingDoctorName;
  final String sharingDoctorName;
  final String approvalStatus;
  // You can add more fields as needed

  SharedRecordModel({
    required this.patientId,
    required this.sharingDoctorName,
    required this.id,
    required this.sharingDoctorId,
    required this.receivingDoctorId,
    required this.receivingDoctorName,
    required this.approvalStatus,
    // Initialize other fields
  });

  static SharedRecordModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return SharedRecordModel(
      sharingDoctorName: snapshot['sharingDoctorName'],
      id: snap.id, // Set the id from the document ID
      sharingDoctorId: snapshot['sharingDoctorId'],
      patientId: snapshot['patientId'],
      receivingDoctorId: snapshot['receivingDoctorId'],
      receivingDoctorName: snapshot['receivingDoctorName'],
      approvalStatus: snapshot['approvalStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sharingDoctorName': sharingDoctorName,
        'patientId': patientId,
        'sharingDoctorId': sharingDoctorId,
        'receivingDoctorId': receivingDoctorId,
        'receivingDoctorName': receivingDoctorName,
        'approvalStatus': approvalStatus,
        // Add other fields
      };
}
