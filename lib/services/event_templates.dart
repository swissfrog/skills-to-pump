import '../models/life_models.dart';
import '../models/json_data.dart';
import 'data_service.dart';

/// Central template system for life events.
/// Now loads from JSON data instead of hardcoded values.
class EventTemplates {
  
  /// Get tasks for an event type - loads from JSON
  static List<LifeTask> getTasksForEvent(LifeEventType type, {String country = 'DE'}) {
    // Map LifeEventType to the string ID used in JSON
    final eventId = _typeToId(type);
    if (eventId == null) return [];

    // Get tasks from DataService (which loads from JSON)
    final dataService = DataService.instance;
    final jsonTasks = dataService.getTasksForEvent(eventId);

    // Convert JsonTask to LifeTask
    return jsonTasks.map((jt) => _convertJsonTaskToLifeTask(jt, type)).toList();
  }

  /// Map LifeEventType to JSON event ID
  static String? _typeToId(LifeEventType type) {
    switch (type) {
      case LifeEventType.move:
        return 'move';
      case LifeEventType.newJob:
        return 'newJob';
      case LifeEventType.buyCar:
        return 'buyCar';
      case LifeEventType.taxYear:
        return 'taxYear';
      case LifeEventType.study:
        return 'study';
      case LifeEventType.family:
        return 'family';
    }
  }

  /// Convert JSON task model to the app's LifeTask model
  static LifeTask _convertJsonTaskToLifeTask(JsonTask jt, LifeEventType eventType) {
    return LifeTask(
      id: jt.id,
      title: jt.title,
      description: jt.description,
      explanation: jt.explanation ?? '',
      requiredDocs: jt.requiredDocuments,
      steps: jt.steps,
      priority: jt.priorityEnum,
      eventType: eventType,
      xpReward: jt.xpReward,
      timeSaved: jt.timeSaved,
    );
  }

  /// Get all events from JSON (for UI)
  static List<JsonEvent> getAllEvents() {
    return DataService.instance.events;
  }
}
