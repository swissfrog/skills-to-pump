import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../theme/app_theme.dart';

// ──────────────────────────────────────────────────────────
// Model
// ──────────────────────────────────────────────────────────
class _JournalEntry {
  final String id;
  final String title;
  final String body;
  final String mood;
  final DateTime createdAt;
  final Color color;

  const _JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.mood,
    required this.createdAt,
    required this.color,
  });
}

const _kMoods = [
  (emoji: '😄', label: 'Super', color: AppTheme.green),
  (emoji: '🙂', label: 'Gut', color: AppTheme.primary),
  (emoji: '😐', label: 'Neutral', color: AppTheme.amber),
  (emoji: '😔', label: 'Müde', color: AppTheme.secondary),
  (emoji: '😤', label: 'Stress', color: AppTheme.tertiary),
];

// ──────────────────────────────────────────────────────────
// Provider
// ──────────────────────────────────────────────────────────
class _JournalNotifier extends StateNotifier<List<_JournalEntry>> {
  _JournalNotifier()
      : super([
          _JournalEntry(
            id: const Uuid().v4(),
            title: 'Erster Tag im neuen Job',
            body: 'Heute war mein erster Tag. Die Kollegen sind sehr nett und das Büro ist modern. Bin gespannt auf die kommenden Wochen!',
            mood: '😄',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
            color: AppTheme.green,
          ),
          _JournalEntry(
            id: const Uuid().v4(),
            title: 'Wohnungsbesichtigung',
            body: 'Drei Wohnungen angeschaut. Die zweite in Schwabing war perfekt – helle Küche, guter Schnitt, U-Bahn 5 Minuten.',
            mood: '🙂',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
            color: AppTheme.primary,
          ),
          _JournalEntry(
            id: const Uuid().v4(),
            title: 'Papierkram erledigt',
            body: 'Endlich SCHUFA-Auskunft beantragt und alle Einkommensnachweise zusammengesucht. Das Stapelpapier wird langsam weniger.',
            mood: '😐',
            createdAt: DateTime.now().subtract(const Duration(days: 8)),
            color: AppTheme.amber,
          ),
        ]);

  void add(_JournalEntry entry) => state = [entry, ...state];
  void delete(String id) => state = state.where((e) => e.id != id).toList();
}

final _journalProvider = StateNotifierProvider<_JournalNotifier, List<_JournalEntry>>((_) => _JournalNotifier());
final _selectedMoodProvider = StateProvider<int>((_) => 0);

// ──────────────────────────────────────────────────────────
// JournalScreen
// ──────────────────────────────────────────────────────────
class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  static const _bg = Color(0xFF0F1115);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_journalProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        title: Text('Journal', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [
          FilledButton.icon(
            onPressed: () => _showComposeSheet(context, ref),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Eintrag'),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          const Gap(16),
        ],
      ),
      body: entries.isEmpty ? _EmptyJournal(onTap: () => _showComposeSheet(context, ref)) : _JournalList(entries: entries),
    );
  }

  void _showComposeSheet(BuildContext ctx, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1B1F27),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ProviderScope(
        parent: ProviderScope.containerOf(ctx),
        child: _ComposeSheet(
          titleCtrl: titleCtrl,
          bodyCtrl: bodyCtrl,
          onSave: (title, body, moodIdx) {
            final mood = _kMoods[moodIdx];
            ref.read(_journalProvider.notifier).add(
              _JournalEntry(
                id: const Uuid().v4(),
                title: title,
                body: body,
                mood: mood.emoji,
                createdAt: DateTime.now(),
                color: mood.color,
              ),
            );
            Navigator.pop(ctx);
          },
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────
// Subwidgets
// ──────────────────────────────────────────────────────────
class _JournalList extends ConsumerWidget {
  final List<_JournalEntry> entries;
  const _JournalList({required this.entries});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (ctx, i) => _EntryCard(entry: entries[i], onDelete: () => ref.read(_journalProvider.notifier).delete(entries[i].id)).animate().fadeIn(delay: Duration(milliseconds: 60 * i)).slideY(begin: .04),
    );
  }
}

class _EntryCard extends StatelessWidget {
  final _JournalEntry entry;
  final VoidCallback onDelete;
  const _EntryCard({required this.entry, required this.onDelete});

  static const _card = Color(0xFF1B1F27);

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Heute';
    if (diff.inDays == 1) return 'Gestern';
    return '${dt.day}.${dt.month}.${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppTheme.tertiary.withOpacity(.15), borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.delete_outline_rounded, color: AppTheme.tertiary, size: 24),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF252B36), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Text(entry.mood, style: const TextStyle(fontSize: 22)), const Gap(10), Expanded(child: Text(entry.title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white), overflow: TextOverflow.ellipsis)), const Gap(8), Text(_formatDate(entry.createdAt), style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280)))]),
            const Gap(10),
            Text(entry.body, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF), height: 1.55), maxLines: 3, overflow: TextOverflow.ellipsis),
            const Gap(12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: entry.color.withOpacity(.10), borderRadius: BorderRadius.circular(6)),
              child: Text(_kMoods.firstWhere((m) => m.emoji == entry.mood, orElse: () => _kMoods[0]).label, style: GoogleFonts.inter(fontSize: 11, color: entry.color, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyJournal extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyJournal({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(padding: const EdgeInsets.all(24), decoration: const BoxDecoration(color: Color(0xFF1B1F27), shape: BoxShape.circle), child: const Text('📓', style: TextStyle(fontSize: 44))),
          const Gap(24),
          Text('Noch keine Einträge', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const Gap(8),
          Text('Halte deine Gedanken und\nFortschritte fest.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))),
          const Gap(28),
          FilledButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Ersten Eintrag schreiben'),
            style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}

class _ComposeSheet extends ConsumerStatefulWidget {
  final TextEditingController titleCtrl;
  final TextEditingController bodyCtrl;
  final void Function(String title, String body, int moodIdx) onSave;
  const _ComposeSheet({required this.titleCtrl, required this.bodyCtrl, required this.onSave});

  @override
  ConsumerState<_ComposeSheet> createState() => _ComposeSheetState();
}

class _ComposeSheetState extends ConsumerState<_ComposeSheet> {
  int _moodIdx = 0;

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
        filled: true,
        fillColor: const Color(0xFF21262F),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF252B36))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF252B36))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primary, width: 1.5)),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3D4450), borderRadius: BorderRadius.circular(2)))),
          const Gap(20),
          Text('Neuer Eintrag', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const Gap(16),
          Text('Wie fühlst du dich?', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kMoods.asMap().entries.map((e) {
              final selected = e.key == _moodIdx;
              return GestureDetector(
                onTap: () => setState(() => _moodIdx = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: selected ? e.value.color.withOpacity(.14) : const Color(0xFF21262F),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? e.value.color.withOpacity(.4) : const Color(0xFF252B36), width: 1.5),
                  ),
                  child: Text(e.value.emoji, style: const TextStyle(fontSize: 22)),
                ),
              );
            }).toList(),
          ),
          const Gap(16),
          TextField(controller: widget.titleCtrl, style: GoogleFonts.inter(color: Colors.white), decoration: _inputDeco('Titel…')),
          const Gap(12),
          TextField(controller: widget.bodyCtrl, style: GoogleFonts.inter(color: Colors.white, height: 1.5), maxLines: 4, decoration: _inputDeco('Was ist heute passiert?')),
          const Gap(20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final t = widget.titleCtrl.text.trim();
                final b = widget.bodyCtrl.text.trim();
                if (t.isEmpty) return;
                widget.onSave(t, b, _moodIdx);
              },
              style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
              child: const Text('Speichern'),
            ),
          ),
        ],
      ),
    );
  }
}
