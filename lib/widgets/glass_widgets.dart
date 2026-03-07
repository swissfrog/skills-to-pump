import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── Glass Container ──────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? tint;
  final double borderRadius;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20,
    this.tint,
    this.borderRadius = 20,
    this.padding,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint ?? Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
    if (onTap != null) return GestureDetector(onTap: onTap, child: card);
    return card;
  }
}

// ─── Glass Icon Button ────────────────────────────────────────────────────────

class GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  const GlassIconBtn({super.key, required this.icon, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
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
            child: Icon(icon, color: color ?? Colors.white, size: 18),
          ),
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class GlassAppBar extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final List<Widget>? actions;

  const GlassAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      child: Row(
        children: [
          if (showBack) ...[
            GlassIconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

// ─── Screen Background ────────────────────────────────────────────────────────

class GlassBackground extends StatelessWidget {
  final Widget child;
  final List<_GlowSpec>? glows;

  const GlassBackground({super.key, required this.child, this.glows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.bgTop, AppTheme.bgMid, AppTheme.bgBottom],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(children: [
        if (glows != null)
          for (final g in glows!) _AmbientGlow(spec: g),
        child,
      ]),
    );
  }
}

class _GlowSpec {
  final Color color;
  final double? top, bottom, left, right, size;
  const _GlowSpec({required this.color, this.top, this.bottom, this.left, this.right, this.size = 280});
}

class _AmbientGlow extends StatelessWidget {
  final _GlowSpec spec;
  const _AmbientGlow({required this.spec});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: spec.top, bottom: spec.bottom, left: spec.left, right: spec.right,
      child: IgnorePointer(
        child: Container(
          width: spec.size, height: spec.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [spec.color.withValues(alpha: 0.14), Colors.transparent]),
          ),
        ),
      ),
    );
  }
}

// Convenience factory
class Glows {
  static List<_GlowSpec> homeGlows = [
    _GlowSpec(color: AppTheme.purple, top: -100, right: -80, size: 320),
    _GlowSpec(color: AppTheme.turquoise, bottom: 80, left: -100, size: 260),
  ];
}

// ─── Tag / Badge ──────────────────────────────────────────────────────────────

class GlassBadge extends StatelessWidget {
  final String label;
  final Color color;
  const GlassBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Segmented Tabs ───────────────────────────────────────────────────────────

class GlassTabs extends StatelessWidget {
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChanged;
  const GlassTabs({super.key, required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
          ),
          child: Row(children: List.generate(labels.length, (i) {
            final active = i == selected;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.purple.withValues(alpha: 0.3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Text(labels[i], textAlign: TextAlign.center,
                    style: TextStyle(
                      color: active ? Colors.white : AppTheme.textMuted,
                      fontSize: 12, fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    )),
                ),
              ),
            );
          })),
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? trailing;
  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12,
            fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const Spacer(),
        if (trailing != null) Text(trailing!, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
      ]),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class GlassActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const GlassActionBtn({super.key, required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
