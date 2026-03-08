import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/life_models.dart';
import '../services/life_event.dart';
import '../theme/app_theme.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  static const _bg = Color(0xFF0F1115);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(lifeEventsProvider);
    final stats = ref.watch(globalStatsProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Life Events',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded,
                color: Colors.white),
            onPressed: () => _showAddSheet(context, ref),
          ),
          const Gap(8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Summary ────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: _SummaryBanner(stats: stats)
                  .animate()
                  .fadeIn(delay: 60.ms)
                  .slideY(begin: .04),
            ),
          ),

          const SliverToBoxAdapter(child: Gap(24)),

          // ── Event cards ────────────────────────────
          SliverPadding(
            padding:
                const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList.separated(
              itemCount: events.length,
              separatorBuilder: (_, __) => const Gap(14),
              itemBuilder: (ctx, i) => _EventCard(
                event: events[i],
                onTap: () =>
                    ctx.push('/event/${events[i].id}'),
              ).animate().fadeIn(
                delay: Duration(
                    milliseconds: 80 + i * 60),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1F27),
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
          24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF3D4450),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),
            Text(
              'Welches Life Event startest du?',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const Gap(8),
            Text(
              'LifeNav erstellt automatisch die passenden Aufgaben.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const Gap(20),
            // Preset events
            ...[
              ('🏠', 'Umzug'),
              ('💼', 'Jobwechsel'),
              ('🚗', 'Auto kaufen'),
              ('💰', 'Steuererklärung'),
              ('🏥', 'Krankenversicherung'),
            ].map(
              (e) => _PresetRow(
                emoji: e.$1,
                label: e.$2,
                onTap: () => Navigator.pop(context),
              ),
            ),
            const Gap(16),
            const Divider(color: Color(0xFF252B36)),
            const Gap(12),
            TextField(
              controller: ctrl,
              style: GoogleFonts.inter(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Oder eigenes Event eingeben…',
                hintStyle: GoogleFonts.inter(
                    color: const Color(0xFF6B7280)),
                filled: true,
                fillColor: const Color(0xFF21262F),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF252B36)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: Color(0xFF252B36)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: AppTheme.primary, width: 1.5),
                ),
              ),
            ),
            const Gap(16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14)),
                  textStyle: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600),
                ),
                child: const Text('Event starten'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetRow extends StatelessWidget {
  final String emoji;
  final String label;
  final VoidCallback onTap;

  const _PresetRow({
    required this.emoji,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Text(emoji,
                style: const TextStyle(fontSize: 22)),
            const Gap(14),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFF6B7280), size: 14),
          ],
        ),
      ),
    );
  }
}

// ── Summary Banner ────────────────────────────────────────
class _SummaryBanner extends StatelessWidget {
  final ({int done, int total, int minutesSaved}) stats;
  const _SummaryBanner({required this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = stats.total == 0
        ? 0.0
        : stats.done / stats.total;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(.18),
            AppTheme.primary.withOpacity(.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppTheme.primary.withOpacity(.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded,
                  color: AppTheme.primary, size: 20),
              const Gap(8),
              Expanded(
                child: Text(
                  '${stats.done} von ${stats.total} Aufgaben erledigt',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '${(pct * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const Gap(12),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: const Color(0xFF252B36),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primary),
            ),
          ),
          const Gap(10),
          Text(
            '~${stats.minutesSaved} Minuten Recherche gespart',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Event Card ────────────────────────────────────────────
class _EventCard extends StatelessWidget {
  final LifeEvent event;
  final VoidCallback onTap;

  const _EventCard({
    required this.event,
    required this.onTap,
  });

  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: event.isCompleted
                  ? AppTheme.green.withOpacity(.25)
                  : const Color(0xFF252B36),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(event.icon,
                      color: event.color, size: 22),
                ),
                const Gap(14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        event.description,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color:
                              const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (event.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          AppTheme.green.withOpacity(.12),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Text(
                      '✓ Fertig',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFF6B7280),
                    size: 20),
              ],
            ),

            const Gap(16),

            // Task chips (first 3 tasks)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.tasks.take(3).map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: t.completed
                        ? AppTheme.green.withOpacity(.10)
                        : const Color(0xFF252B36),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: t.completed
                          ? AppTheme.green.withOpacity(.2)
                          : const Color(0xFF3D4450),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t.completed
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: t.completed
                            ? AppTheme.green
                            : const Color(0xFF6B7280),
                        size: 12,
                      ),
                      const Gap(5),
                      Text(
                        t.title,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: t.completed
                              ? AppTheme.green
                              : const Color(0xFFD1D5DB),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            if (event.totalCount > 3) ...[
              const Gap(8),
              Text(
                '+${event.totalCount - 3} weitere Aufgaben',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],

            const Gap(14),

            // Progress
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: event.progress,
                      minHeight: 6,
                      backgroundColor:
                          const Color(0xFF252B36),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(
                              event.color),
                    ),
                  ),
                ),
                const Gap(12),
                Text(
                  '${event.doneCount}/${event.totalCount}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: event.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            if (event.minutesLeft > 0) ...[
              const Gap(8),
              Text(
                'Noch ~${event.minutesLeft} Min bis Abschluss',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
