import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SkillCard extends StatelessWidget {
  final SkillCategory category;
  final VoidCallback? onTap;

  const SkillCard({
    super.key,
    required this.category,
    this.onTap,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'camera':
        return Icons.camera_alt;
      case 'safe':
        return Icons.lock;
      case 'joystick':
        return Icons.videogame_asset;
      case 'turntable':
        return Icons.album;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.getCategoryColor(category.color);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconData(category.icon),
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              category.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class NavigationRow extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool leftSelected;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;

  const NavigationRow({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    this.leftSelected = true,
    this.onLeftTap,
    this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onLeftTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: leftSelected ? AppTheme.purple.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                leftLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: leftSelected ? AppTheme.purple : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onRightTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: !leftSelected ? AppTheme.purple.withValues(alpha: 0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rightLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: !leftSelected ? AppTheme.purple : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
