// ─── Enums ────────────────────────────────────────────────────────────────────

enum DocCategory { bills, government, insurance, contracts, personal, appointments, other }
enum DocType { invoice, govLetter, contract, insurance, appointment, form, unknown }
enum TaskStatus { open, inProgress, completed }
enum TaskPriority { low, medium, high }

extension DocCategoryLabel on DocCategory {
  String get label {
    const m = {
      DocCategory.bills: 'Rechnungen', DocCategory.government: 'Behörden',
      DocCategory.insurance: 'Versicherung', DocCategory.contracts: 'Verträge',
      DocCategory.personal: 'Persönlich', DocCategory.appointments: 'Termine',
      DocCategory.other: 'Sonstiges',
    };
    return m[this]!;
  }
}

extension DocTypeLabel on DocType {
  String get label {
    const m = {
      DocType.invoice: 'Rechnung', DocType.govLetter: 'Behördenbrief',
      DocType.contract: 'Vertrag', DocType.insurance: 'Versicherung',
      DocType.appointment: 'Termin', DocType.form: 'Formular',
      DocType.unknown: 'Unbekannt',
    };
    return m[this]!;
  }
}

// ─── Timeline Event ───────────────────────────────────────────────────────────

class TimelineEvent {
  final String id;
  final String title;
  final String? note;
  final DateTime date;
  const TimelineEvent({required this.id, required this.title, this.note, required this.date});
}

// ─── Task ─────────────────────────────────────────────────────────────────────

class DocTask {
  final String id;
  final String title;
  final String description;
  final DateTime? deadline;
  final TaskStatus status;
  final TaskPriority priority;
  final String? linkedDocId;

  const DocTask({
    required this.id,
    required this.title,
    required this.description,
    this.deadline,
    this.status = TaskStatus.open,
    this.priority = TaskPriority.medium,
    this.linkedDocId,
  });

  DocTask copyWith({TaskStatus? status}) => DocTask(
    id: id, title: title, description: description,
    deadline: deadline, status: status ?? this.status,
    priority: priority, linkedDocId: linkedDocId,
  );
}

// ─── Scanned Document ─────────────────────────────────────────────────────────

class ScannedDocument {
  final String id;
  final String name;
  final String imagePath;
  final DateTime scannedAt;
  final String? ocrText;
  final DocCategory category;
  final DocType docType;
  final String? sender;
  final String? aiSummary;
  final String? aiExplanation;
  final String? replyDraft;
  final List<DocTask> tasks;
  final List<TimelineEvent> timeline;
  final bool hasForm;
  /// Links this document to a required doc from LifeTask.requiredDocs
  final String? linkedRequiredDoc;

  const ScannedDocument({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.scannedAt,
    this.ocrText,
    this.category = DocCategory.other,
    this.docType = DocType.unknown,
    this.sender,
    this.aiSummary,
    this.aiExplanation,
    this.replyDraft,
    this.tasks = const [],
    this.timeline = const [],
    this.hasForm = false,
    this.linkedRequiredDoc,
  });

  ScannedDocument copyWith({
    String? aiSummary, String? aiExplanation, String? replyDraft,
    DocCategory? category, DocType? docType, String? sender,
    List<DocTask>? tasks, List<TimelineEvent>? timeline, bool? hasForm,
    String? linkedRequiredDoc,
  }) => ScannedDocument(
    id: id, name: name, imagePath: imagePath, scannedAt: scannedAt,
    ocrText: ocrText,
    category: category ?? this.category,
    docType: docType ?? this.docType,
    sender: sender ?? this.sender,
    aiSummary: aiSummary ?? this.aiSummary,
    aiExplanation: aiExplanation ?? this.aiExplanation,
    replyDraft: replyDraft ?? this.replyDraft,
    tasks: tasks ?? this.tasks,
    timeline: timeline ?? this.timeline,
    hasForm: hasForm ?? this.hasForm,
    linkedRequiredDoc: linkedRequiredDoc ?? this.linkedRequiredDoc,
  );
}

// ─── Legacy stubs (lesson_screen compat) ─────────────────────────────────────

class SkillCategory {
  final String id; final String title; final String icon; final String color;
  const SkillCategory({required this.id, required this.title, required this.icon, required this.color});
}
class Lesson {
  final String id; final String title; final String subtitle; final int order;
  final bool isUnlocked; final bool isCompleted;
  const Lesson({required this.id, required this.title, required this.subtitle, required this.order,
    this.isUnlocked = false, this.isCompleted = false});
}
class Stage {
  final int number; final String label; final bool isCompleted; final bool isCurrent;
  const Stage({required this.number, required this.label, this.isCompleted = false, this.isCurrent = false});
}
