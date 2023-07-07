// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDGP5vFaSD9ZBHE2MGKjjPviF2JJ9e7Bzo',
    appId: '1:639097874521:web:7270ba16b42485d4e42948',
    messagingSenderId: '639097874521',
    projectId: 'clockin-9dbe0',
    authDomain: 'clockin-9dbe0.firebaseapp.com',
    storageBucket: 'clockin-9dbe0.appspot.com',
    measurementId: 'G-YEP86X5X8L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDj07npZpW6woX4IWzbx-pZMMMEtOTlPhE',
    appId: '1:639097874521:android:7177e6aca8eb1767e42948',
    messagingSenderId: '639097874521',
    projectId: 'clockin-9dbe0',
    storageBucket: 'clockin-9dbe0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA_YXQ2mkkljzfrToNe3rukoNaLoQUc6-g',
    appId: '1:639097874521:ios:0d8c55469e10de57e42948',
    messagingSenderId: '639097874521',
    projectId: 'clockin-9dbe0',
    storageBucket: 'clockin-9dbe0.appspot.com',
    iosClientId: '639097874521-odpa13r165r2mvcgto9raatv8vsctuqe.apps.googleusercontent.com',
    iosBundleId: 'com.example.clockIn',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA_YXQ2mkkljzfrToNe3rukoNaLoQUc6-g',
    appId: '1:639097874521:ios:1e79079238776f25e42948',
    messagingSenderId: '639097874521',
    projectId: 'clockin-9dbe0',
    storageBucket: 'clockin-9dbe0.appspot.com',
    iosClientId: '639097874521-6in4gggd2brp0f43dunneh21tcl03bfo.apps.googleusercontent.com',
    iosBundleId: 'com.example.clockIn.RunnerTests',
  );
}
