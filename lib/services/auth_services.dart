import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_data.dart';
import '../models/work_hours.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final AuthService _singleton = AuthService._internal();

  factory AuthService() {
    return _singleton;
  }

  AuthService._internal();
  Future<UserCredential> createUser(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _db.collection('roles').doc(userCredential.user!.uid).set({
        'email': email,
        'isAdmin': false,
        'isActive': true,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
            'The email address is already in use by another account.');
      } else {
        throw Exception(
            'An error occurred while creating the account: ${e.code}');
      }
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<bool> deactivateUser(String email) async {
    try {
      await _db.collection('roles').doc(email).update({'isActive': false});
      return true;
    } catch (error) {
      print('Error deactivating user: $error');
      return false;
    }
  }

  Future<bool> reactivateUser(String email) async {
    try {
      await _db.collection('roles').doc(email).update({'isActive': true});
      return true;
    } catch (error) {
      print('Error deactivating user: $error');
      return false;
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
      if (e.code == 'user-not-found') {
        throw Exception('No user found for this email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided for this user.');
      }
      throw Exception(e.message ?? 'An unknown error occurred.');
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

        UserData user = UserData(
          uid: uid,
          email: userEmail,
          isAdmin: isAdmin,
          isActive: isActive,
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
    final userCollection = FirebaseFirestore.instance.collection('roles');
    final snapshot = await userCollection.get();

    return snapshot.docs.map((doc) {
      return UserData.fromMap(doc.data(), doc.id);
    }).toList();
  }

  Future<void> updateClockInOutTimes(
    WorkHours workHours,
    DateTime clockIn,
    DateTime clockOut,
  ) async {
    double totalHours = clockOut.difference(clockIn).inMinutes / 60;
    try {
      await _db.collection('work_hours').doc(workHours.id).update({
        'clockIn': clockIn,
        'clockOut': clockOut,
        'totalHours': totalHours.toStringAsFixed(2),
      });
    } catch (error) {
      print('Error updating clock-in and clock-out times: $error');
      throw Exception('An error occurred while updating times.');
    }
  }
}
