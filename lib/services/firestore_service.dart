import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference workHoursCollection =
      FirebaseFirestore.instance.collection('work_hours');

  Future<void> clockIn(String userId) async {
    try {
      await workHoursCollection.add({
        'userId': userId,
        'date': DateTime.now().toUtc().toString().substring(0, 10),
        'clockIn': Timestamp.now(),
        'clockOut': null,
      });
    } catch (e) {
      print('Error clocking in: $e');
    }
  }

  Future<void> clockOut(String userId) async {
    try {
      QuerySnapshot snapshot = await workHoursCollection
          .where('userId', isEqualTo: userId)
          .where('clockOut', isNull: true)
          .orderBy('clockIn', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot workEntryDoc = snapshot.docs.first;
        await workHoursCollection.doc(workEntryDoc.id).update({
          'clockOut': Timestamp.now(),
        });
      } else {
        print('No unclosed work entry found for user $userId');
      }
    } catch (e) {
      print('Error clocking out: $e');
    }
  }
}
