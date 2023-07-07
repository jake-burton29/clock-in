import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/work_hours.dart';

class WorkHoursService {
  CollectionReference workHoursRef =
      FirebaseFirestore.instance.collection('work_hours');
  final CollectionReference _workHoursCollection =
      FirebaseFirestore.instance.collection('work_hours');

  Future<void> clockIn(String uid) async {
    try {
      await _workHoursCollection.add({
        'clockIn': Timestamp.now(),
        'clockOut': null,
        'userId': uid,
      });
    } catch (e) {
      print('Error clocking in: $e');
    }
  }

  Future<void> clockOut(String docId) async {
    return workHoursRef.doc(docId).update({
      'clockOut': DateTime.now(),
    });
  }

  Stream<WorkHours?> getCurrentWorkHours(String userId) {
    return workHoursRef
        .where('userId', isEqualTo: userId)
        .where('clockOut', isNull: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty
            ? WorkHours.fromSnapshot(snapshot.docs.first)
            : null);
  }
}
