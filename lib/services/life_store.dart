import 'package:hive_flutter/hive_flutter.dart';

class LifeStore {
  static const String _tasksBox = 'tasks';
  static const String _eventsBox = 'events';
  static const String _settingsBox = 'settings';

  static late Box _tasks;
  static late Box _events;
  static late Box _settings;

  static Future<void> init() async {
    await Hive.initFlutter();
    _tasks = await Hive.openBox(_tasksBox);
    _events = await Hive.openBox(_eventsBox);
    _settings = await Hive.openBox(_settingsBox);
  }

  // Tasks
  static List<Map> getTasks() => _tasks.values.map((e) => Map<String, dynamic>.from(e)).toList();
  
  static Future<void> addTask(Map task) async {
    await _tasks.add(task);
  }

  static Future<void> updateTask(int key, Map task) async {
    await _tasks.put(key, task);
  }

  static Future<void> deleteTask(int key) async {
    await _tasks.delete(key);
  }

  // Events
  static List<Map> getEvents() => _events.values.map((e) => Map<String, dynamic>.from(e)).toList();
  
  static Future<void> addEvent(Map event) async {
    await _events.add(event);
  }

  // Settings
  static dynamic get(String key) => _settings.get(key);
  
  static Future<void> set(String key, dynamic value) async {
    await _settings.put(key, value);
  }
}