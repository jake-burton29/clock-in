import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_data.dart';
import '../models/work_hours.dart';
import '../services/auth_services.dart';
import '../services/work_hours_service.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final WorkHoursService _workHoursService = WorkHoursService();
  final AuthService _authService = AuthService();
  DateTimeRange? dateRange;
  List<WorkHours>? employeeHours;
  UserData? selectedUser;
  List<UserData>? userList;
  double? totalHoursInPayPeriod;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initUserList();
  }

  Future<void> initUserList() async {
    userList = await _authService.getUserList();
    if (userList != null && userList!.isNotEmpty) {
      print('User List: $userList'); // Print user list to console
      setState(() {
        selectedUser = userList![0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (userList != null)
                DropdownButton<UserData>(
                  value: selectedUser,
                  items: userList!
                      .map((user) => DropdownMenuItem<UserData>(
                            child: Text(user.email),
                            value: user,
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedUser = value;
                      employeeHours = null;
                    });
                  },
                ),
              ElevatedButton(
                child: Text("Select Date Range"),
                onPressed: selectedUser == null
                    ? null
                    : () async {
                        dateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 5),
                          lastDate: DateTime(DateTime.now().year + 5),
                        );

                        if (dateRange != null) {
                          employeeHours = await _workHoursService
                              .getWorkHoursInRangeForEmployee(selectedUser!.uid,
                                  dateRange!.start, dateRange!.end);
                          totalHoursInPayPeriod = employeeHours
                              ?.map((workHours) => workHours.totalHours ?? 0)
                              .fold(
                                  0,
                                  (previous, current) =>
                                      (previous ?? 0) + (current));

                          setState(() {});
                        }
                      },
              ),
              if (employeeHours != null)
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text(
                          'Date',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Hours',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: employeeHours!
                        .map(
                          (workHours) => DataRow(
                            cells: <DataCell>[
                              DataCell(Text(workHours.clockOut != null
                                  ? DateFormat('MM-dd-yyyy – hh:mm a')
                                      .format(workHours.clockOut!)
                                  : 'Not clocked out yet')),
                              DataCell(Text((workHours.totalHours ?? 0)
                                  .toStringAsFixed(2))),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (employeeHours != null)
                Text(
                  'Total Hours: ${(employeeHours?.map((workHours) => workHours.totalHours ?? 0.0).fold(0.0, (double previous, double current) => previous + current))?.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                ),
              Container(
                width:
                    screenWidth * 0.4, // Fields take up about 40% screen width
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                mainAxisSize: MainAxisSize.min, // arrange buttons in a row
                children: [
                  ElevatedButton(
                    child: Text('Create New User'),
                    onPressed: () async {
                      String email = emailController.text;
                      String password = passwordController.text;
                      UserCredential newUser =
                          await _authService.createUser(email, password);

                      if (newUser.user != null) {
                        print('User created successfully');
                        initUserList();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('User created successfully')));
                      } else {
                        print('Error creating user');
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Error creating user')));
                      }
                    },
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    child: Text('Deactivate User'),
                    onPressed: () async {
                      String email = emailController.text;

                      bool success = await _authService.deactivateUser(email);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                                'User\'s deactivated successfully')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Error deactivating user')));
                      }
                    },
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    child: Text('Reactivate User'),
                    onPressed: () async {
                      String email = emailController.text;

                      bool success = await _authService.reactivateUser(email);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text(
                                'User\'s reactivated successfully')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: const Text('Error reactivating user')));
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
