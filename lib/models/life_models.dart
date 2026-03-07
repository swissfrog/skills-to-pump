// ─── Life Event Types ─────────────────────────────────────────────────────────

enum LifeEventType {
  move, newJob, buyCar, taxYear, study, family,
}

extension LifeEventTypeExt on LifeEventType {
  String get label {
    const m = {
      LifeEventType.move: 'Umzug', LifeEventType.newJob: 'Neuer Job',
      LifeEventType.buyCar: 'Auto kaufen', LifeEventType.taxYear: 'Steuerjahr',
      LifeEventType.study: 'Studium', LifeEventType.family: 'Familie',
    };
    return m[this]!;
  }

  String get emoji {
    const m = {
      LifeEventType.move: '📦', LifeEventType.newJob: '💼',
      LifeEventType.buyCar: '🚗', LifeEventType.taxYear: '📋',
      LifeEventType.study: '🎓', LifeEventType.family: '👨‍👩‍👧',
    };
    return m[this]!;
  }

  String get description {
    const m = {
      LifeEventType.move: 'Ummelden, Verträge ändern, Nachsendeauftrag',
      LifeEventType.newJob: 'Lohnsteuer, Sozialversicherung, Vertrag',
      LifeEventType.buyCar: 'Zulassung, Versicherung, TÜV',
      LifeEventType.taxYear: 'Steuererklärung, Belege, Fristen',
      LifeEventType.study: 'Immatrikulation, BAföG, Krankenversicherung',
      LifeEventType.family: 'Kindergeld, Elterngeld, Geburtsurkunde',
    };
    return m[this]!;
  }
}

// ─── Task Priority & Status ───────────────────────────────────────────────────

enum TaskPriority { low, medium, high, urgent }
enum TaskStatus   { open, inProgress, completed, skipped }

extension TaskPriorityExt on TaskPriority {
  String get label {
    const m = {
      TaskPriority.low: 'Niedrig', TaskPriority.medium: 'Mittel',
      TaskPriority.high: 'Hoch', TaskPriority.urgent: 'Dringend',
    };
    return m[this]!;
  }
}

extension TaskStatusExt on TaskStatus {
  String get label {
    const m = {
      TaskStatus.open: 'Offen', TaskStatus.inProgress: 'In Arbeit',
      TaskStatus.completed: 'Erledigt', TaskStatus.skipped: 'Übersprungen',
    };
    return m[this]!;
  }

  bool get isDone => this == TaskStatus.completed || this == TaskStatus.skipped;
}

// ─── Life Task ────────────────────────────────────────────────────────────────

class LifeTask {
  final String id;
  final String title;
  final String description;
  final String explanation;
  final List<String> requiredDocs;
  final List<String> steps;
  final TaskPriority priority;
  final TaskStatus status;
  final DateTime? deadline;
  final LifeEventType? eventType;
  final String? tip;
  final int xpReward;

  const LifeTask({
    required this.id,
    required this.title,
    required this.description,
    required this.explanation,
    this.requiredDocs = const [],
    this.steps = const [],
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.open,
    this.deadline,
    this.eventType,
    this.tip,
    this.xpReward = 15,
  });

  LifeTask copyWith({TaskStatus? status}) => LifeTask(
    id: id, title: title, description: description,
    explanation: explanation, requiredDocs: requiredDocs,
    steps: steps, priority: priority,
    status: status ?? this.status,
    deadline: deadline, eventType: eventType, tip: tip, xpReward: xpReward,
  );

  bool get isOverdue =>
      deadline != null && deadline!.isBefore(DateTime.now()) && !status.isDone;
  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    final d = deadline!;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }
  bool get isDueSoon {
    if (deadline == null) return false;
    return deadline!.difference(DateTime.now()).inDays <= 7 && !status.isDone;
  }
}

// ─── Life Event ───────────────────────────────────────────────────────────────

class LifeEvent {
  final String id;
  final LifeEventType type;
  final DateTime startedAt;
  final List<LifeTask> tasks;

  const LifeEvent({
    required this.id,
    required this.type,
    required this.startedAt,
    required this.tasks,
  });

  int get completedCount => tasks.where((t) => t.status.isDone).length;
  double get progress => tasks.isEmpty ? 0 : completedCount / tasks.length;
  bool get isCompleted => completedCount == tasks.length;
}
