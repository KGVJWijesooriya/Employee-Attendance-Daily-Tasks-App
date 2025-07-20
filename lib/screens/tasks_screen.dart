import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/error_simulation.dart';
import 'package:intl/intl.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final tasks = await StorageService.getTasks();
      _tasks.clear();
      _tasks.addAll(tasks);
    } catch (e) {
      _error = 'Failed to load tasks.';
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveTasks() async {
    try {
      await StorageService.saveTasks(_tasks);
    } catch (e) {
      setState(() {
        _error = 'Failed to save tasks.';
      });
    }
  }

  void _addTask() async {
    String name = '';
    DateTime? dueDate;
    String priority = 'Low';
    String status = 'Not Started';
    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: Text('Add Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(labelText: 'Name'),
                      onChanged: (v) => name = v,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text('Due Date: '),
                        Text(
                          dueDate == null
                              ? 'Select'
                              : DateFormat('MM/dd/yyyy').format(dueDate!),
                        ),
                        IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null)
                              setState(() => dueDate = picked);
                          },
                        ),
                      ],
                    ),
                    DropdownButtonFormField<String>(
                      value: priority,
                      items: ['Low', 'Medium', 'High']
                          .map(
                            (p) => DropdownMenuItem(value: p, child: Text(p)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => priority = v!),
                      decoration: InputDecoration(labelText: 'Priority'),
                    ),
                    DropdownButtonFormField<String>(
                      value: status,
                      items: ['Not Started', 'In Progress', 'Done']
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => status = v!),
                      decoration: InputDecoration(labelText: 'Status'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (name.isEmpty) return;
                    // If no due date picked, set to today
                    if (dueDate == null) dueDate = DateTime.now();
                    Navigator.pop(ctx, {
                      'name': name,
                      'dueDate': dueDate!.toIso8601String(),
                      'priority': priority,
                      'status': status,
                    });
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    ).then((task) async {
      if (task != null) {
        setState(() {
          _tasks.add(task);
        });
        await _saveTasks();
        await _loadTasks();
      }
    });
  }

  void _updateStatus(int idx) async {
    String status = _tasks[idx]['status'];
    await showDialog(
      context: context,
      builder: (ctx) {
        String newStatus = status;
        return AlertDialog(
          title: Text('Update Status'),
          content: DropdownButtonFormField<String>(
            value: newStatus,
            items: [
              'Not Started',
              'In Progress',
              'Done',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => newStatus = v!,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, newStatus),
              child: Text('Update'),
            ),
          ],
        );
      },
    ).then((newStatus) async {
      if (newStatus != null && newStatus != status) {
        setState(() {
          _tasks[idx]['status'] = newStatus;
        });
        await _saveTasks();
      }
    });
  }

  // Hidden error simulation feature: long press on AppBar title
  void _simulateError() {
    ErrorSimulation.triggerError();
    setState(() {
      _error = 'Simulated error will occur on next save/load.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _simulateError,
          child: const Text('Tasks'),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Text(_error!, style: TextStyle(color: Colors.red)),
            )
          : _tasks.isEmpty
          ? Center(child: Text('No tasks yet.'))
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, i) {
                final t = _tasks[i];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(t['name'] ?? ''),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Due: ' +
                              (t['dueDate'] != null
                                  ? DateFormat(
                                      'MM/dd/yyyy',
                                    ).format(DateTime.parse(t['dueDate']))
                                  : ''),
                        ),
                        Text('Priority: ${t['priority']}'),
                        Text('Status: ${t['status']}'),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _updateStatus(i),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
        tooltip: 'Add Task',
      ),
    );
  }
}
