import 'package:cloud_firestore/cloud_firestore.dart';

class WorkHours {
  String id;
  String userId;
  DateTime clockIn;
  DateTime? clockOut;

  WorkHours({
    required this.id,
    required this.userId,
    required this.clockIn,
    this.clockOut,
  });

  // Convert a WorkHours object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clockIn': clockIn,
      'clockOut': clockOut,
    };
  }

  // Create a WorkHours object from a Firestore snapshot
  static WorkHours fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return WorkHours(
      id: snapshot.id,
      userId: data['userId'],
      clockIn: data['clockIn'].toDate(),
      clockOut: data['clockOut']?.toDate(),
    );
  }
}
