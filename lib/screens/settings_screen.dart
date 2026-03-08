import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

// ──────────────────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────────────────
class _SettingsState {
  final bool notifications;
  final bool biometrics;
  final bool autoAssign;
  final bool analytics;
  final String language;

  const _SettingsState({
    this.notifications = true,
    this.biometrics = false,
    this.autoAssign = true,
    this.analytics = false,
    this.language = 'Deutsch',
  });

  _SettingsState copyWith({
    bool? notifications,
    bool? biometrics,
    bool? autoAssign,
    bool? analytics,
    String? language,
  }) =>
      _SettingsState(
        notifications: notifications ?? this.notifications,
        biometrics: biometrics ?? this.biometrics,
        autoAssign: autoAssign ?? this.autoAssign,
        analytics: analytics ?? this.analytics,
        language: language ?? this.language,
      );
}

class _SettingsNotifier extends StateNotifier<_SettingsState> {
  _SettingsNotifier() : super(const _SettingsState());

  void toggle(String key) {
    state = switch (key) {
      'notifications' => state.copyWith(notifications: !state.notifications),
      'biometrics' => state.copyWith(biometrics: !state.biometrics),
      'autoAssign' => state.copyWith(autoAssign: !state.autoAssign),
      'analytics' => state.copyWith(analytics: !state.analytics),
      _ => state,
    };
  }

  void setLanguage(String lang) => state = state.copyWith(language: lang);
}

final _settingsProvider = StateNotifierProvider<_SettingsNotifier, _SettingsState>((_) => _SettingsNotifier());

// ──────────────────────────────────────────────────────────
// SettingsScreen
// ──────────────────────────────────────────────────────────
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _bg = Color(0xFF0F1115);
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_settingsProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Einstellungen', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        physics: const BouncingScrollPhysics(),
        children: [
          _ProfileCard().animate().fadeIn(delay: 60.ms).slideY(begin: .04),
          const Gap(28),
          _SectionLabel(label: 'Benachrichtigungen').animate().fadeIn(delay: 100.ms),
          const Gap(12),
          _SettingsGroup(
            children: [
              _SwitchTile(icon: Icons.notifications_rounded, iconColor: AppTheme.primary, title: 'Push-Benachrichtigungen', subtitle: 'Erinnerungen für ausstehende Docs', value: s.notifications, onChanged: (_) => ref.read(_settingsProvider.notifier).toggle('notifications')),
            ],
          ).animate().fadeIn(delay: 120.ms),
          const Gap(20),
          _SectionLabel(label: 'Sicherheit').animate().fadeIn(delay: 140.ms),
          const Gap(12),
          _SettingsGroup(
            children: [
              _SwitchTile(icon: Icons.fingerprint_rounded, iconColor: AppTheme.green, title: 'Biometrischer Login', subtitle: 'Face ID / Fingerabdruck', value: s.biometrics, onChanged: (_) => ref.read(_settingsProvider.notifier).toggle('biometrics')),
              _DividerLine(),
              _NavTile(icon: Icons.lock_outline_rounded, iconColor: AppTheme.amber, title: 'PIN ändern', onTap: () {}),
              _DividerLine(),
              _NavTile(icon: Icons.shield_outlined, iconColor: AppTheme.secondary, title: 'Datenschutz & Daten', onTap: () {}),
            ],
          ).animate().fadeIn(delay: 160.ms),
          const Gap(20),
          _SectionLabel(label: 'OCR & Automatisierung').animate().fadeIn(delay: 180.ms),
          const Gap(12),
          _SettingsGroup(
            children: [
              _SwitchTile(icon: Icons.auto_awesome_rounded, iconColor: AppTheme.primary, title: 'Auto-Zuweisung', subtitle: 'Docs automatisch Life Events zuweisen', value: s.autoAssign, onChanged: (_) => ref.read(_settingsProvider.notifier).toggle('autoAssign')),
              _DividerLine(),
              _NavTile(icon: Icons.language_rounded, iconColor: AppTheme.secondary, title: 'OCR Sprache', trailing: Text(s.language, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))), onTap: () => _showLanguagePicker(context, ref)),
              _DividerLine(),
              _NavTile(icon: Icons.storage_rounded, iconColor: AppTheme.amber, title: 'Lokaler Speicher', trailing: Text('128 MB frei', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))), onTap: () {}),
            ],
          ).animate().fadeIn(delay: 200.ms),
          const Gap(20),
          _SectionLabel(label: 'Diagnose').animate().fadeIn(delay: 220.ms),
          const Gap(12),
          _SettingsGroup(
            children: [
              _SwitchTile(icon: Icons.analytics_outlined, iconColor: AppTheme.tertiary, title: 'Anonyme Nutzungsstatistik', subtitle: 'Hilft uns, die App zu verbessern', value: s.analytics, onChanged: (_) => ref.read(_settingsProvider.notifier).toggle('analytics')),
              _DividerLine(),
              _NavTile(icon: Icons.bug_report_outlined, iconColor: const Color(0xFF9CA3AF), title: 'Fehler melden', onTap: () {}),
            ],
          ).animate().fadeIn(delay: 240.ms),
          const Gap(20),
          _SectionLabel(label: 'App').animate().fadeIn(delay: 260.ms),
          const Gap(12),
          _SettingsGroup(
            children: [
              _NavTile(icon: Icons.info_outline_rounded, iconColor: AppTheme.primary, title: 'Version', trailing: Text('1.0.0 (1)', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))), onTap: () {}),
              _DividerLine(),
              _NavTile(icon: Icons.description_outlined, iconColor: const Color(0xFF9CA3AF), title: 'Nutzungsbedingungen', onTap: () {}),
              _DividerLine(),
              _NavTile(icon: Icons.privacy_tip_outlined, iconColor: const Color(0xFF9CA3AF), title: 'Datenschutzerklärung', onTap: () {}),
            ],
          ).animate().fadeIn(delay: 280.ms),
          const Gap(20),
          _SettingsGroup(
            children: [
              _NavTile(icon: Icons.logout_rounded, iconColor: AppTheme.tertiary, title: 'Abmelden', titleColor: AppTheme.tertiary, onTap: () => _showLogoutDialog(context)),
              _DividerLine(),
              _NavTile(icon: Icons.delete_forever_rounded, iconColor: AppTheme.tertiary, title: 'Alle Daten löschen', titleColor: AppTheme.tertiary, onTap: () => _showDeleteDialog(context)),
            ],
          ).animate().fadeIn(delay: 300.ms),
          const Gap(32),
          Center(child: Text('LifeNav · Made with ❤️ in Flutter', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF3D4450)))),
        ],
      ),
    );
  }

  void _showLanguagePicker(BuildContext ctx, WidgetRef ref) {
    const langs = ['Deutsch', 'English', 'Français', 'Español', 'Italiano'];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1B1F27),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OCR Sprache', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
            const Gap(16),
            ...langs.map((l) => ListTile(
                  title: Text(l, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)),
                  trailing: Consumer(builder: (_, ref, __) => ref.watch(_settingsProvider).language == l ? const Icon(Icons.check_rounded, color: AppTheme.primary) : const SizedBox.shrink()),
                  onTap: () {
                    ref.read(_settingsProvider.notifier).setLanguage(l);
                    Navigator.pop(ctx);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                )),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1F27),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Abmelden?', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text('Du wirst aus deinem LifeNav-Konto abgemeldet.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Abbrechen', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF)))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.tertiary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Abmelden', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1B1F27),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Alle Daten löschen?', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        content: Text('Diese Aktion kann nicht rückgängig gemacht werden. Alle Scans, Events und Journal-Einträge werden gelöscht.', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF9CA3AF))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Abbrechen', style: GoogleFonts.inter(color: const Color(0xFF9CA3AF)))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.tertiary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text('Löschen', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Reusable Settings Widgets
// ──────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF252B36), width: 1)),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF0060CC)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.person_rounded, color: Colors.white, size: 28),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Max Mustermann', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const Gap(3),
                Text('max@lifenav.app', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(8)),
            child: Text('Pro', style: GoogleFonts.inter(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label.toUpperCase(), style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF6B7280), letterSpacing: 1.0));
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return Container(decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF252B36), width: 1)), child: Column(children: children));
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final void Function(bool) onChanged;

  const _SwitchTile({required this.icon, required this.iconColor, required this.title, this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                if (subtitle != null) ...[const Gap(2), Text(subtitle!, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280)))],
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primary, trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppTheme.primary.withOpacity(.3) : const Color(0xFF252B36))),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback onTap;

  const _NavTile({required this.icon, required this.iconColor, required this.title, this.titleColor, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withOpacity(.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
            const Gap(14),
            Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: titleColor ?? Colors.white))),
            if (trailing != null) ...[const Gap(8), trailing!] else const Icon(Icons.chevron_right_rounded, color: Color(0xFF3D4450), size: 18),
          ],
        ),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(color: Color(0xFF252B36), height: 1, thickness: 1, indent: 52);
  }
}
