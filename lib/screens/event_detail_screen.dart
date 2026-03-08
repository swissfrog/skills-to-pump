import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';
import 'task_detail_screen.dart';
import 'event_completion_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final LifeEvent event;
  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();
    final color = LN.colorForEvent(event.type);

    return Scaffold(
      backgroundColor: LN.bg,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            Icon(LN.iconForEvent(event.type), color: color, size: 24),
            const SizedBox(width: 12),
            Text(event.type.label, style: LN.h3),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final ev = store.events.firstWhere(
            (e) => e.id == event.id,
            orElse: () => event,
          );
          final progress = ev.progress;
          final completedCount = ev.completedCount;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProgressCard(
                  progress: progress,
                  completedCount: completedCount,
                  totalCount: ev.tasks.length,
                  color: color,
                ),
                const SizedBox(height: 24),
                Text('AUFGABEN', style: LN.label),
                const SizedBox(height: 12),
                ...ev.tasks.map((task) => _TaskTile(
                  task: task,
                  color: color,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskDetailScreen(
                        task: task,
                        onCompletedEvent: (completedEvent) {
                          Navigator.pop(context);
                          if (completedEvent != null && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventCompletionScreen(event: completedEvent),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  onDone: () {
                    final completed = store.updateTaskStatus(task.id, TaskStatus.completed);
                    if (completed != null && context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EventCompletionScreen(event: completed),
                        ),
                      );
                    }
                  },
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final double progress;
  final int completedCount;
  final int totalCount;
  final Color color;

  const _ProgressCard({
    required this.progress,
    required this.completedCount,
    required this.totalCount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: LN.surface,
        borderRadius: LN.r24,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$completedCount / $totalCount erledigt', style: LN.body.copyWith(fontWeight: FontWeight.w600)),
              Text('${(progress * 100).toInt()}%', style: LN.h3.copyWith(color: color)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: LN.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  final LifeTask task;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onDone;

  const _TaskTile({
    required this.task,
    required this.color,
    required this.onTap,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.status.isDone;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: LN.surface,
          borderRadius: LN.r16,
          border: isDone ? Border.all(color: LN.success.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onDone,
              icon: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_off,
                color: isDone ? LN.success : color,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: LN.body.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? LN.label3 : LN.label1,
                    ),
                  ),
                  if (task.requiredDocs.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${task.requiredDocs.length} Dokumente',
                        style: LN.bodySmall.copyWith(color: LN.label3, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: LN.label3),
          ],
        ),
      ),
    );
  }
}
