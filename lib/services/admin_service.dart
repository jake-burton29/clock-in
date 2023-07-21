import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminService {
  Future<void> initializeAdmin(FirebaseFirestore firestore) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    String? adminEmail = dotenv.env['ADMIN_EMAIL'];
    String? adminPassword = dotenv.env['ADMIN_PASSWORD'];

    if (adminEmail != null && adminPassword != null) {
      var adminUsers = await firestore
          .collection('roles')
          .where('isAdmin', isEqualTo: true)
          .get();

      if (adminUsers.docs.isEmpty) {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );

        await firestore.collection('roles').doc(userCredential.user!.uid).set({
          'isAdmin': true,
          'isActive': true,
          'email': userCredential.user?.email,
        });
      }
    } else {
      print(
          'ADMIN_EMAIL and/or ADMIN_PASSWORD not found in environment variables');
    }
  }
}
