import 'package:cloud_firestore/cloud_firestore.dart';

class SharedRecordModel {
  final String patientId;
  final String id;
  final String sharingDoctorId;
  final String receivingDoctorId;
  final String approvalStatus;
  // You can add more fields as needed

  SharedRecordModel({
    required this.patientId,
    required this.id,
    required this.sharingDoctorId,
    required this.receivingDoctorId,
    required this.approvalStatus,
    // Initialize other fields
  });

  static SharedRecordModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return SharedRecordModel(
      id: snap.id, // Set the id from the document ID
      sharingDoctorId: snapshot['sharingDoctorId'],
      patientId: snapshot['patientId'],
      receivingDoctorId: snapshot['receivingDoctorId'],
      approvalStatus: snapshot['approvalStatus'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'sharingDoctorId': sharingDoctorId,
        'receivingDoctorId': receivingDoctorId,
        'approvalStatus': approvalStatus,
        // Add other fields
      };
}
