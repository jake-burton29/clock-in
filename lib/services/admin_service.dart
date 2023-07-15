import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminService {
  Future<void> initializeAdmin(FirebaseFirestore firestore) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    // Retrieve admin email and password from environment variables
    String? adminEmail = dotenv.env['ADMIN_EMAIL'];
    String? adminPassword = dotenv.env['ADMIN_PASSWORD'];

    if (adminEmail != null && adminPassword != null) {
      // Check if an admin account already exists
      var adminUsers = await firestore
          .collection('roles')
          .where('isAdmin', isEqualTo: true)
          .get();

      if (adminUsers.docs.isEmpty) {
        // No admin account exists, create a new one
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );

        // Add a document to the 'roles' collection to indicate that this user is an admin
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
