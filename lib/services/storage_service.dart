import 'package:shared_preferences/shared_preferences.dart';
import '../utils/error_simulation.dart';
import 'dart:convert';

class StorageService {
  // Attendance
  static Future<String?> getUserName() async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during load');
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<void> setUserName(String name) async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during save');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<Map<String, dynamic>> getAttendanceRecord(
    String dateKey,
  ) async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during load');
    }
    final prefs = await SharedPreferences.getInstance();
    return {
      'checkIn': prefs.getString('attendance_${dateKey}_in'),
      'checkOut': prefs.getString('attendance_${dateKey}_out'),
      'onLeave': prefs.getBool('attendance_${dateKey}_leave') ?? false,
    };
  }

  static Future<void> setCheckIn(String dateKey, String time) async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during save');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_${dateKey}_in', time);
  }

  static Future<void> setCheckOut(String dateKey, String time) async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during save');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('attendance_${dateKey}_out', time);
  }

  static Future<void> setOnLeave(String dateKey, bool value) async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during save');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('attendance_${dateKey}_leave', value);
  }

  // Attendance history: returns a list of dateKeys with any record
  static Future<List<String>> getAttendanceHistory() async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during load');
    }
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final dateKeys = <String>{};
    for (final k in keys) {
      final match = RegExp(r'attendance_(\d{8})_').firstMatch(k);
      if (match != null) {
        dateKeys.add(match.group(1)!);
      }
    }
    return dateKeys.toList()..sort((a, b) => b.compareTo(a)); // newest first
  }

  // Tasks
  static Future<List<Map<String, dynamic>>> getTasks() async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during load');
    }
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    return tasksJson
        .map((t) => Map<String, dynamic>.from(jsonDecode(t)))
        .toList();
  }

  static Future<void> saveTasks(List<Map<String, dynamic>> tasks) async {
    if (ErrorSimulation.shouldSimulateError) {
      ErrorSimulation.reset();
      throw Exception('Simulated error during save');
    }
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((t) => jsonEncode(t)).toList();
    await prefs.setStringList('tasks', tasksJson);
  }
}
