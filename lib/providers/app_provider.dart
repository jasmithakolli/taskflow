import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class AppProvider extends ChangeNotifier {
  static const _tasksKey = 'taskflow_tasks_v1';
  static const _themeKey = 'taskflow_theme_v1';

  List<Task> _tasks = [];
  bool _ready = false;
  bool isSetupComplete = false;
  ThemeMode _themeMode = ThemeMode.dark;
  String profileName = '';

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isReady => _ready;
  ThemeMode get themeMode => _themeMode;
  int get total => _tasks.length;
  int get completed => _tasks.where((t) => t.isCompleted).length;
  int get pending => _tasks.where((t) => t.status == 'Pending').length;
  int get inProgress => _tasks.where((t) => t.status == 'In Progress').length;
  int get overdue => _tasks.where((t) => t.isOverdue).length;
  double get completionRate => total == 0 ? 0 : completed / total;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_tasksKey);
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List<dynamic>;
        _tasks = decoded
            .map((e) => Task.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        _tasks = [];
      }
    }
    profileName = prefs.getString('taskflow_profile_name') ?? '';
    isSetupComplete = prefs.getBool('taskflow_setup_complete') ?? false;
    _themeMode = prefs.getBool(_themeKey) == false
        ? ThemeMode.light
        : ThemeMode.dark;
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _tasksKey,
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  Future<void> addTask(Task task) async {
    _tasks.insert(0, task);
    await _persist();
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index < 0) return;
    _tasks[index] = task;
    await _persist();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> setStatus(Task task, String status) async {
    task.status = status;
    await updateTask(task);
  }

  Future<void> toggleTheme(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, dark);
    notifyListeners();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isCompleted);
    await _persist();
    notifyListeners();
  }

  Future<void> completeSetup(String name) async {
    profileName = name.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taskflow_profile_name', profileName);
    await prefs.setBool('taskflow_setup_complete', true);
    isSetupComplete = true;
    notifyListeners();
  }

  Future<void> updateProfile(String name) async {
    final value = name.trim();
    if (value.isEmpty) return;
    profileName = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taskflow_profile_name', profileName);
    notifyListeners();
  }
}
