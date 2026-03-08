import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

// ── Models ──────────────────────────────────────────────────
class _LifeEvent {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int totalDocs;
  final int uploadedDocs;

  const _LifeEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.totalDocs,
    required this.uploadedDocs,
  });

  double get progress => totalDocs == 0 ? 0 : uploadedDocs / totalDocs;
}

class _RecentDoc {
  final String name;
  final String event;
  final String date;
  final IconData icon;
  final Color color;

  const _RecentDoc({
    required this.name,
    required this.event,
    required this.date,
    required this.icon,
    required this.color,
  });
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

// ── Sample Data ─────────────────────────────────────────────
const _kEvents = <_LifeEvent>[
  _LifeEvent(id: 'job', title: 'Neue Stelle', subtitle: '3 Docs ausstehend', icon: Icons.work_rounded, color: AppTheme.primary, totalDocs: 7, uploadedDocs: 4),
  _LifeEvent(id: 'apartment', title: 'Wohnung mieten', subtitle: '5 Docs ausstehend', icon: Icons.apartment_rounded, color: AppTheme.secondary, totalDocs: 8, uploadedDocs: 3),
  _LifeEvent(id: 'bank', title: 'Konto eröffnen', subtitle: 'Bereit zum Einreichen', icon: Icons.account_balance_rounded, color: AppTheme.amber, totalDocs: 4, uploadedDocs: 4),
  _LifeEvent(id: 'insurance', title: 'Krankenversicherung', subtitle: '2 Docs ausstehend', icon: Icons.health_and_safety_rounded, color: AppTheme.green, totalDocs: 5, uploadedDocs: 3),
];

const _kRecentDocs = <_RecentDoc>[
  _RecentDoc(name: 'Arbeitszeugnis.pdf', event: 'Neue Stelle', date: 'Heute, 14:23', icon: Icons.picture_as_pdf_rounded, color: AppTheme.tertiary),
  _RecentDoc(name: 'Mietbescheinigung.jpg', event: 'Wohnung mieten', date: 'Gestern, 09:11', icon: Icons.image_rounded, color: AppTheme.secondary),
  _RecentDoc(name: 'Personalausweis.jpg', event: 'Konto eröffnen', date: '12. Jan, 18:04', icon: Icons.badge_rounded, color: AppTheme.amber),
];

const _kQuickActions = <_QuickAction>[
  _QuickAction(icon: Icons.document_scanner_rounded, label: 'Dokument\nscannen', color: AppTheme.primary, route: '/upload'),
  _QuickAction(icon: Icons.add_task_rounded, label: 'Neues\nLife Event', color: AppTheme.secondary, route: '/goals'),
  _QuickAction(icon: Icons.edit_note_rounded, label: 'Journal\nEintrag', color: AppTheme.amber, route: '/journal'),
  _QuickAction(icon: Icons.cloud_upload_rounded, label: 'Aus Galerie\nimportieren', color: AppTheme.tertiary, route: '/upload'),
];

// ── Screen ──────────────────────────────────────────────────
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const _bg = Color(0xFF0F1115);
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Gap(28),
                _buildProgressOverview().animate().fadeIn(delay: 100.ms).slideY(begin: .04),
                const Gap(28),
                _sectionHeader(context: context, title: 'Life Events', action: 'Alle anzeigen', onTap: () => context.go('/goals')).animate().fadeIn(delay: 150.ms),
                const Gap(18),
                _buildLifeEventGrid(context).animate().fadeIn(delay: 200.ms),
                const Gap(28),
                _sectionHeader(context: context, title: 'Schnellzugriff').animate().fadeIn(delay: 250.ms),
                const Gap(18),
                _buildQuickActions(context).animate().fadeIn(delay: 280.ms),
                const Gap(28),
                _sectionHeader(context: context, title: 'Zuletzt gescannt', action: 'Alle Docs', onTap: () => context.push('/upload')).animate().fadeIn(delay: 300.ms),
                const Gap(18),
                _buildRecentDocs().animate().fadeIn(delay: 330.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      expandedHeight: 130,
      floating: true,
      snap: true,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(_greeting(), style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280), fontWeight: FontWeight.w500, letterSpacing: .3)),
                    const Gap(4),
                    Text('LifeNav', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -.5)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.go('/settings'),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.primary, Color(0xFF0060CC)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview() {
    const totalDocs = 24;
    const uploadedDocs = 14;
    const percent = uploadedDocs / totalDocs;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFF252B36))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.insights_rounded, color: AppTheme.primary, size: 20)),
              const Gap(12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Gesamtfortschritt', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF6B7280))), Text('$uploadedDocs von $totalDocs Dokumenten', style: GoogleFonts.inter(fontSize: 15, color: Colors.white, fontWeight: FontWeight.w600))])),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.12), borderRadius: BorderRadius.circular(8)), child: Text('${(percent * 100).round()}%', style: GoogleFonts.inter(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w700))),
            ],
          ),
          const Gap(16),
          ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: percent, minHeight: 8, backgroundColor: const Color(0xFF252B36), valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary))),
          const Gap(14),
          Row(children: [_statChip(Icons.check_circle_rounded, '$uploadedDocs erledigt', AppTheme.green), const Gap(10), _statChip(Icons.pending_rounded, '${totalDocs - uploadedDocs} ausstehend', AppTheme.amber), const Gap(10), _statChip(Icons.folder_rounded, '${_kEvents.length} Events', AppTheme.secondary)]),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(color: color.withOpacity(.09), borderRadius: BorderRadius.circular(10)),
        child: Row(children: [Icon(icon, color: color, size: 14), const Gap(5), Flexible(child: Text(label, style: GoogleFonts.inter(fontSize: 11, color: color, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis))]),
      ),
    );
  }

  Widget _buildLifeEventGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.05),
      itemCount: _kEvents.length,
      itemBuilder: (_, i) => _LifeEventCard(event: _kEvents[i]),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: List.generate(_kQuickActions.length, (i) {
        final a = _kQuickActions[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => context.push(a.route),
            child: Container(
              margin: EdgeInsets.only(right: i < _kQuickActions.length - 1 ? 10 : 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF252B36))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: a.color.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(a.icon, color: a.color, size: 20)), const Gap(8), Text(a.label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFFD1D5DB), fontWeight: FontWeight.w500, height: 1.35))]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRecentDocs() {
    return Column(children: _kRecentDocs.asMap().entries.map((e) => _RecentDocTile(doc: e.value, isLast: e.key == _kRecentDocs.length - 1)).toList());
  }

  Widget _sectionHeader({required BuildContext context, required String title, String? action, VoidCallback? onTap}) {
    return Row(children: [Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -.3)), const Spacer(), if (action != null) GestureDetector(onTap: onTap, child: Text(action, style: GoogleFonts.inter(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w500)))]);
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Guten Morgen 👋';
    if (h < 17) return 'Guten Tag 👋';
    return 'Guten Abend 👋';
  }
}

class _LifeEventCard extends StatelessWidget {
  final _LifeEvent event;
  const _LifeEventCard({super.key, required this.event});
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/goals'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF252B36))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: event.color.withOpacity(.12), borderRadius: BorderRadius.circular(12)), child: Icon(event.icon, color: event.color, size: 20)),
            const Spacer(),
            Text(event.title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
            const Gap(3),
            Text(event.subtitle, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280))),
            const Gap(10),
            ClipRRect(borderRadius: BorderRadius.circular(99), child: LinearProgressIndicator(value: event.progress, minHeight: 5, backgroundColor: const Color(0xFF252B36), valueColor: AlwaysStoppedAnimation<Color>(event.color))),
            const Gap(5),
            Text('${event.uploadedDocs}/${event.totalDocs} Docs', style: GoogleFonts.inter(fontSize: 10, color: event.color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _RecentDocTile extends StatelessWidget {
  final _RecentDoc doc;
  final bool isLast;
  const _RecentDocTile({super.key, required this.doc, required this.isLast});
  static const _card = Color(0xFF1B1F27);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF252B36))),
      child: Row(
        children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: doc.color.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(doc.icon, color: doc.color, size: 22)),
          const Gap(14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doc.name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white), overflow: TextOverflow.ellipsis), const Gap(3), Text('${doc.event} · ${doc.date}', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF6B7280)))])),
          const Gap(10),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280), size: 20),
        ],
      ),
    );
  }
}
