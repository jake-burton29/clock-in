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

  Future<UserCredential> createUser(String email, String password) async {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('roles').doc(userCredential.user!.uid).set({
      'email': email,
      'isAdmin': false,
      'isActive': true,
    });
    return userCredential;
  }

  Future<bool> deactivateUser(String email) async {
    try {
      await _db.collection('roles').doc(email).update({'isActive': false});
      return true; // Return true if the update operation is successful
    } catch (error) {
      print('Error deactivating user: $error');
      return false; // Return false if there's an error during the update operation
    }
  }

  Future<bool> reactivateUser(String email) async {
    try {
      await _db.collection('roles').doc(email).update({'isActive': true});
      return true; // Return true if the update operation is successful
    } catch (error) {
      print('Error deactivating user: $error');
      return false; // Return false if there's an error during the update operation
    }
  }

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

        if (userData['email'] is! String || userData['email'] != email) {
          throw Exception('Email mismatch');
        }
        if (userData['isAdmin'] is! bool) {
          throw Exception('isAdmin should be a boolean');
        }

        if (userData['isActive'] is! bool) {
          throw Exception('isActive should be a boolean');
        }

        if (!userData['isActive']) {
          throw Exception('User is not active');
        }

        bool isAdmin = userData['isAdmin'] ?? false;
        String userEmail = userData['email'] ?? '';
        bool isActive = userData['isActive'] ?? true;

        // Create a UserData object with the necessary fields
        UserData user = UserData(
          uid: uid,
          email: userEmail,
          isAdmin: isAdmin,
          isActive: isActive, // Add this
          // Add any other necessary fields from the userDoc
        );

        return user;
      } else {
        throw Exception('User document does not exist');
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
        return await getUserData(user.uid, user.email!);
      }
    });
  }

  Future<List<UserData>> getUserList() async {
    final userCollection = FirebaseFirestore.instance
        .collection('roles'); // use the correct collection name
    final snapshot = await userCollection.get();

    return snapshot.docs.map((doc) {
      return UserData.fromMap(doc.data(), doc.id);
    }).toList();
  }
}
