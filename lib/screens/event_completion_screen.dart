import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/user_progress.dart';

/// Shown when user completes all tasks in an event. Clean card with progress animation.
class EventCompletionScreen extends StatefulWidget {
  final LifeEvent event;

  const EventCompletionScreen({super.key, required this.event});

  @override
  State<EventCompletionScreen> createState() => _EventCompletionScreenState();
}

class _EventCompletionScreenState extends State<EventCompletionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTimeSaved(int minutes) {
    if (minutes < 60) return '$minutes Minuten';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 1 && m == 0) return '1 Stunde';
    if (m == 0) return '$h Stunden';
    return '$h Std. $m Min.';
  }

  String _shareMessageForEvent(LifeEventType type) {
    const messages = {
      LifeEventType.move: 'I organized my move with LifeNav.',
      LifeEventType.newJob: 'I organized my new job with LifeNav.',
      LifeEventType.buyCar: 'I organized my car purchase with LifeNav.',
      LifeEventType.taxYear: 'I organized my tax year with LifeNav.',
      LifeEventType.study: 'I organized my studies with LifeNav.',
      LifeEventType.family: 'I organized my family matters with LifeNav.',
    };
    return messages[type] ?? 'I organized my life event with LifeNav.';
  }

  Future<void> _shareAchievement() async {
    await Share.share(
      _shareMessageForEvent(widget.event.type),
      subject: 'LifeNav Achievement',
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = LN.colorForEvent(widget.event.type);
    final minutesSaved = widget.event.timeSavedFromCompletedTasks;
    final progress = UserProgress();

    return Scaffold(
      backgroundColor: LN.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LN.surface,
                      border: Border.all(
                        color: color.withValues(alpha: 0.5),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(
                            value: _progressAnimation.value,
                            strokeWidth: 6,
                            backgroundColor: LN.surface2,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                        Icon(
                          Icons.check_circle,
                          size: 48,
                          color: color,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Event Completed',
                style: LN.h2.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You finished the "${widget.event.type.label}" event.',
                style: LN.body.copyWith(color: LN.label2, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: LN.surface,
                  borderRadius: LN.r24,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                  boxShadow: LN.shadow(color),
                ),
                child: Column(
                  children: [
                    Text(
                      'Du hast ${_formatTimeSaved(minutesSaved)} Recherche gespart.',
                      style: LN.body.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.event.type.label,
                      style: LN.bodySmall.copyWith(color: color, fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    ListenableBuilder(
                      listenable: progress,
                      builder: (_, __) => Text(
                        'Gesamt gespart: ${progress.totalTimeSavedFormatted}',
                        style: LN.bodySmall.copyWith(color: LN.label2, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _shareAchievement,
                  icon: const Icon(Icons.share, size: 22),
                  label: const Text('Share Achievement', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: LN.r16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: LN.r16,
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Weiter', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
