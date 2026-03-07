import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// Simple in-memory document store with ChangeNotifier.
class DocStore extends ChangeNotifier {
  static final DocStore _instance = DocStore._();
  factory DocStore() => _instance;
  DocStore._();

  final List<ScannedDocument> _docs = [];
  final List<DocTask> _allTasks = [];

  List<ScannedDocument> get docs => List.unmodifiable(_docs);

  List<DocTask> get allTasks {
    // Merge tasks from all docs + standalone tasks
    final fromDocs = _docs.expand((d) => d.tasks).toList();
    final taskIds = fromDocs.map((t) => t.id).toSet();
    final standalone = _allTasks.where((t) => !taskIds.contains(t.id)).toList();
    return [...fromDocs, ...standalone]
      ..sort((a, b) {
        if (a.deadline == null && b.deadline == null) return 0;
        if (a.deadline == null) return 1;
        if (b.deadline == null) return -1;
        return a.deadline!.compareTo(b.deadline!);
      });
  }

  List<DocTask> get openTasks => allTasks.where((t) => t.status != TaskStatus.completed).toList();
  List<DocTask> get urgentTasks => openTasks.where((t) {
    if (t.deadline == null) return false;
    return t.deadline!.difference(DateTime.now()).inDays <= 7;
  }).toList();

  void addDocument(ScannedDocument doc) {
    _docs.insert(0, doc);
    notifyListeners();
  }

  void updateDocument(ScannedDocument doc) {
    final idx = _docs.indexWhere((d) => d.id == doc.id);
    if (idx >= 0) { _docs[idx] = doc; notifyListeners(); }
  }

  void removeDocument(String id) {
    _docs.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  void updateTaskStatus(String taskId, TaskStatus status) {
    // Update in docs
    for (int i = 0; i < _docs.length; i++) {
      final tasks = _docs[i].tasks.map((t) => t.id == taskId ? t.copyWith(status: status) : t).toList();
      if (tasks.any((t) => t.id == taskId)) {
        _docs[i] = _docs[i].copyWith(tasks: tasks);
      }
    }
    notifyListeners();
  }

  List<ScannedDocument> getByCategory(DocCategory cat) =>
      _docs.where((d) => d.category == cat).toList();

  int get totalDocs => _docs.length;
}
