import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/work_hours.dart';
import 'package:intl/intl.dart';

class WorkHoursService {
  CollectionReference workHoursRef =
      FirebaseFirestore.instance.collection('work_hours');
  final CollectionReference _workHoursCollection =
      FirebaseFirestore.instance.collection('work_hours');

  Future<void> clockIn(String userId) async {
    try {
      await _workHoursCollection.add({
        'userId': userId,
        'date': DateTime.now().toUtc().toString().substring(0, 10),
        'clockIn': Timestamp.now(),
        'clockOut': null,
        'totalHours': null,
      });
    } catch (e) {
      print('Error clocking in: $e');
    }
  }

  Future<Object> clockOut(String docId) async {
    Timestamp clockOut = Timestamp.now();

    DocumentSnapshot doc = await workHoursRef.doc(docId).get();
    Timestamp clockIn = doc.get('clockIn');

    double totalHours =
        clockOut.toDate().difference(clockIn.toDate()).inMinutes / 60;

    String formattedClockOut =
        DateFormat('yyyy-MM-dd hh:mm:ss a').format(clockOut.toDate());
    workHoursRef.doc(docId).update({
      'clockOut': clockOut,
      'totalHours': totalHours.toStringAsFixed(2),
    });
    return {
      "clockOut": formattedClockOut,
      "totalHours": totalHours,
    };
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

  Future<List<WorkHours>> getWorkHoursInRangeForEmployee(
      String userId, DateTime start, DateTime end) async {
    QuerySnapshot snapshot = await workHoursRef
        .where('userId', isEqualTo: userId)
        .where('date',
            isGreaterThanOrEqualTo: start.toUtc().toString().substring(0, 10))
        .where('date',
            isLessThanOrEqualTo: end.toUtc().toString().substring(0, 10))
        .get();

    return snapshot.docs.map((doc) => WorkHours.fromSnapshot(doc)).toList();
  }
}
