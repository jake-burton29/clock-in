import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_data.dart';
import '../models/work_hours.dart';
import '../services/work_hours_service.dart';
import 'package:intl/intl.dart';

class ClockInOutScreen extends StatefulWidget {
  final UserData? user; // change User to UserData

  ClockInOutScreen({required this.user});

  @override
  _ClockInOutScreenState createState() => _ClockInOutScreenState();
}

class _ClockInOutScreenState extends State<ClockInOutScreen> {
  final WorkHoursService _workHoursService = WorkHoursService();

  @override
  void initState() {
    super.initState();
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clockIn() async {
    await _workHoursService.clockIn(widget.user!.uid);

    String formattedClockOut =
        DateFormat('yyyy-MM-dd hh:mm:ss a').format(DateTime.now());
    _showDialog("Clocked In", "You have clocked in at $formattedClockOut");
  }

  Future<void> _clockOut(String docId) async {
    final hours = await _workHoursService.clockOut(docId);
    _showDialog(
      "Clocked Out",
      "You have clocked out. Total hours worked today: $hours",
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Clock In/Out Screen'),
        automaticallyImplyLeading: false,
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
