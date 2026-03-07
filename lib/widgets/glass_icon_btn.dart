import 'dart:ui';
import 'package:flutter/material.dart';

class GlassIconBtn extends StatelessWidget {
  final IconData icon;
  const GlassIconBtn({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
