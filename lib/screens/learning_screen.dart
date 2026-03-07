import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_progress.dart';
import '../widgets/glass_widgets.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});
  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  int _tab = 0;
  final _progress = UserProgress();

  static const _topics = [
    {
      'id': 'steuern', 'title': 'Steuern',
      'icon': Icons.calculate_outlined, 'color': Color(0xFFFF9F0A),
      'lessons': [
        {'title': 'Was ist die Steuererklärung?', 'xp': 20, 'done': true},
        {'title': 'Welche Formulare brauche ich?', 'xp': 20, 'done': true},
        {'title': 'Absetzbare Kosten verstehen', 'xp': 25, 'done': false},
        {'title': 'Elster online nutzen', 'xp': 30, 'done': false},
      ],
    },
    {
      'id': 'amt', 'title': 'Behörden',
      'icon': Icons.account_balance_outlined, 'color': Color(0xFF30D158),
      'lessons': [
        {'title': 'Behördenbriefe lesen', 'xp': 20, 'done': true},
        {'title': 'Widerspruch einlegen', 'xp': 25, 'done': false},
        {'title': 'Fristen richtig berechnen', 'xp': 20, 'done': false},
      ],
    },
    {
      'id': 'versicherungen', 'title': 'Versicherung',
      'icon': Icons.shield_outlined, 'color': Color(0xFF0A84FF),
      'lessons': [
        {'title': 'Welche Versicherungen brauche ich?', 'xp': 20, 'done': false},
        {'title': 'Schaden melden', 'xp': 20, 'done': false},
        {'title': 'Kündigung richtig formulieren', 'xp': 25, 'done': false},
      ],
    },
    {
      'id': 'arzt', 'title': 'Gesundheit',
      'icon': Icons.local_hospital_outlined, 'color': Color(0xFFFF453A),
      'lessons': [
        {'title': 'Krankenkasse verstehen', 'xp': 20, 'done': true},
        {'title': 'Arztkosten absetzen', 'xp': 25, 'done': false},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LP.bg,
      body: SafeArea(
        child: Column(children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTabBar(),
          ),
          const SizedBox(height: 16),
          Expanded(child: _tab == 0 ? _buildAllTopics() : _buildInProgress()),
        ]),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: LP.surface, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Lernen', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          Text('Wissen aufbauen • XP sammeln', style: TextStyle(color: LP.label3, fontSize: 11)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: LP.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: LP.primary.withValues(alpha: 0.3), width: 1)),
          child: Text('${_progress.xp} XP',
            style: const TextStyle(color: LP.primary, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }

  Widget _buildTabBar() {
    final labels = ['Alle Themen', 'In Arbeit'];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: LP.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: labels.asMap().entries.map((e) {
        final active = e.key == _tab;
        return Expanded(child: GestureDetector(
          onTap: () => setState(() => _tab = e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? LP.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(11)),
            child: Text(e.value, textAlign: TextAlign.center,
              style: TextStyle(color: active ? Colors.white : LP.label3,
                fontSize: 13, fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
          ),
        ));
      }).toList()),
    );
  }

  Widget _buildAllTopics() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: _topics.length,
      itemBuilder: (_, i) => _TopicCard(
        topic: _topics[i],
        onLessonTap: (lesson) => _openLesson(context, lesson, _topics[i]),
      ),
    );
  }

  Widget _buildInProgress() {
    final inProgress = _topics.expand((t) {
      return (t['lessons'] as List).where((l) => !(l as Map)['done'] as bool).map((l) => {'topic': t, 'lesson': l});
    }).toList();

    if (inProgress.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.emoji_events_outlined, color: LP.attention, size: 48),
        SizedBox(height: 12),
        Text('Alles erledigt! 🎉', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        Text('Du bist auf dem neuesten Stand', style: TextStyle(color: LP.label3, fontSize: 12)),
      ]));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: inProgress.length,
      itemBuilder: (_, i) {
        final item = inProgress[i];
        final topic = item['topic'] as Map;
        final lesson = item['lesson'] as Map;
        return _LessonRow(
          lesson: lesson, topicColor: topic['color'] as Color,
          onTap: () => _openLesson(context, lesson, topic),
        );
      },
    );
  }

  void _openLesson(BuildContext context, Map lesson, Map topic) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => LessonDetailScreen(lesson: lesson, topic: topic),
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween(begin: const Offset(1, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 280),
    ));
  }
}

// ─── Topic Card ───────────────────────────────────────────────────────────────

class _TopicCard extends StatefulWidget {
  final Map topic;
  final Function(Map) onLessonTap;
  const _TopicCard({required this.topic, required this.onLessonTap});
  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final lessons = topic['lessons'] as List;
    final done = lessons.where((l) => (l as Map)['done'] as bool).length;
    final color = topic['color'] as Color;
    final progress = done / lessons.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: LP.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
        ),
        child: Column(children: [
          // Header
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(13)),
                  child: Icon(topic['icon'] as IconData, color: color, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(topic['title'] as String,
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: progress, minHeight: 5,
                      backgroundColor: LP.surface2,
                      valueColor: AlwaysStoppedAnimation(color))),
                  const SizedBox(height: 4),
                  Text('$done/${lessons.length} Lektionen',
                    style: const TextStyle(color: LP.label3, fontSize: 11)),
                ])),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.expand_more_rounded, color: LP.label3, size: 22)),
              ]),
            ),
          ),
          // Lessons
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Column(children: [
              const Divider(color: LP.divider, height: 1),
              ...lessons.map((l) => _LessonRow(
                lesson: l as Map, topicColor: color,
                onTap: () => widget.onLessonTap(l),
              )),
              const SizedBox(height: 4),
            ]),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ]),
      ),
    );
  }
}

// ─── Lesson Row ───────────────────────────────────────────────────────────────

class _LessonRow extends StatelessWidget {
  final Map lesson; final Color topicColor; final VoidCallback onTap;
  const _LessonRow({required this.lesson, required this.topicColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final done = lesson['done'] as bool;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(
              color: done ? topicColor.withValues(alpha: 0.2) : LP.surface2,
              shape: BoxShape.circle,
              border: Border.all(color: done ? topicColor : LP.divider, width: 1.5)),
            child: done
              ? Icon(Icons.check_rounded, color: topicColor, size: 15)
              : const Icon(Icons.lock_open_outlined, color: LP.label3, size: 14)),
          const SizedBox(width: 12),
          Expanded(child: Text(lesson['title'] as String,
            style: TextStyle(color: done ? LP.label2 : Colors.white,
              fontSize: 13, fontWeight: done ? FontWeight.w400 : FontWeight.w500,
              decoration: done ? TextDecoration.lineThrough : null))),
          Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(color: topicColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(7)),
            child: Text('+${lesson['xp']} XP',
              style: TextStyle(color: topicColor, fontSize: 10, fontWeight: FontWeight.w600))),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right_rounded, color: LP.label3, size: 16),
        ]),
      ),
    );
  }
}

// ─── Lesson Detail ────────────────────────────────────────────────────────────

class LessonDetailScreen extends StatefulWidget {
  final Map lesson; final Map topic;
  const LessonDetailScreen({super.key, required this.lesson, required this.topic});
  @override
  State<LessonDetailScreen> createState() => _LessonDetailState();
}

class _LessonDetailState extends State<LessonDetailScreen> {
  int _phase = 0; // 0=read, 1=quiz, 2=done
  int? _answer;
  bool _showResult = false;
  final _progress = UserProgress();

  static const _quizData = {
    'Was ist die Steuererklärung?': {
      'q': 'Wie oft muss man in Deutschland Steuern erklären?',
      'options': ['Täglich', 'Jährlich', 'Alle 5 Jahre', 'Nie'],
      'correct': 1,
    },
    'Welche Formulare brauche ich?': {
      'q': 'Welches Hauptformular wird für die Steuererklärung benötigt?',
      'options': ['Anlage K', 'Mantelbogen (ESt 1A)', 'Formular Z', 'Steuerbogen B'],
      'correct': 1,
    },
  };

  Map? get _quiz => _quizData[widget.lesson['title']];

  @override
  Widget build(BuildContext context) {
    final color = widget.topic['color'] as Color;
    return Scaffold(
      backgroundColor: LP.bg,
      body: SafeArea(
        child: Column(children: [
          // AppBar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(color: LP.surface, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16))),
              const SizedBox(width: 12),
              Expanded(child: Text(widget.topic['title'] as String,
                style: const TextStyle(color: LP.label2, fontSize: 13))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('+${widget.lesson['xp']} XP',
                  style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700))),
            ]),
          ),
          // Phase indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _PhaseChip('Lektion', _phase == 0, color),
              const SizedBox(width: 8),
              _PhaseChip('Quiz', _phase == 1, color),
              const SizedBox(width: 8),
              _PhaseChip('Fertig', _phase == 2, color),
            ]),
          ),
          const SizedBox(height: 20),
          Expanded(child: _phase == 2 ? _buildDone(color) : _phase == 1 && _quiz != null
            ? _buildQuiz(color) : _buildContent(color)),
        ]),
      ),
    );
  }

  Widget _buildContent(Color color) {
    return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
      Text(widget.lesson['title'] as String,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      const SizedBox(height: 16),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: LP.surface, borderRadius: BorderRadius.circular(18)),
        child: const Text(
          'Die Steuererklärung ist eine jährliche Pflicht für viele Arbeitnehmer in Deutschland. '
          'Sie dient dazu, Ihre tatsächlich gezahlten Steuern mit dem abzurechnen, was Sie schulden oder zurückbekommen.\n\n'
          'In den meisten Fällen erhalten Sie eine Rückerstattung, da Ihr Arbeitgeber oft zu viel Steuer einbehält.',
          style: TextStyle(color: LP.label2, fontSize: 14, height: 1.7)),
      ),
      const SizedBox(height: 16),
      // Key tip
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.25), width: 1)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.tips_and_updates_outlined, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Tipp', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            const Text('Nutzen Sie Elster (elster.de) für die kostenlose Online-Einreichung.',
              style: TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
          ])),
        ])),
      const SizedBox(height: 24),
      GestureDetector(
        onTap: () => setState(() => _phase = _quiz != null ? 1 : 2),
        child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
          child: Center(child: Text(_quiz != null ? 'Weiter zum Quiz →' : 'Abschließen ✓',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)))),
      ),
    ]);
  }

  Widget _buildQuiz(Color color) {
    final quiz = _quiz!;
    final options = quiz['options'] as List;
    final correct = quiz['correct'] as int;
    return ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1)),
        child: Text(quiz['q'] as String,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, height: 1.4))),
      const SizedBox(height: 20),
      ...options.asMap().entries.map((e) {
        final selected = _answer == e.key;
        final isCorrect = e.key == correct;
        Color bg = LP.surface;
        Color border = LP.divider;
        if (_showResult && selected && isCorrect) { bg = LP.success.withValues(alpha: 0.15); border = LP.success; }
        else if (_showResult && selected && !isCorrect) { bg = LP.danger.withValues(alpha: 0.15); border = LP.danger; }
        else if (_showResult && isCorrect) { bg = LP.success.withValues(alpha: 0.1); border = LP.success; }
        else if (selected) { bg = color.withValues(alpha: 0.15); border = color; }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: _showResult ? null : () => setState(() => _answer = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1.5)),
              child: Row(children: [
                Expanded(child: Text(e.value as String,
                  style: TextStyle(color: _showResult && isCorrect ? LP.success : Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w500))),
                if (_showResult && isCorrect) const Icon(Icons.check_circle_rounded, color: LP.success, size: 20),
                if (_showResult && selected && !isCorrect) const Icon(Icons.cancel_rounded, color: LP.danger, size: 20),
              ]),
            ),
          ),
        );
      }),
      const SizedBox(height: 10),
      if (!_showResult && _answer != null)
        GestureDetector(
          onTap: () => setState(() => _showResult = true),
          child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
            child: const Center(child: Text('Antwort prüfen',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))))),
      if (_showResult)
        GestureDetector(
          onTap: () { _progress.completeLesson(); setState(() => _phase = 2); },
          child: Container(padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(color: LP.success, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: LP.success.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
            child: const Center(child: Text('Lektion abschließen ✓',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700))))),
    ]);
  }

  Widget _buildDone(Color color) {
    return Center(child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 100, height: 100,
          decoration: BoxDecoration(color: LP.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: LP.success.withValues(alpha: 0.4), width: 2)),
          child: const Icon(Icons.emoji_events_rounded, color: LP.success, size: 52)),
        const SizedBox(height: 24),
        const Text('Lektion abgeschlossen! 🎉',
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
        const SizedBox(height: 10),
        Text('+${widget.lesson['xp']} XP erhalten',
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Mach so weiter!', style: TextStyle(color: LP.label3, fontSize: 14)),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(color: LP.success, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: LP.success.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
            child: const Text('Zurück zur Übersicht',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)))),
      ]),
    ));
  }
}

class _PhaseChip extends StatelessWidget {
  final String label; final bool active; final Color color;
  const _PhaseChip(this.label, this.active, this.color);
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: active ? color.withValues(alpha: 0.2) : LP.surface,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: active ? color : LP.divider, width: 1)),
    child: Text(label, style: TextStyle(
      color: active ? color : LP.label3,
      fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w400)),
  );
}
