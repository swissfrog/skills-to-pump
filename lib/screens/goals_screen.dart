import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

// ──────────────────────────────────────────────────────────
// GoalsScreen (Simple placeholder)
// ──────────────────────────────────────────────────────────
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const _bg = Color(0xFF0F1115);
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = [
      (id: 'job', title: 'Neue Stelle', icon: Icons.work_rounded, color: AppTheme.primary, progress: 0.57),
      (id: 'apartment', title: 'Wohnung mieten', icon: Icons.apartment_rounded, color: AppTheme.secondary, progress: 0.38),
      (id: 'bank', title: 'Konto eröffnen', icon: Icons.account_balance_rounded, color: AppTheme.amber, progress: 1.0),
      (id: 'insurance', title: 'Krankenversicherung', icon: Icons.health_and_safety_rounded, color: AppTheme.green, progress: 0.6),
    ];

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Life Events', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [IconButton(icon: const Icon(Icons.add_rounded, color: Colors.white), onPressed: () {})],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
        physics: const BouncingScrollPhysics(),
        itemCount: events.length,
        separatorBuilder: (_, __) => const Gap(14),
        itemBuilder: (ctx, i) {
          final e = events[i];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF252B36), width: 1)),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: e.color.withOpacity(.12), borderRadius: BorderRadius.circular(14)), child: Icon(e.icon, color: e.color, size: 22)),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                      const Gap(2),
                      Text('${(e.progress * 100).round()}% abgeschlossen', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
                    ],
                  ),
                ),
                Text('${(e.progress * 100).round()}%', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: e.color)),
              ],
            ),
          );
        },
      ),
    );
  }
}
