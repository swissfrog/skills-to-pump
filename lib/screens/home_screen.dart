import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/life_models.dart';
import '../services/life_event.dart';
import '../theme/app_theme.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _bg = Color(0xFF0F1115);
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextStep = ref.watch(nextImportantStepProvider);
    final stats = ref.watch(globalStatsProvider);
    final events = ref.watch(lifeEventsProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _AppBar(),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Gap(28),

                // ── Next Important Step ──────────────
                if (nextStep != null)
                  _NextStepCard(
                    event: nextStep.event,
                    task: nextStep.task,
                  )
                      .animate()
                      .fadeIn(delay: 80.ms)
                      .slideY(begin: .04)
                else
                  _AllDoneCard()
                      .animate()
                      .fadeIn(delay: 80.ms),

                const Gap(28),

                // ── Stats Row ────────────────────────
                _StatsRow(stats: stats)
                    .animate()
                    .fadeIn(delay: 140.ms),

                const Gap(28),

                // ── Active Events ────────────────────
                _SectionHeader(
                  title: 'Aktive Life Events',
                  action: 'Alle',
                  onTap: () => context.go('/goals'),
                ).animate().fadeIn(delay: 180.ms),

                const Gap(14),

                ...events.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _EventRow(
                          event: e.value,
                          onTap: () => context.push(
                              '/event/${e.value.id}'),
                        )
                            .animate()
                            .fadeIn(
                              delay: Duration(
                                  milliseconds: 200 + e.key * 60),
                            ),
                      ),
                    ),

                const Gap(28),

                // ── Quick Actions ────────────────────
                _SectionHeader(title: 'Schnellzugriff')
                    .animate()
                    .fadeIn(delay: 320.ms),

                const Gap(14),

                _QuickActionsRow()
                    .animate()
                    .fadeIn(delay: 340.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sliver AppBar ─────────────────────────────────────────
class _AppBar extends StatelessWidget {
  static const _bg = Color(0xFF0F1115);

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 11) return 'Guten Morgen 👋';
    if (h < 17) return 'Guten Tag 👋';
    return 'Guten Abend 👋';
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 120,
      floating: true,
      snap: true,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 16,
            20,
            16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'LifeNav',
                      style: GoogleFonts.inter(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -.5,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/settings'),
                child: Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.primary,
                        Color(0xFF0060CC),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Next Important Step Card ──────────────────────────────
class _NextStepCard extends StatelessWidget {
  final LifeEvent event;
  final LifeTask task;

  const _NextStepCard({required this.event, required this.task});

  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              event.color.withOpacity(.18),
              event.color.withOpacity(.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: event.color.withOpacity(.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.bolt_rounded,
                          color: event.color, size: 14),
                      const Gap(4),
                      Text(
                        'Nächster Schritt',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: event.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: event.color.withOpacity(.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(event.icon,
                      color: event.color, size: 18),
                ),
              ],
            ),
            const Gap(16),
            Text(
              task.title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -.3,
              ),
            ),
            const Gap(6),
            Text(
              task.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF9CA3AF),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Gap(16),
            Row(
              children: [
                // Docs needed indicator
                _InfoChip(
                  icon: Icons.description_outlined,
                  label: '${task.docs.length} Dokumente',
                  color: event.color,
                ),
                const Gap(10),
                // Time estimate
                _InfoChip(
                  icon: Icons.schedule_rounded,
                  label: '~${task.estimatedMinutes} Min',
                  color: event.color,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: event.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Starten →',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const Gap(16),
            // Event progress
            Row(
              children: [
                Text(
                  event.title,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const Spacer(),
                Text(
                  '${event.doneCount}/${event.totalCount} Aufgaben',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
            const Gap(8),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: event.progress,
                minHeight: 5,
                backgroundColor: const Color(0xFF252B36),
                valueColor:
                    AlwaysStoppedAnimation<Color>(event.color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const Gap(5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── All Done Card ─────────────────────────────────────────
class _AllDoneCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.green.withOpacity(.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppTheme.green.withOpacity(.25)),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration_rounded,
              color: AppTheme.green, size: 40),
          const Gap(12),
          Text(
            'Alles erledigt! 🎉',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Gap(6),
          Text(
            'Alle Aufgaben sind abgeschlossen.\nFüge ein neues Life Event hinzu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const Gap(16),
          FilledButton.icon(
            onPressed: () => context.go('/goals'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Neues Event'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              textStyle: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats Row ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final ({int done, int total, int minutesSaved}) stats;
  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final pct = stats.total == 0
        ? 0.0
        : stats.done / stats.total;

    return Row(
      children: [
        _StatCard(
          value: '${stats.done}',
          label: 'Erledigt',
          icon: Icons.check_circle_rounded,
          color: AppTheme.green,
        ),
        const Gap(12),
        _StatCard(
          value: '${stats.total - stats.done}',
          label: 'Offen',
          icon: Icons.pending_rounded,
          color: AppTheme.amber,
        ),
        const Gap(12),
        _StatCard(
          value: '${stats.minutesSaved} Min',
          label: 'Zeit gespart',
          icon: Icons.timer_rounded,
          color: AppTheme.primary,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF252B36)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const Gap(10),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Event Row ─────────────────────────────────────────────
class _EventRow extends StatelessWidget {
  final LifeEvent event;
  final VoidCallback onTap;

  const _EventRow({required this.event, required this.onTap});

  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF252B36)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: event.color.withOpacity(.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(event.icon,
                  color: event.color, size: 22),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    event.nextTask != null
                        ? 'Nächste: ${event.nextTask!.title}'
                        : '✓ Abgeschlossen',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: event.nextTask != null
                          ? const Color(0xFF6B7280)
                          : AppTheme.green,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: event.progress,
                            minHeight: 5,
                            backgroundColor:
                                const Color(0xFF252B36),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                                    event.color),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Text(
                        '${event.doneCount}/${event.totalCount}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: event.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(10),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF6B7280), size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Quick Actions ─────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  static const _actions = [
    (icon: Icons.document_scanner_rounded,
        label: 'Doc\nscannen',
        color: AppTheme.primary,
        route: '/upload'),
    (icon: Icons.flag_rounded,
        label: 'Neues\nEvent',
        color: AppTheme.secondary,
        route: '/goals'),
    (icon: Icons.edit_note_rounded,
        label: 'Journal\nEintrag',
        color: AppTheme.amber,
        route: '/journal'),
    (icon: Icons.settings_rounded,
        label: 'Einstel-\nlungen',
        color: AppTheme.green,
        route: '/settings'),
  ];

  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(_actions.length, (i) {
        final a = _actions[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => context.push(a.route),
            child: Container(
              margin: EdgeInsets.only(
                  right: i < _actions.length - 1 ? 10 : 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: const Color(0xFF252B36)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: a.color.withOpacity(.12),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(a.icon,
                        color: a.color, size: 20),
                  ),
                  const Gap(8),
                  Text(
                    a.label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 10.5,
                      color: const Color(0xFFD1D5DB),
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    this.action,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -.3,
          ),
        ),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onTap,
            child: Text(
              action!,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
