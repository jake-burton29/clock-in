import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Singleton instance
  static final AuthService _singleton = AuthService._internal();

  // Factory constructor that returns the singleton instance
  factory AuthService() {
    return _singleton;
  }

  // Internal constructor
  AuthService._internal();

  Future<UserCredential?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  Future<UserData?> getUserData(String uid, String email) async {
    try {
      DocumentSnapshot userDoc = await _db.collection('roles').doc(uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        bool isAdmin = userData['isAdmin'] ?? false;
        String userEmail = userData['email'] ?? '';

        // Check if the email in the document matches the passed email
        if (userEmail != email) {
          throw Exception('Email mismatch');
        }

        // Create a UserData object with the necessary fields
        UserData user = UserData(
          uid: uid,
          email: userEmail,
          isAdmin: isAdmin,
          // Add any other necessary fields from the userDoc
        );

        return user;
      } else {
        // User document does not exist
        return null;
      }
    } catch (e) {
      print(e);
      return null;
    }
  }

  Stream<UserData?> get user {
    return _auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) {
        return null;
      } else {
        return await getUserData(user.uid, user.email!); // Add the '!' operator
      }
    });
  }
}
