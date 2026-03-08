import 'package:flutter/material.dart';

// ──────────────────────────────────────────────────────────
// Immutable data layer
// ──────────────────────────────────────────────────────────

class RequiredDoc {
  final String id;
  final String name;
  final bool available;

  const RequiredDoc({
    required this.id,
    required this.name,
    this.available = false,
  });

  RequiredDoc toggle() =>
      RequiredDoc(id: id, name: name, available: !available);
}

class TaskStep {
  final int number;
  final String text;
  const TaskStep({required this.number, required this.text});
}

class LifeTask {
  final String id;
  final String title;
  final String description;
  final List<RequiredDoc> docs;
  final List<TaskStep> steps;
  final bool completed;
  final int estimatedMinutes;

  const LifeTask({
    required this.id,
    required this.title,
    required this.description,
    required this.docs,
    required this.steps,
    this.completed = false,
    this.estimatedMinutes = 15,
  });

  LifeTask markDone() => _copy(completed: true);

  LifeTask withDoc(int idx, RequiredDoc doc) {
    final list = List<RequiredDoc>.from(docs);
    list[idx] = doc;
    return _copy(docs: list);
  }

  LifeTask _copy({
    bool? completed,
    List<RequiredDoc>? docs,
  }) =>
      LifeTask(
        id: id,
        title: title,
        description: description,
        docs: docs ?? this.docs,
        steps: steps,
        completed: completed ?? this.completed,
        estimatedMinutes: estimatedMinutes,
      );
}

class LifeEvent {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<LifeTask> tasks;
  final DateTime startedAt;

  const LifeEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.tasks,
    required this.startedAt,
  });

  // ── Computed ──────────────────────────────────────────
  int get doneCount => tasks.where((t) => t.completed).length;
  int get totalCount => tasks.length;
  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;
  bool get isCompleted => doneCount == totalCount && totalCount > 0;

  int get minutesLeft => tasks
      .where((t) => !t.completed)
      .fold(0, (s, t) => s + t.estimatedMinutes);

  LifeTask? get nextTask {
    for (final t in tasks) {
      if (!t.completed) return t;
    }
    return null;
  }

  LifeEvent withTasks(List<LifeTask> t) => LifeEvent(
        id: id,
        title: title,
        description: description,
        icon: icon,
        color: color,
        tasks: t,
        startedAt: startedAt,
      );
}
