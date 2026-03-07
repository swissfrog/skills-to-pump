import 'package:flutter/foundation.dart';
import '../models/life_models.dart';
import 'event_templates.dart';
import 'user_progress.dart';

/// Central state for life events and tasks.
class LifeStore extends ChangeNotifier {
  static final LifeStore _i = LifeStore._();
  factory LifeStore() => _i;
  LifeStore._() { _seedDemoData(); }

  final List<LifeEvent> _events = [];
  final _progress = UserProgress();

  List<LifeEvent> get events => List.unmodifiable(_events);

  List<LifeTask> get allTasks =>
      _events.expand((e) => e.tasks).toList()
        ..sort((a, b) {
          if (a.status.isDone && !b.status.isDone) return 1;
          if (!a.status.isDone && b.status.isDone) return -1;
          final pa = a.priority.index; final pb = b.priority.index;
          if (pa != pb) return pb.compareTo(pa);
          if (a.deadline == null && b.deadline != null) return 1;
          if (a.deadline != null && b.deadline == null) return -1;
          if (a.deadline != null && b.deadline != null) return a.deadline!.compareTo(b.deadline!);
          return 0;
        });

  List<LifeTask> get openTasks => allTasks.where((t) => !t.status.isDone).toList();
  List<LifeTask> get todayTasks => openTasks.where((t) => t.isDueToday || t.isOverdue).toList();
  List<LifeTask> get urgentTasks => openTasks.where((t) => t.isDueSoon || t.priority == TaskPriority.urgent).toList();
  List<LifeTask> get completedTasks => allTasks.where((t) => t.status.isDone).toList();

  LifeTask? get nextTask => openTasks.isNotEmpty ? openTasks.first : null;

  int get estimatedMinutesSaved => completedTasks.length * 45;

  // ── Actions ─────────────────────────────────────────────────────────────────

  LifeEvent startEvent(LifeEventType type) {
    // Generate tasks using the new template system
    final templates = EventTemplates.getTasksForEvent(type);
    
    // In a real database scenario, these would be saved to 'user_tasks'
    final tasks = templates.map((t) => t.copyWith()).toList();

    final ev = LifeEvent(
      id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
      type: type, 
      startedAt: DateTime.now(), 
      tasks: tasks,
    );
    _events.insert(0, ev);
    notifyListeners();
    return ev;
  }

  void updateTaskStatus(String taskId, TaskStatus status) {
    for (int ei = 0; ei < _events.length; ei++) {
      final tasks = _events[ei].tasks;
      final ti = tasks.indexWhere((t) => t.id == taskId);
      if (ti >= 0) {
        final updated = List<LifeTask>.from(tasks);
        updated[ti] = tasks[ti].copyWith(status: status);
        _events[ei] = LifeEvent(
          id: _events[ei].id, type: _events[ei].type,
          startedAt: _events[ei].startedAt, tasks: updated,
        );
        if (status == TaskStatus.completed) _progress.completeTask();
        notifyListeners();
        return;
      }
    }
  }

  bool hasEvent(LifeEventType type) => _events.any((e) => e.type == type);

  // ── Demo seed ────────────────────────────────────────────────────────────────
  void _seedDemoData() {
    final moveTasks = EventTemplates.getTasksForEvent(LifeEventType.move);
    // Mark first two as done
    final seeded = moveTasks.asMap().entries.map((e) =>
        e.key < 2 ? e.value.copyWith(status: TaskStatus.completed) : e.value).toList();
    _events.add(LifeEvent(
      id: 'ev_demo', type: LifeEventType.move,
      startedAt: DateTime.now().subtract(const Duration(days: 5)),
      tasks: seeded,
    ));
  }
}
