import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/error_simulation.dart';
import 'about_screen.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String? _name;
  TextEditingController _nameController = TextEditingController();
  bool _isEditingName = false;

  DateTime _today = DateTime.now();
  String? _checkIn;
  String? _checkOut;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _name = await StorageService.getUserName();
      if (_name != null) _nameController.text = _name!;
      String todayKey = _dateKey(_today);
      final todayRecord = await StorageService.getAttendanceRecord(todayKey);
      _checkIn = todayRecord['checkIn'];
      _checkOut = todayRecord['checkOut'];
      // Load history
      final keys = await StorageService.getAttendanceHistory();
      _history = [];
      for (final k in keys) {
        final rec = await StorageService.getAttendanceRecord(k);
        _history.add({
          'dateKey': k,
          'checkIn': rec['checkIn'],
          'checkOut': rec['checkOut'],
          'onLeave': rec['onLeave'],
        });
      }
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data.';
        _loading = false;
      });
    }
  }

  String _dateKey(DateTime dt) => DateFormat('yyyyMMdd').format(dt);

  Future<void> _saveName() async {
    try {
      await StorageService.setUserName(_nameController.text.trim());
      setState(() {
        _name = _nameController.text.trim();
        _isEditingName = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to save name.';
      });
    }
  }

  Future<void> _checkInNow() async {
    try {
      String now = DateFormat('HH:mm').format(DateTime.now());
      await StorageService.setCheckIn(_dateKey(_today), now);
      setState(() {
        _checkIn = now;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to check in.';
      });
    }
  }

  Future<void> _markOnLeave(String dateKey) async {
    try {
      await StorageService.setOnLeave(dateKey, true);
      await _loadData();
    } catch (e) {
      setState(() {
        _error = 'Failed to mark as On Leave.';
      });
    }
  }

  Future<void> _checkOutNow() async {
    try {
      String now = DateFormat('HH:mm').format(DateTime.now());
      await StorageService.setCheckOut(_dateKey(_today), now);
      setState(() {
        _checkOut = now;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to check out.';
      });
    }
  }

  String _attendanceStatus() {
    if (_checkIn != null && _checkOut != null) return 'Present';
    if (_checkIn != null || _checkOut != null) return 'Incomplete';
    return 'Absent';
  }

  String _todayDate() => DateFormat.yMd().format(_today);
  String _todayDay() => DateFormat.EEEE().format(_today);

  String _timeSpent() {
    if (_checkIn == null || _checkOut == null) return '--:--';
    try {
      DateTime inTime = DateFormat('HH:mm').parse(_checkIn!);
      DateTime outTime = DateFormat('HH:mm').parse(_checkOut!);
      Duration diff = outTime.difference(inTime);
      if (diff.isNegative) return '--:--';
      int h = diff.inHours;
      int m = diff.inMinutes % 60;
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
    } catch (_) {
      return '--:--';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: () {
            ErrorSimulation.triggerError();
            setState(() {
              _error = 'Simulated error will occur on next save/load.';
            });
          },
          child: const Text('Attendance'),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_error!, style: TextStyle(color: Colors.red)),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: _isEditingName || _name == null
                            ? TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: 'Enter your name',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.check),
                                    onPressed: _saveName,
                                  ),
                                ),
                              )
                            : ListTile(
                                title: Text('Name: $_name'),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    setState(() {
                                      _isEditingName = true;
                                    });
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today: ${_todayDate()} (${_todayDay()})',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text('Check-In: ${_checkIn ?? '--:--'}'),
                              ),
                              ElevatedButton(
                                onPressed: _checkIn == null
                                    ? _checkInNow
                                    : null,
                                child: Text('Check-In'),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Check-Out: ${_checkOut ?? '--:--'}',
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _checkOut == null && _checkIn != null
                                    ? _checkOutNow
                                    : null,
                                child: Text('Check-Out'),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text('Time Spent: ${_timeSpent()}'),
                          SizedBox(height: 8),
                          Text(
                            'Attendance Status: ${_attendanceStatus()}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'History:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, idx) {
                        final rec = _history[idx];
                        final date = DateTime.parse(rec['dateKey']);
                        final dateStr = DateFormat.yMd().format(date);
                        final dayStr = DateFormat.EEEE().format(date);
                        final status =
                            (rec['checkIn'] != null && rec['checkOut'] != null)
                            ? 'Present'
                            : (rec['checkIn'] != null ||
                                  rec['checkOut'] != null)
                            ? 'Incomplete'
                            : rec['onLeave'] == true
                            ? 'On Leave'
                            : 'Absent';
                        return ListTile(
                          title: Text('$dateStr ($dayStr)'),
                          subtitle: Text(
                            'Check-In: ${rec['checkIn'] ?? '--:--'}, Check-Out: ${rec['checkOut'] ?? '--:--'}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(status),
                              if (status != 'On Leave')
                                IconButton(
                                  icon: Icon(
                                    Icons.beach_access,
                                    color: Colors.blueGrey,
                                  ),
                                  tooltip: 'Mark as On Leave',
                                  onPressed: () => _markOnLeave(rec['dateKey']),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
