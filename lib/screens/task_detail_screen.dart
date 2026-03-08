import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';
import '../services/premium_service.dart';
import '../widgets/partner_widgets.dart';
import 'event_completion_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final LifeTask task;
  final void Function(LifeEvent? completedEvent)? onCompletedEvent;

  const TaskDetailScreen({super.key, required this.task, this.onCompletedEvent});

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();
    final premium = PremiumService();
    final isDone = task.status == TaskStatus.completed;

    return Scaffold(
      backgroundColor: LN.bg,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text('Details', style: LN.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Badge(
              text: isDone ? 'COMPLETED' : 'PENDING',
              color: isDone ? LN.success : LN.highlight,
            ),
            const SizedBox(height: 12),
            Text(task.title, style: LN.h1),
            const SizedBox(height: 24),

            _SectionHeader(title: 'What to do'),
            Text(task.explanation, style: LN.body),
            const SizedBox(height: 32),

            if (task.requiredDocs.isNotEmpty) ...[
              _SectionHeader(title: 'Required Documents'),
              ...task.requiredDocs.map((doc) => _DocItem(title: doc, isPremium: premium.isPremium)),
              if (!premium.isPremium)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('Get Premium to scan and store documents.', style: TextStyle(color: LN.highlight, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              const SizedBox(height: 32),
            ],

            if (task.steps.isNotEmpty) ...[
              _SectionHeader(title: 'Step-by-Step'),
              ...task.steps.asMap().entries.map((e) => _StepItem(index: e.key + 1, text: e.value)),
              const SizedBox(height: 32),
            ],

            // Partner Integration Placeholder
            if (task.id.contains('move_reg')) const PartnerIntegrationCard(category: 'Registration Service'),
            if (task.id.contains('move_internet')) const PartnerIntegrationCard(category: 'Internet Providers'),
            if (task.id.contains('car_1')) const PartnerIntegrationCard(category: 'Insurance Brokers'),

            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  if (isDone) {
                    store.updateTaskStatus(task.id, TaskStatus.open);
                    Navigator.pop(context);
                  } else {
                    final completed = store.updateTaskStatus(task.id, TaskStatus.completed);
                    if (onCompletedEvent != null) {
                      onCompletedEvent!(completed);
                    } else {
                      final navigator = Navigator.of(context);
                      navigator.pop();
                      if (completed != null) {
                        navigator.push(
                          MaterialPageRoute(
                            builder: (_) => EventCompletionScreen(event: completed),
                          ),
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDone ? LN.surface2 : LN.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: LN.r16),
                  elevation: 0,
                ),
                child: Text(
                  isDone ? 'Mark as Not Done' : 'Complete Task',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(title.toUpperCase(), style: LN.label),
  );
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
    child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
  );
}

class _DocItem extends StatelessWidget {
  final String title; final bool isPremium;
  const _DocItem({required this.title, required this.isPremium});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: LN.surface, borderRadius: LN.r16),
    child: Row(children: [
      const Icon(Icons.description_outlined, color: LN.primary, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(title, style: LN.bodySmall.copyWith(color: LN.label1))),
      if (isPremium) const Icon(Icons.add_a_photo_outlined, size: 18, color: LN.primary),
    ]),
  );
}

class _StepItem extends StatelessWidget {
  final int index; final String text;
  const _StepItem({required this.index, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 12, backgroundColor: LN.surface3, child: Text('$index', style: const TextStyle(fontSize: 12, color: Colors.white))),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: LN.body)),
      ],
    ),
  );
}
