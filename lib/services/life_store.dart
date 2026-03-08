import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/life_models.dart';
import 'event_templates.dart';
import 'user_progress.dart';

const _kEventsKey = 'lifenav_events';

/// Central state for life events and tasks.
class LifeStore extends ChangeNotifier {
  static final LifeStore _i = LifeStore._();
  factory LifeStore() => _i;
  LifeStore._() { _loadOrSeed(); }

  final List<LifeEvent> _events = [];
  final _progress = UserProgress();
  bool _loaded = false;

  Future<void> _loadOrSeed() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kEventsKey);
    if (json != null && json.isNotEmpty) {
      try {
        final list = jsonDecode(json) as List;
        _events.clear();
        _events.addAll(list.map((e) => LifeEvent.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }
    if (_events.isEmpty) _seedDemoData();
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final list = _events.map((e) => e.toJson()).toList();
    await prefs.setString(_kEventsKey, jsonEncode(list));
  }

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
    final templates = EventTemplates.getTasksForEvent(type);
    final tasks = templates.map((t) => t.copyWith()).toList();

    final ev = LifeEvent(
      id: 'ev_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      startedAt: DateTime.now(),
      tasks: tasks,
    );
    _events.insert(0, ev);
    notifyListeners();
    _persist();
    return ev;
  }

  /// Returns the event if it just became completed (all tasks done), else null.
  LifeEvent? updateTaskStatus(String taskId, TaskStatus status) {
    for (int ei = 0; ei < _events.length; ei++) {
      final tasks = _events[ei].tasks;
      final ti = tasks.indexWhere((t) => t.id == taskId);
      if (ti >= 0) {
        final task = tasks[ti];
        final wasCompleted = task.status.isDone;
        final updated = List<LifeTask>.from(tasks);
        updated[ti] = task.copyWith(status: status);
        _events[ei] = LifeEvent(
          id: _events[ei].id, type: _events[ei].type,
          startedAt: _events[ei].startedAt, tasks: updated,
        );
        if (status == TaskStatus.completed) {
          _progress.completeTask();
          _progress.addTimeSaved(task.timeSaved);
          _progress.addLifeScoreForTask();
        }
        notifyListeners();
        _persist();
        final ev = _events[ei];
        if (ev.isCompleted) {
          _progress.addLifeScoreForEvent();
          return ev;
        }
        return null;
      }
    }
    return null;
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
