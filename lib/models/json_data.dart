import 'package:flutter/material.dart';
import 'life_models.dart';

/// Converts string to TaskPriority (using life_models.dart enum)
TaskPriority priorityFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'urgent':
      return TaskPriority.urgent;
    case 'high':
      return TaskPriority.high;
    case 'medium':
      return TaskPriority.medium;
    default:
      return TaskPriority.low;
  }
}

/// Model for a task loaded from JSON
class JsonTask {
  final String id;
  final String title;
  final String description;
  final String? explanation;
  final List<String> requiredDocuments;
  final List<String> steps;
  final String priority;
  final int xpReward;
  final int timeSaved;

  JsonTask({
    required this.id,
    required this.title,
    required this.description,
    this.explanation,
    required this.requiredDocuments,
    required this.steps,
    required this.priority,
    required this.xpReward,
    this.timeSaved = 0,
  });

  factory JsonTask.fromJson(Map<String, dynamic> json) {
    return JsonTask(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      explanation: json['explanation'] as String?,
      requiredDocuments: (json['requiredDocuments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      steps: (json['steps'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      priority: json['priority'] as String? ?? 'medium',
      xpReward: json['xpReward'] as int? ?? 10,
      timeSaved: json['timeSaved'] as int? ?? 0,
    );
  }

  TaskPriority get priorityEnum => priorityFromString(priority);
}

/// Model for an event loaded from JSON
class JsonEvent {
  final String id;
  final String title;
  final String icon;
  final String description;
  final String category;
  final List<String> taskIds;

  JsonEvent({
    required this.id,
    required this.title,
    required this.icon,
    required this.description,
    required this.category,
    required this.taskIds,
  });

  factory JsonEvent.fromJson(Map<String, dynamic> json) {
    return JsonEvent(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String? ?? 'event',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      taskIds: (json['taskIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convert icon string to IconData
  IconData get iconData {
    switch (icon) {
      case 'home_outlined':
        return Icons.home_outlined;
      case 'work_outline':
        return Icons.work_outline;
      case 'directions_car_outlined':
        return Icons.directions_car_outlined;
      case 'description_outlined':
        return Icons.description_outlined;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'favorite_outline':
        return Icons.favorite_outline;
      default:
        return Icons.event;
    }
  }
}

/// Container for all events loaded from JSON
class JsonEventData {
  final List<JsonEvent> events;

  JsonEventData({required this.events});

  factory JsonEventData.fromJson(Map<String, dynamic> json) {
    return JsonEventData(
      events: (json['events'] as List<dynamic>)
          .map((e) => JsonEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get all unique categories
  List<String> get categories {
    return events.map((e) => e.category).toSet().toList()..sort();
  }

  /// Get events grouped by category
  Map<String, List<JsonEvent>> get eventsByCategory {
    final Map<String, List<JsonEvent>> grouped = {};
    for (final event in events) {
      grouped.putIfAbsent(event.category, () => []).add(event);
    }
    return grouped;
  }

  /// Get events for a specific category
  List<JsonEvent> getEventsByCategory(String category) {
    return events.where((e) => e.category == category).toList();
  }
}

/// Container for all tasks loaded from JSON
class JsonTaskData {
  final List<JsonTask> tasks;

  JsonTaskData({required this.tasks});

  factory JsonTaskData.fromJson(Map<String, dynamic> json) {
    return JsonTaskData(
      tasks: (json['tasks'] as List<dynamic>)
          .map((e) => JsonTask.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Find a task by its ID
  JsonTask? getTaskById(String id) {
    try {
      return tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get multiple tasks by their IDs
  List<JsonTask> getTasksByIds(List<String> ids) {
    return ids.map((id) => getTaskById(id)).whereType<JsonTask>().toList();
  }
}
