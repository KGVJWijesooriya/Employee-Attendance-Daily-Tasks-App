import 'package:flutter/material.dart';
import 'screens/attendance_screen.dart';
import 'screens/tasks_screen.dart';
// ...existing code...
import 'utils/error_simulation.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Attendance & Tasks',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  String? _errorMessage;

  static final List<Widget> _screens = <Widget>[
    AttendanceScreen(),
    TasksScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _errorMessage = null;
    });
  }

  void _simulateError() async {
    print('Error simulation triggered');
    try {
      ErrorSimulation.triggerError();
      // If no error is thrown, still show a message
      setState(() {
        _errorMessage = 'Error simulation completed.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save, please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _simulateError,
          child: const Text('Employee Attendance & Tasks'),
        ),
      ),
      body: Stack(
        children: [
          _screens[_selectedIndex],
          if (_errorMessage != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MaterialBanner(
                content: Text(_errorMessage!),
                backgroundColor: Colors.red.shade100,
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _errorMessage = null;
                      });
                    },
                    child: const Text('DISMISS'),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
