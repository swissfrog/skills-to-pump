import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTotalTimeSavedKey = 'lifenav_total_time_saved';
const _kLifeScoreKey = 'lifenav_life_score';

/// Life Score level thresholds: 0-20 Beginner, 21-50 Organizer, 51-80 Planner, 81-120 Explorer, 120+ Life Navigator
const _lifeScoreLevels = [
  (20, 'Beginner'),
  (50, 'Organizer'),
  (80, 'Planner'),
  (120, 'Explorer'),
  (999999, 'Life Navigator'),
];

/// Singleton XP / streak / level system + Time Saved + Life Score tracking.
class UserProgress extends ChangeNotifier {
  static final UserProgress _i = UserProgress._();
  factory UserProgress() => _i;
  UserProgress._() {
    _loadTimeSaved();
    _loadLifeScore();
  }

  int _xp = 340;
  int _streak = 7;
  int _lessonsToday = 2;
  int _lessonsTotal = 18;
  int _tasksCompleted = 5;
  int _totalTimeSavedMinutes = 0;
  int _lifeScore = 0;

  int get xp => _xp;
  int get streak => _streak;
  int get lessonsToday => _lessonsToday;
  int get lessonsTotal => _lessonsTotal;
  int get tasksCompleted => _tasksCompleted;
  int get totalTimeSavedMinutes => _totalTimeSavedMinutes;
  int get lifeScore => _lifeScore;
  int get level => (_xp / 100).floor() + 1;
  double get levelProgress => (_xp % 100) / 100.0;
  int get xpToNext => 100 - (_xp % 100);

  /// Life Score level name based on current score
  String get lifeScoreLevel {
    for (final level in _lifeScoreLevels) {
      if (_lifeScore <= level.$1) return level.$2;
    }
    return 'Life Navigator';
  }

  /// Progress within current Life Score level (0.0 to 1.0)
  double get lifeScoreLevelProgress {
    if (lifeScoreLevel == 'Life Navigator') return 1.0;
    int levelMin = 0;
    int levelMax = 20;
    for (int i = 0; i < _lifeScoreLevels.length; i++) {
      levelMax = _lifeScoreLevels[i].$1;
      if (_lifeScore <= levelMax) {
        levelMin = i > 0 ? _lifeScoreLevels[i - 1].$1 : 0;
        break;
      }
      levelMin = levelMax;
    }
    final range = levelMax - levelMin;
    if (range <= 0) return 1.0;
    return ((_lifeScore - levelMin) / range).clamp(0.0, 1.0);
  }

  /// Points needed to reach next Life Score level
  int get lifeScorePointsToNextLevel {
    for (int i = 0; i < _lifeScoreLevels.length; i++) {
      final max = _lifeScoreLevels[i].$1;
      if (_lifeScore < max) return max - _lifeScore;
    }
    return 0; // Max level
  }

  /// Formatted: "2h 30min" or "45min"
  String get totalTimeSavedFormatted {
    if (_totalTimeSavedMinutes < 60) return '$_totalTimeSavedMinutes min';
    final h = _totalTimeSavedMinutes ~/ 60;
    final m = _totalTimeSavedMinutes % 60;
    return m > 0 ? '${h}h ${m}min' : '${h}h';
  }

  String get levelTitle {
    if (level < 3) return 'Einsteiger';
    if (level < 6) return 'Fortgeschrittener';
    if (level < 10) return 'Experte';
    return 'Meister';
  }

  Future<void> _loadTimeSaved() async {
    final prefs = await SharedPreferences.getInstance();
    _totalTimeSavedMinutes = prefs.getInt(_kTotalTimeSavedKey) ?? 0;
  }

  Future<void> _persistTimeSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTotalTimeSavedKey, _totalTimeSavedMinutes);
  }

  Future<void> _loadLifeScore() async {
    final prefs = await SharedPreferences.getInstance();
    _lifeScore = prefs.getInt(_kLifeScoreKey) ?? 0;
  }

  Future<void> _persistLifeScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kLifeScoreKey, _lifeScore);
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

  /// Add time saved (in minutes) when user completes a task.
  void addTimeSaved(int minutes) {
    _totalTimeSavedMinutes += minutes;
    _persistTimeSaved();
    notifyListeners();
  }

  /// Life Score: Task completed → +1
  void addLifeScoreForTask() {
    _lifeScore += 1;
    _persistLifeScore();
    notifyListeners();
  }

  /// Life Score: Document uploaded → +2
  void addLifeScoreForDocument() {
    _lifeScore += 2;
    _persistLifeScore();
    notifyListeners();
  }

  /// Life Score: Event completed → +10
  void addLifeScoreForEvent() {
    _lifeScore += 10;
    _persistLifeScore();
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
