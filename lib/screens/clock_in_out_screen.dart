import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/work_hours.dart';
import '../services/work_hours_service.dart';
import '../services/auth_services.dart';

class ClockInOutScreen extends StatefulWidget {
  final UserData? user; // change User to UserData

  ClockInOutScreen({this.user}); // remove required from this.user

  @override
  _ClockInOutScreenState createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  final WorkHoursService _workHoursService = WorkHoursService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<void> _clockIn() async {
    await _workHoursService.clockIn(widget.user!.uid);
  }

  Future<void> _clockOut(String docId) async {
    await _workHoursService.clockOut(docId);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clock In/Out Screen'),
      ),
      body: StreamBuilder<WorkHours?>(
        stream: _workHoursService.getCurrentWorkHours(widget.user!.uid),
        builder: (BuildContext context, AsyncSnapshot<WorkHours?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            WorkHours? currentWorkHours = snapshot.data;
            bool isClockedIn = currentWorkHours != null;
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Logged in User: ${widget.user?.email}',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 20),
                  if (widget.user!.isAdmin)
                    ElevatedButton(
                      child: Text('Admin'),
                      onPressed: () {
                        // Navigate to Admin page
                        Navigator.pushNamed(context, '/admin');
                      },
                    )
                  else if (isClockedIn)
                    ElevatedButton(
                      child: Text('Clock Out'),
                      onPressed: () => _clockOut(currentWorkHours.id),
                    )
                  else
                    ElevatedButton(
                      child: Text('Clock In'),
                      onPressed: _clockIn,
                    ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Sign Out'),
                    onPressed: () => _signOut(context),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
