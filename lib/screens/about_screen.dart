import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'AttendanceTasks_VimukthiJayasanka_20250720.apk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Developer: Vimukthi Jayasanka'),
              const SizedBox(height: 8),
              Text('Date: 20-07-2025'),
              const SizedBox(height: 24),
              const Text('Employee Attendance & Daily Tasks App'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
