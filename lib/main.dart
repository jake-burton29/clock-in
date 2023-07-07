import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/clock_in_out_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/admin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/admin_service.dart';
import 'package:provider/provider.dart'; // import Provider
import '../models/user_data.dart'; // import your UserData model
import '../services/auth_services.dart'; // import AuthService

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  AdminService adminService = AdminService();
  await adminService.initializeAdmin(firestore);
  runApp(ClockInApp());
}

class ClockInApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserData?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        title: 'Clock In App',
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/clock': (context) => ClockInOutScreen(
              user: Provider.of<UserData?>(context)), // provide the user
          '/summary': (context) => SummaryScreen(),
          '/admin': (context) => AdminScreen(),
        },
      ),
    );
  }
}
