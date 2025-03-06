import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_data.dart';
import '../models/work_hours.dart';
import '../services/auth_services.dart';

class EditScreen extends StatefulWidget {
  final UserData selectedUser;
  final List<WorkHours>? employeeHours;
  final Function()? onEdit; // Add a callback to notify the parent widget

  EditScreen({
    required this.selectedUser,
    required this.employeeHours,
    this.onEdit, // Initialize the callback
  });

  @override
  _EditScreenState createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  DateTime? newClockIn; // Track selected clock-in time
  DateTime? newClockOut; // Track selected clock-out time

  @override
  void initState() {
    super.initState();
    newClockIn = DateTime.now(); // Initialize with the current time
    newClockOut = DateTime.now(); // Initialize with the current time
  }

  Future<void> _showEditModal(
    BuildContext context,
    WorkHours workHours,
  ) async {
    newClockIn = workHours.clockIn;
    newClockOut = workHours.clockOut ?? DateTime.now();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Clock-In and Clock-Out Times'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Clock-In Time'),
                subtitle: Text(DateFormat('hh:mm a').format(newClockIn!)),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(newClockIn!),
                  );
                  if (pickedTime != null) {
                    setState(() {
                      newClockIn = DateTime(
                        newClockIn!.year,
                        newClockIn!.month,
                        newClockIn!.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                  Text("${pickedTime?.hour}: ${pickedTime?.minute}");
                },
              ),
              ListTile(
                title: Text('Clock-Out Time'),
                subtitle: Text(DateFormat('hh:mm a').format(newClockOut!)),
                onTap: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(newClockOut!),
                  );
                  Text("${pickedTime?.hour}: ${pickedTime?.minute}");
                  if (pickedTime != null) {
                    setState(() {
                      newClockOut = DateTime(
                        newClockOut!.year,
                        newClockOut!.month,
                        newClockOut!.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                    });
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm Changes'),
              onPressed: () async {
                // Call the AuthService method to update times
                try {
                  await AuthService().updateClockInOutTimes(
                    workHours,
                    newClockIn!,
                    newClockOut!,
                  );
                  Navigator.of(context).pop(); // Close the modal
                  // Replace the current EditScreen with a new instance
                  // Navigator.of(context).pushReplacement(MaterialPageRoute(
                  //   builder: (context) => EditScreen(
                  //     selectedUser: widget.selectedUser,
                  //     employeeHours: widget.employeeHours,
                  //     onEdit: widget.onEdit, // Pass the callback
                  //   ),
                  // ));
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error updating times: $e');
                  // Handle the error as needed
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    UserData selectedUser = widget.selectedUser;
    List<WorkHours>? employeeHours = widget.employeeHours;

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Screen'),
      ),
      body: Column(
        children: [
          Text(
            "${selectedUser.email}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: employeeHours?.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                final workHours = employeeHours![index];

                return ListTile(
                  title: Text(DateFormat('MM-dd-yyyy – hh:mm a')
                      .format(workHours.clockIn)),
                  subtitle: workHours.clockOut != null
                      ? Text(DateFormat('MM-dd-yyyy – hh:mm a')
                          .format(workHours.clockOut!))
                      : Text('Not clocked out yet'),
                  onTap: () {
                    _showEditModal(
                      context,
                      workHours,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
