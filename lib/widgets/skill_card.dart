import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class SkillCard extends StatelessWidget {
  final SkillCategory category;
  final VoidCallback? onTap;
  const SkillCard({super.key, required this.category, this.onTap});

  IconData _getIcon(String name) {
    switch (name) {
      case 'camera':    return Icons.camera_alt_outlined;
      case 'safe':      return Icons.folder_outlined;
      case 'joystick':  return Icons.videogame_asset_outlined;
      case 'turntable': return Icons.music_note_outlined;
      case 'upload':    return Icons.cloud_upload_outlined;
      default:          return Icons.widgets_outlined;
    }
  }

  List<Color> _getGradient(String colorName) {
    switch (colorName) {
      case 'purple':    return [const Color(0xFF7C3AED), const Color(0xFFA78BFA)];
      case 'coral':     return [const Color(0xFFE53E3E), const Color(0xFFFC8181)];
      case 'turquoise': return [const Color(0xFF0D9488), const Color(0xFF5EEAD4)];
      case 'yellow':    return [const Color(0xFFD97706), const Color(0xFFFCD34D)];
      default:          return [const Color(0xFF7C3AED), const Color(0xFFA78BFA)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient(category.color);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [gradient[0].withValues(alpha: 0.4), gradient[1].withValues(alpha: 0.2)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1),
              boxShadow: [
                BoxShadow(color: gradient[0].withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Icon(_getIcon(category.icon), color: Colors.white, size: 26),
                ),
                const SizedBox(height: 10),
                Text(category.title,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
