import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/login_screen.dart';
import 'screens/clock_in_out_screen.dart';
import 'screens/summary_screen.dart';
import 'screens/edit_screen.dart';
import 'screens/admin_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/admin_service.dart';
import 'package:provider/provider.dart';
import '../models/user_data.dart';
import '../services/auth_services.dart';

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
        theme: ThemeData(
          // Light theme
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.light(
            primary: Colors.blue[800]!,
            secondary: Colors.amber,
            error: Colors.red,
            onPrimary: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.dark(
            primary: Colors.blue[700]!,
            secondary: Colors.amber,
            error: Colors.red,
            onPrimary: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.grey[900],
          fontFamily: 'Roboto',
          textTheme: TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.normal),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Roboto'),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginScreen(),
          '/clock': (context) =>
              ClockInOutScreen(user: Provider.of<UserData?>(context)),
          '/summary': (context) => SummaryScreen(),
          '/admin': (context) => AdminScreen(),
        },
      ),
    );
  }
}
