import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/json_data.dart';

/// Service to load events and tasks from JSON assets
class DataService {
  static DataService? _instance;
  static JsonEventData? _eventData;
  static JsonTaskData? _taskData;
  static bool _isLoaded = false;

  DataService._();

  static DataService get instance {
    _instance ??= DataService._();
    return _instance!;
  }

  /// Load all JSON data from assets
  Future<void> loadData() async {
    if (_isLoaded) return;

    try {
      // Load events
      final eventsJson = await rootBundle.loadString('assets/data/events.json');
      _eventData = JsonEventData.fromJson(jsonDecode(eventsJson));

      // Load tasks
      final tasksJson = await rootBundle.loadString('assets/data/tasks.json');
      _taskData = JsonTaskData.fromJson(jsonDecode(tasksJson));

      _isLoaded = true;
      print('✅ DataService: Loaded ${_eventData!.events.length} events and ${_taskData!.tasks.length} tasks');
    } catch (e) {
      print('❌ DataService: Failed to load JSON data: $e');
    }
  }

  /// Get all events
  List<JsonEvent> get events => _eventData?.events ?? [];

  /// Get all tasks
  List<JsonTask> get tasks => _taskData?.tasks ?? [];

  /// Get all unique categories
  List<String> get categories => _eventData?.categories ?? [];

  /// Get events grouped by category
  Map<String, List<JsonEvent>> get eventsByCategory => _eventData?.eventsByCategory ?? {};

  /// Get event by ID
  JsonEvent? getEventById(String id) {
    try {
      return events.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get task by ID
  JsonTask? getTaskById(String id) => _taskData?.getTaskById(id);

  /// Get tasks for an event
  List<JsonTask> getTasksForEvent(String eventId) {
    final event = getEventById(eventId);
    if (event == null) return [];
    return _taskData?.getTasksByIds(event.taskIds) ?? [];
  }

  /// Check if data is loaded
  bool get isLoaded => _isLoaded;
}
