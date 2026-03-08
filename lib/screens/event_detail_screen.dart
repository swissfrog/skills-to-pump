import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/life_models.dart';
import '../services/life_event.dart';
import '../theme/app_theme.dart';

class EventDetailScreen extends ConsumerWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  static const _bg = Color(0xFF0F1115);
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(lifeEventsProvider);
    final event = events.firstWhere((e) => e.id == eventId);

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ─────────────────────────────────
          SliverAppBar(
            backgroundColor: _bg,
            surfaceTintColor: Colors.transparent,
            expandedHeight: 160,
            pinned: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
              onPressed: () =>
                  Navigator.of(context).maybePop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                padding: EdgeInsets.fromLTRB(
                  20,
                  MediaQuery.of(context).padding.top + 56,
                  20,
                  20,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisAlignment:
                      MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: event.color
                                .withOpacity(.15),
                            borderRadius:
                                BorderRadius.circular(14),
                          ),
                          child: Icon(event.icon,
                              color: event.color,
                              size: 24),
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
                                  fontSize: 22,
                                  fontWeight:
                                      FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -.4,
                                ),
                              ),
                              Text(
                                event.description,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: const Color(
                                      0xFF9CA3AF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: event.progress,
                              minHeight: 7,
                              backgroundColor:
                                  const Color(0xFF252B36),
                              valueColor:
                                  AlwaysStoppedAnimation<
                                      Color>(event.color),
                            ),
                          ),
                        ),
                        const Gap(12),
                        Text(
                          '${event.doneCount}/${event.totalCount} Aufgaben',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: event.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Task List ───────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            sliver: SliverList.separated(
              itemCount: event.tasks.length,
              separatorBuilder: (_, __) => const Gap(14),
              itemBuilder: (ctx, i) {
                final task = event.tasks[i];
                return _TaskCard(
                  task: task,
                  event: event,
                  taskIndex: i,
                  onComplete: () => ref
                      .read(lifeEventsProvider.notifier)
                      .completeTask(event.id, task.id),
                  onToggleDoc: (di) => ref
                      .read(lifeEventsProvider.notifier)
                      .toggleDoc(event.id, task.id, di),
                ).animate().fadeIn(
                  delay: Duration(
                      milliseconds: 60 + i * 70),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task Card ─────────────────────────────────────────────
class _TaskCard extends ConsumerStatefulWidget {
  final LifeTask task;
  final LifeEvent event;
  final int taskIndex;
  final VoidCallback onComplete;
  final void Function(int) onToggleDoc;

  const _TaskCard({
    required this.task,
    required this.event,
    required this.taskIndex,
    required this.onComplete,
    required this.onToggleDoc,
  });

  @override
  ConsumerState<_TaskCard> createState() =>
      _TaskCardState();
}

class _TaskCardState extends ConsumerState<_TaskCard> {
  bool _expanded = false;

  static const _card = Color(0xFF1B1F27);
  static const _card2 = Color(0xFF21262F);

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final event = widget.event;
    final isNext = !task.completed &&
        event.nextTask?.id == task.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.completed
              ? AppTheme.green.withOpacity(.2)
              : isNext
                  ? event.color.withOpacity(.3)
                  : const Color(0xFF252B36),
          width: isNext ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────
          GestureDetector(
            onTap: task.completed
                ? null
                : () =>
                    setState(() => _expanded = !_expanded),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // Step number / Check
                  GestureDetector(
                    onTap: task.completed
                        ? null
                        : widget.onComplete,
                    child: AnimatedContainer(
                      duration: const Duration(
                          milliseconds: 250),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: task.completed
                            ? AppTheme.green
                                .withOpacity(.15)
                            : isNext
                                ? event.color
                                    .withOpacity(.12)
                                : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.completed
                              ? AppTheme.green
                              : isNext
                                  ? event.color
                                  : const Color(
                                      0xFF3D4450),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: task.completed
                            ? const Icon(
                                Icons.check_rounded,
                                color: AppTheme.green,
                                size: 16,
                              )
                            : Text(
                                '${widget.taskIndex + 1}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight:
                                      FontWeight.w700,
                                  color: isNext
                                      ? event.color
                                      : const Color(
                                          0xFF6B7280),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const Gap(14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isNext)
                              Container(
                                margin:
                                    const EdgeInsets.only(
                                        right: 8),
                                padding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3),
                                decoration: BoxDecoration(
                                  color: event.color
                                      .withOpacity(.15),
                                  borderRadius:
                                      BorderRadius.circular(
                                          6),
                                ),
                                child: Text(
                                  'JETZT',
                                  style: GoogleFonts.inter(
                                    fontSize: 9,
                                    color: event.color,
                                    fontWeight:
                                        FontWeight.w800,
                                    letterSpacing: .5,
                                  ),
                                ),
                              ),
                            Expanded(
                              child: Text(
                                task.title,
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.w600,
                                  color: task.completed
                                      ? const Color(
                                          0xFF6B7280)
                                      : Colors.white,
                                  decoration: task.completed
                                      ? TextDecoration
                                          .lineThrough
                                      : null,
                                  decorationColor:
                                      const Color(
                                          0xFF6B7280),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(4),
                        Text(
                          task.description,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color:
                                const Color(0xFF6B7280),
                            height: 1.45,
                          ),
                          maxLines: _expanded ? 100 : 2,
                          overflow: _expanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        const Gap(8),
                        Row(
                          children: [
                            _MiniChip(
                              icon: Icons
                                  .description_outlined,
                              label:
                                  '${task.docs.length} Docs',
                              color: task.completed
                                  ? AppTheme.green
                                  : event.color,
                            ),
                            const Gap(8),
                            _MiniChip(
                              icon: Icons.schedule_rounded,
                              label:
                                  '${task.estimatedMinutes} Min',
                              color: task.completed
                                  ? AppTheme.green
                                  : event.color,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!task.completed) ...[
                    const Gap(8),
                    Icon(
                      _expanded
                          ? Icons
                              .keyboard_arrow_up_rounded
                          : Icons
                              .keyboard_arrow_down_rounded,
                      color: const Color(0xFF6B7280),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Expanded content ────────────────────────
          if (_expanded && !task.completed) ...[
            const Divider(
                color: Color(0xFF252B36), height: 1),

            // Documents
            if (task.docs.isNotEmpty) ...[
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Text(
                  'Benötigte Dokumente',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: .3,
                  ),
                ),
              ),
              const Gap(10),
              ...task.docs.asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.fromLTRB(
                          16, 0, 16, 8),
                      child: _DocRow(
                        doc: e.value,
                        color: event.color,
                        onTap: () =>
                            widget.onToggleDoc(e.key),
                      ),
                    ),
                  ),
            ],

            // Steps
            if (task.steps.isNotEmpty) ...[
              const Divider(
                  color: Color(0xFF252B36),
                  height: 1,
                  indent: 16),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Text(
                  'Schritt-für-Schritt',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF9CA3AF),
                    letterSpacing: .3,
                  ),
                ),
              ),
              const Gap(10),
              ...task.steps.map(
                (s) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 10),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: event.color
                              .withOpacity(.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${s.number}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: event.color,
                            ),
                          ),
                        ),
                      ),
                      const Gap(10),
                      Expanded(
                        child: Text(
                          s.text,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: const Color(
                                0xFFD1D5DB),
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Complete button
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    widget.onComplete();
                    setState(() => _expanded = false);
                  },
                  icon: const Icon(
                      Icons.check_rounded, size: 18),
                  label: const Text('Als erledigt markieren'),
                  style: FilledButton.styleFrom(
                    backgroundColor: event.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12)),
                    textStyle: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Doc Row ───────────────────────────────────────────────
class _DocRow extends StatelessWidget {
  final RequiredDoc doc;
  final Color color;
  final VoidCallback onTap;

  const _DocRow({
    required this.doc,
    required this.color,
    required this.onTap,
  });

  static const _card2 = Color(0xFF21262F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _card2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: doc.available
                ? color.withOpacity(.25)
                : const Color(0xFF3D4450),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: doc.available
                    ? color.withOpacity(.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: doc.available
                      ? color
                      : const Color(0xFF4D5562),
                  width: 1.5,
                ),
              ),
              child: doc.available
                  ? Icon(Icons.check_rounded,
                      color: color, size: 13)
                  : null,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                doc.name,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: doc.available
                      ? const Color(0xFF9CA3AF)
                      : Colors.white,
                  fontWeight: FontWeight.w500,
                  decoration: doc.available
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor:
                      const Color(0xFF6B7280),
                ),
              ),
            ),
            Text(
              doc.available ? 'Vorhanden' : 'Fehlt',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: doc.available
                    ? color
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini Chip ─────────────────────────────────────────────
class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 11),
          const Gap(4),
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
