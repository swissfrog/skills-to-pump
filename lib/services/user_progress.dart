import 'package:flutter/foundation.dart';

/// Singleton XP / streak / level system.
class UserProgress extends ChangeNotifier {
  static final UserProgress _i = UserProgress._();
  factory UserProgress() => _i;
  UserProgress._();

  int _xp = 340;
  int _streak = 7;
  int _lessonsToday = 2;
  int _lessonsTotal = 18;
  int _tasksCompleted = 5;
  int _timeSavedMinutes = 0;

  int get xp => _xp;
  int get streak => _streak;
  int get lessonsToday => _lessonsToday;
  int get lessonsTotal => _lessonsTotal;
  int get tasksCompleted => _tasksCompleted;
  int get timeSavedMinutes => _timeSavedMinutes;
  int get timeSavedHours => (_timeSavedMinutes / 60).floor();
  int get timeSavedRemainingMinutes => _timeSavedMinutes % 60;
  int get level => (_xp / 100).floor() + 1;
  double get levelProgress => (_xp % 100) / 100.0;
  int get xpToNext => 100 - (_xp % 100);

  String get levelTitle {
    if (level < 3) return 'Einsteiger';
    if (level < 6) return 'Fortgeschrittener';
    if (level < 10) return 'Experte';
    return 'Meister';
  }

  void addXp(int amount) {
    _xp += amount;
    notifyListeners();
  }

  void completeLesson() {
    _lessonsToday++;
    _lessonsTotal++;
    addXp(20);
  }

  void completeTask() {
    _tasksCompleted++;
    addXp(10);
  }

  void addTimeSaved(int minutes) {
    _timeSavedMinutes += minutes;
    notifyListeners();
  }

  // Category progress (mock)
  double categoryProgress(String id) {
    const map = {
      'arzt': 0.7, 'steuern': 0.3, 'versicherungen': 0.5,
      'schule': 0.9, 'amt': 0.2, 'auto': 0.6, 'arbeit': 0.4, 'sonstiges': 0.1,
    };
    return map[id] ?? 0.0;
  }
}
