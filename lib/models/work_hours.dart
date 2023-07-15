import 'package:cloud_firestore/cloud_firestore.dart';

class WorkHours {
  String id;
  String userId;
  DateTime clockIn;
  DateTime? clockOut;
  double? totalHours;

  WorkHours({
    required this.id,
    required this.userId,
    required this.clockIn,
    this.clockOut,
    this.totalHours,
  });

  // Convert a WorkHours object into a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'clockIn': clockIn,
      'clockOut': clockOut,
      "totalHours": totalHours
    };
  }

// Create a WorkHours object from a Firestore snapshot
  static WorkHours fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    double? totalHours;
    if (data['totalHours'] != null) {
      totalHours = double.tryParse(data['totalHours'].toString());
      if (totalHours == null) {
        // Log a warning, throw an error, or handle this case however you like.
        print(
            'Warning: Could not parse totalHours from data: ${data['totalHours']}');
      }
    }

    return WorkHours(
      id: snapshot.id,
      userId: data['userId'],
      clockIn: (data['clockIn'] as Timestamp).toDate(),
      clockOut: data['clockOut'] != null
          ? (data['clockOut'] as Timestamp).toDate()
          : null,
      totalHours: totalHours,
    );
  }
}
