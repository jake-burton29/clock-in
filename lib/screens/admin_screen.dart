import 'package:flutter/material.dart';

class AdminScreen extends StatelessWidget {
  final List<Map<String, dynamic>> employeeHours = [
    {'name': 'Employee 1', 'hours': '8'},
    {'name': 'Employee 2', 'hours': '7.5'},
    // Add more employees here
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
      ),
      body: ListView.builder(
        itemCount: employeeHours.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(employeeHours[index]['name']),
            subtitle: Text(employeeHours[index]['hours']),
          );
        },
      ),
    );
  }
}
