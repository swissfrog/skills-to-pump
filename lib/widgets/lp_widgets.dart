import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';

// ── LP Card ──────────────────────────────────────────────────────────────────

class LPCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;
  final List<BoxShadow>? shadows;

  const LPCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderColor,
    this.radius = 22,
    this.onTap,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? LP.surface,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
        boxShadow: shadows ?? LP.shadow(),
      ),
      child: child,
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: 1.0, duration: const Duration(milliseconds: 120),
          child: card,
        ),
      );
    }
    return card;
  }
}

// ── LP Back Button ───────────────────────────────────────────────────────────

class LPBackBtn extends StatelessWidget {
  const LPBackBtn({super.key});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pop(context),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: LP.surface, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.arrow_back_ios_new_rounded, color: LP.label1, size: 16),
    ),
  );
}

// ── LP Section Label ─────────────────────────────────────────────────────────

class LPLabel extends StatelessWidget {
  final String text;
  final String? trailing;
  const LPLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(text, style: LP.captionBold),
    if (trailing != null) ...[const Spacer(), Text(trailing!, style: LP.captionBold)],
  ]);
}

// ── LP Tab Bar ───────────────────────────────────────────────────────────────

class LPTabBar extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  final Color? activeColor;

  const LPTabBar({
    super.key,
    required this.labels,
    required this.selected,
    required this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? LP.primary;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: LP.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: labels.asMap().entries.map((e) {
        final active = e.key == selected;
        return Expanded(child: GestureDetector(
          onTap: () => onChanged(e.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: active ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              boxShadow: active ? LP.shadow(color) : null,
            ),
            child: Text(e.value, textAlign: TextAlign.center,
              style: TextStyle(
                color: active ? Colors.white : LP.label3,
                fontSize: 13,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              )),
          ),
        ));
      }).toList()),
    );
  }
}

// ── LP Priority Badge ─────────────────────────────────────────────────────────

class LPPriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const LPPriorityBadge({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    final color = LP.priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(priority.label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800)),
    );
  }
}

// ── LP Deadline chip ─────────────────────────────────────────────────────────

class LPDeadline extends StatelessWidget {
  final DateTime deadline;
  const LPDeadline({super.key, required this.deadline});

  @override
  Widget build(BuildContext context) {
    final days = deadline.difference(DateTime.now()).inDays;
    final color = days <= 1 ? LP.danger : days <= 7 ? LP.attention : LP.label3;
    final label = days < 0 ? 'Überfällig!'
        : days == 0 ? 'Heute!'
        : days == 1 ? 'Morgen'
        : '${deadline.day}.${deadline.month}.${deadline.year}';
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.schedule_outlined, color: color, size: 11),
      const SizedBox(width: 4),
      Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ── LP XP Badge ──────────────────────────────────────────────────────────────

class LPXpBadge extends StatelessWidget {
  final int xp;
  final Color? color;
  const LPXpBadge({super.key, required this.xp, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? LP.success;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(7)),
      child: Text('+$xp XP', style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

// ── LP Primary Button ─────────────────────────────────────────────────────────

class LPButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? color;
  final IconData? icon;
  final bool loading;

  const LPButton({
    super.key,
    required this.label,
    this.onTap,
    this.color,
    this.icon,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? LP.primary;
    final enabled = onTap != null && !loading;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 54,
        decoration: BoxDecoration(
          color: enabled ? c : LP.surface2,
          borderRadius: BorderRadius.circular(16),
          boxShadow: enabled ? LP.shadow(c) : null,
        ),
        child: Center(child: loading
          ? const SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
          : Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
              Text(label, style: TextStyle(
                color: enabled ? Colors.white : LP.label3,
                fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
        ),
      ),
    );
  }
}

// ── LP Check Circle ───────────────────────────────────────────────────────────

class LPCheckCircle extends StatelessWidget {
  final bool checked;
  final Color color;
  final VoidCallback? onTap;
  final double size;

  const LPCheckCircle({
    super.key,
    required this.checked,
    required this.color,
    this.onTap,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size, height: size,
        decoration: BoxDecoration(
          color: checked ? color.withValues(alpha: 0.2) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: checked ? color : LP.surface3, width: 1.5),
        ),
        child: checked ? Icon(Icons.check_rounded, color: color, size: size * 0.55) : null,
      ),
    );
  }
}

// ── LP Section Header ─────────────────────────────────────────────────────────

class LPSectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const LPSectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Text(title, style: LP.captionBold),
      if (trailing != null) ...[const Spacer(), trailing!],
    ]),
  );
}

// ── LP Progress Bar ───────────────────────────────────────────────────────────

class LPProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const LPProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(height),
    child: LinearProgressIndicator(
      value: value.clamp(0.0, 1.0),
      minHeight: height,
      backgroundColor: LP.surface2,
      valueColor: AlwaysStoppedAnimation(color),
    ),
  );
}

// ── Navigation page route ────────────────────────────────────────────────────

PageRoute lpRoute(Widget screen, {bool fullscreen = false}) => PageRouteBuilder(
  pageBuilder: (_, __, ___) => screen,
  transitionsBuilder: (_, anim, __, child) => SlideTransition(
    position: Tween(
      begin: fullscreen ? const Offset(0, 1) : const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
    child: child,
  ),
  transitionDuration: const Duration(milliseconds: 260),
);
