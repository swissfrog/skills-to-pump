import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';
import '../widgets/lp_widgets.dart';
import 'task_detail_screen.dart';

class EventCreatorScreen extends StatefulWidget {
  const EventCreatorScreen({super.key});
  @override
  State<EventCreatorScreen> createState() => _EventCreatorScreenState();
}

class _EventCreatorScreenState extends State<EventCreatorScreen> {
  LifeEventType? _selected;
  bool _loading = false;
  final _store = LifeStore();

  static const _all = [
    LifeEventType.move, LifeEventType.newJob, LifeEventType.buyCar,
    LifeEventType.taxYear, LifeEventType.study, LifeEventType.family,
  ];

  Future<void> _start() async {
    if (_selected == null) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    final ev = _store.startEvent(_selected!);
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pushReplacement(context, lpRoute(EventDetailScreen(event: ev)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LP.bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Row(children: [
              const LPBackBtn(),
              const SizedBox(width: 14),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Life Event starten', style: TextStyle(color: LP.label1, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                Text('Aufgaben werden automatisch generiert', style: TextStyle(color: LP.label3, fontSize: 12)),
              ])),
            ]),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.95),
              itemCount: _all.length,
              itemBuilder: (_, i) {
                final ev = _all[i];
                final sel = _selected == ev;
                final color = LP.eventColor(ev);
                final alreadyActive = _store.hasEvent(ev);
                return GestureDetector(
                  onTap: () => setState(() => _selected = sel ? null : ev),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: sel ? color.withValues(alpha: 0.14) : LP.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: sel ? color : LP.divider, width: sel ? 1.5 : 1),
                      boxShadow: sel ? LP.shadow(color) : LP.shadow(),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(ev.emoji, style: const TextStyle(fontSize: 28)),
                        if (alreadyActive) ...[
                          const SizedBox(width: 4),
                          Container(width: 8, height: 8,
                            decoration: BoxDecoration(color: LP.success, shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: LP.success.withValues(alpha: 0.5), blurRadius: 4)])),
                        ],
                      ]),
                      const Spacer(),
                      Text(ev.label, style: TextStyle(
                        color: sel ? color : LP.label1,
                        fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                      const SizedBox(height: 5),
                      Text(ev.description, style: const TextStyle(color: LP.label3, fontSize: 10, height: 1.5),
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (sel) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.check_circle_rounded, color: color, size: 13),
                          const SizedBox(width: 4),
                          Text('Ausgewählt', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800)),
                        ]),
                      ],
                    ]),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: LPButton(
              label: _selected == null ? 'Event auswählen'
                  : '${_selected!.label} starten  →',
              color: _selected != null ? LP.primary : LP.surface2,
              loading: _loading,
              onTap: _selected != null ? _start : null,
            ),
          ),
        ]),
      ),
    );
  }
}

// ─── Event Detail ─────────────────────────────────────────────────────────────

class EventDetailScreen extends StatefulWidget {
  final LifeEvent event;
  const EventDetailScreen({super.key, required this.event});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _store = LifeStore();
  late LifeEvent _event;
  @override
  void initState() { super.initState(); _event = widget.event; _store.addListener(_r); }
  void _r() {
    final updated = _store.events.firstWhere((e) => e.id == _event.id, orElse: () => _event);
    if (mounted) setState(() => _event = updated);
  }
  @override
  void dispose() { _store.removeListener(_r); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final color = LP.eventColor(_event.type);
    return Scaffold(
      backgroundColor: LP.bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
            child: Row(children: [
              const LPBackBtn(),
              const SizedBox(width: 10),
              Text(_event.type.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_event.type.label, style: const TextStyle(color: LP.label1, fontSize: 19, fontWeight: FontWeight.w900)),
                Text('${_event.completedCount}/${_event.tasks.length} Aufgaben',
                  style: const TextStyle(color: LP.label3, fontSize: 11)),
              ])),
              Text('${(_event.progress * 100).round()}%',
                style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: LPProgressBar(value: _event.progress, color: color, height: 6)),
          const SizedBox(height: 14),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
            itemCount: _event.tasks.length,
            itemBuilder: (_, i) {
              final task = _event.tasks[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _CheckItem(
                  task: task, index: i, color: color,
                  onTap: () => Navigator.push(context, lpRoute(TaskDetailScreen(task: task))),
                  onToggle: () => _store.updateTaskStatus(task.id,
                    task.status.isDone ? TaskStatus.open : TaskStatus.completed),
                ));
            },
          )),
        ]),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final LifeTask task; final int index; final Color color;
  final VoidCallback onTap, onToggle;
  const _CheckItem({required this.task, required this.index, required this.color,
    required this.onTap, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final done = task.status.isDone;
    final pc = LP.priorityColor(task.priority);
    return GestureDetector(
      onTap: onTap,
      child: LPCard(
        color: done ? LP.surface.withValues(alpha: 0.4) : LP.surface,
        borderColor: done ? null : color.withValues(alpha: 0.15),
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          LPCheckCircle(checked: done, color: color, onTap: onToggle),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(task.title, style: TextStyle(
              color: done ? LP.label3 : LP.label1, fontSize: 13, fontWeight: FontWeight.w700,
              decoration: done ? TextDecoration.lineThrough : null)),
            Text(task.description, style: const TextStyle(color: LP.label3, fontSize: 11),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (!done) LPPriorityBadge(priority: task.priority),
            const SizedBox(height: 4),
            LPXpBadge(xp: task.xpReward, color: done ? LP.label3 : color),
          ]),
        ]),
      ),
    );
  }
}
