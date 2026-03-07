import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class StageProgress extends StatelessWidget {
  final List<Stage> stages;
  final Function(int)? onStageTap;

  const StageProgress({
    super.key,
    required this.stages,
    this.onStageTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stages.length,
        itemBuilder: (context, index) {
          final stage = stages[index];
          return GestureDetector(
            onTap: () => onStageTap?.call(stage.number),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: stage.isCurrent 
                    ? AppTheme.yellow 
                    : stage.isCompleted 
                        ? AppTheme.turquoise 
                        : AppTheme.darkCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: stage.isCurrent 
                      ? AppTheme.yellow 
                      : stage.isCompleted 
                          ? AppTheme.turquoise 
                          : AppTheme.textSecondary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                '${stage.number} ${stage.label}',
                style: TextStyle(
                  color: stage.isCurrent || stage.isCompleted 
                      ? Colors.black 
                      : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!lesson.isUnlocked) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.darkCardLocked,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.lock,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    lesson.subtitle,
                    style: TextStyle(
                      color: AppTheme.textSecondary.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Recent',
                    style: TextStyle(
                      color: AppTheme.purple,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                if (lesson.isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: AppTheme.turquoise,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lesson.title,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lesson.subtitle,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoreButton extends StatelessWidget {
  final VoidCallback? onTap;

  const MoreButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'More',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.keyboard_arrow_down,
              color: AppTheme.textPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
