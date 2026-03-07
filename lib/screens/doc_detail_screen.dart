import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../models/models.dart';
import '../services/doc_store.dart';

class DocDetailScreen extends StatefulWidget {
  final ScannedDocument doc;
  const DocDetailScreen({super.key, required this.doc});
  @override
  State<DocDetailScreen> createState() => _DocDetailScreenState();
}

class _DocDetailScreenState extends State<DocDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late ScannedDocument _doc;
  final _store = DocStore();

  @override
  void initState() {
    super.initState();
    _doc = widget.doc;
    _tabs = TabController(length: 5, vsync: this);
    _store.addListener(_onStoreChange);
  }

  void _onStoreChange() {
    final updated = _store.docs.firstWhere((d) => d.id == _doc.id, orElse: () => _doc);
    if (mounted) setState(() => _doc = updated);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _store.removeListener(_onStoreChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = AppTheme.getCardConfig(_typeId(_doc.docType));
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: Column(children: [
            _buildHeader(cfg),
            _buildTabBar(cfg),
            Expanded(child: TabBarView(controller: _tabs, children: [
              _OcrTab(doc: _doc),
              _SummaryTab(doc: _doc),
              _ExplainTab(doc: _doc),
              _ReplyTab(doc: _doc),
              _TimelineTab(doc: _doc, onTaskToggle: _toggleTask),
            ])),
          ]),
        ),
      ),
    );
  }

  Widget _buildHeader(CardColorConfig cfg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Row(children: [
        GlassIconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_doc.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          Row(children: [
            GlassBadge(label: _doc.docType.label, color: cfg.glow),
            const SizedBox(width: 6),
            GlassBadge(label: _doc.category.label, color: AppTheme.blue),
          ]),
        ])),
        // Thumbnail
        ClipRRect(borderRadius: BorderRadius.circular(10),
          child: SizedBox(width: 44, height: 44,
            child: Image.file(File(_doc.imagePath), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: cfg.glow.withValues(alpha: 0.2),
                child: Icon(cfg.icon, color: cfg.glow, size: 20))))),
      ]),
    );
  }

  Widget _buildTabBar(CardColorConfig cfg) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1),
            ),
            child: TabBar(
              controller: _tabs,
              indicator: BoxDecoration(
                color: cfg.glow.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(11),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: LP.label3,
              labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              unselectedLabelStyle: const TextStyle(fontSize: 10),
              tabs: const [
                Tab(text: 'OCR'), Tab(text: 'KI'), Tab(text: 'Erklärt'),
                Tab(text: 'Antwort'), Tab(text: 'Verlauf'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTask(String taskId, TaskStatus newStatus) {
    _store.updateTaskStatus(taskId, newStatus);
  }

  String _typeId(DocType t) {
    switch (t) {
      case DocType.invoice: return 'tasks';
      case DocType.govLetter: return 'categories';
      case DocType.form: return 'ai';
      default: return 'scan';
    }
  }
}

// ─── OCR Tab ──────────────────────────────────────────────────────────────────

class _OcrTab extends StatelessWidget {
  final ScannedDocument doc;
  const _OcrTab({required this.doc});

  @override
  Widget build(BuildContext context) {
    final hasText = doc.ocrText?.isNotEmpty == true;
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 18), children: [
      // Image preview
      ClipRRect(borderRadius: BorderRadius.circular(16),
        child: SizedBox(height: 160,
          child: Image.file(File(doc.imagePath), fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(height: 160,
              color: LP.purple.withValues(alpha: 0.1),
              child: const Icon(Icons.image_outlined, color: LP.label3, size: 48))))),
      const SizedBox(height: 12),
      if (!hasText)
        GlassCard(padding: const EdgeInsets.all(20),
          child: const Column(children: [
            Icon(Icons.text_fields_outlined, color: LP.label3, size: 36),
            SizedBox(height: 8),
            Text('Kein Text erkannt', style: TextStyle(color: LP.label2, fontSize: 14)),
            Text('Das Bild enthält keinen lesbaren Text',
              style: TextStyle(color: LP.label3, fontSize: 11)),
          ]))
      else ...[
        Row(children: [
          GlassBadge(label: '${doc.ocrText!.split(' ').length} Wörter', color: AppTheme.green),
          const Spacer(),
          GlassIconBtn(icon: Icons.copy_outlined,
            onTap: () => Clipboard.setData(ClipboardData(text: doc.ocrText!))
                .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kopiert!'), duration: Duration(seconds: 1))))),
        ]),
        const SizedBox(height: 8),
        GlassCard(padding: const EdgeInsets.all(14),
          child: SelectableText(doc.ocrText!,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.65, letterSpacing: 0.1))),
      ],
    ]);
  }
}

// ─── Summary Tab (KI) ─────────────────────────────────────────────────────────

class _SummaryTab extends StatelessWidget {
  final ScannedDocument doc;
  const _SummaryTab({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 18), children: [
      // Sender
      if (doc.sender != null) ...[
        SectionHeader(title: 'ABSENDER'),
        GlassCard(padding: const EdgeInsets.all(12),
          child: Row(children: [
            const Icon(Icons.business_outlined, color: AppTheme.blue, size: 20),
            const SizedBox(width: 10),
            Text(doc.sender!, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ])),
        const SizedBox(height: 12),
      ],
      // Summary
      SectionHeader(title: 'KI-ZUSAMMENFASSUNG'),
      GlassCard(
        tint: LP.purple.withValues(alpha: 0.08),
        borderColor: LP.purple.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome, color: LP.purple, size: 15),
            const SizedBox(width: 6),
            const Text('KI Analyse', style: TextStyle(color: LP.purple, fontSize: 11, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(doc.aiSummary ?? 'Keine KI-Analyse verfügbar',
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6)),
        ]),
      ),
      const SizedBox(height: 12),
      // Tasks
      if (doc.tasks.isNotEmpty) ...[
        SectionHeader(title: 'ERKANNTE AUFGABEN', trailing: '${doc.tasks.length}'),
        ...doc.tasks.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _TaskRow(task: t),
        )),
      ],
    ]);
  }
}

class _TaskRow extends StatelessWidget {
  final DocTask task;
  const _TaskRow({required this.task});

  Color get _color {
    switch (task.priority) {
      case TaskPriority.high: return AppTheme.coral;
      case TaskPriority.medium: return AppTheme.yellow;
      default: return AppTheme.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      tint: _color.withValues(alpha: 0.06),
      child: Row(children: [
        Icon(Icons.task_alt_outlined, color: _color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(task.description, style: const TextStyle(color: LP.label3, fontSize: 10)),
        ])),
        if (task.deadline != null)
          GlassBadge(label: '${task.deadline!.day}.${task.deadline!.month}', color: _color),
      ]),
    );
  }
}

// ─── Explain Tab ──────────────────────────────────────────────────────────────

class _ExplainTab extends StatelessWidget {
  final ScannedDocument doc;
  const _ExplainTab({required this.doc});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 18), children: [
      GlassCard(
        tint: AppTheme.turquoise.withValues(alpha: 0.08),
        borderColor: AppTheme.turquoise.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lightbulb_outline, color: AppTheme.turquoise, size: 18),
            const SizedBox(width: 8),
            const Text('Einfach erklärt', style: TextStyle(color: AppTheme.turquoise, fontSize: 13, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 12),
          Text(doc.aiExplanation ?? 'Keine Erklärung verfügbar.',
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.7)),
        ]),
      ),
      const SizedBox(height: 14),
      // Tips based on doc type
      SectionHeader(title: 'TIPPS & NÄCHSTE SCHRITTE'),
      ..._tips(doc.docType).map((tip) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('→', style: TextStyle(color: AppTheme.turquoise, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            Expanded(child: Text(tip, style: const TextStyle(color: LP.label2, fontSize: 12, height: 1.5))),
          ])),
      )),
    ]);
  }

  List<String> _tips(DocType t) {
    switch (t) {
      case DocType.invoice: return ['Betrag und Bankdaten prüfen', 'Rechnung vor dem Fälligkeitsdatum bezahlen', 'Quittung aufbewahren'];
      case DocType.govLetter: return ['Frist genau beachten', 'Bei Unklarheiten nachfragen', 'Antwort per Einschreiben senden'];
      case DocType.contract: return ['Alle Klauseln sorgfältig lesen', 'Laufzeit und Kündigung prüfen', 'Kopie für eigene Unterlagen aufbewahren'];
      case DocType.form: return ['Alle Pflichtfelder ausfüllen', 'Unterschrift nicht vergessen', 'Kopie vor dem Senden machen'];
      case DocType.appointment: return ['Termin im Kalender eintragen', 'Pünktlich erscheinen', 'Benötigte Dokumente mitbringen'];
      default: return ['Dokument sorgfältig lesen', 'Fristen beachten', 'Bei Fragen professionelle Hilfe holen'];
    }
  }
}

// ─── Reply Tab ────────────────────────────────────────────────────────────────

class _ReplyTab extends StatefulWidget {
  final ScannedDocument doc;
  const _ReplyTab({required this.doc});
  @override
  State<_ReplyTab> createState() => _ReplyTabState();
}

class _ReplyTabState extends State<_ReplyTab> {
  late TextEditingController _ctrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.doc.replyDraft ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.doc.replyDraft == null) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.reply_outlined, color: LP.label3, size: 40),
        SizedBox(height: 8),
        Text('Kein Antwortvorschlag verfügbar', style: TextStyle(color: LP.label2)),
        Text('Bitte zuerst OCR durchführen', style: TextStyle(color: LP.label3, fontSize: 12)),
      ]));
    }
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 18), children: [
      Row(children: [
        GlassBadge(label: 'KI-Entwurf', color: LP.purple),
        const Spacer(),
        GlassIconBtn(icon: _editing ? Icons.check : Icons.edit_outlined,
          color: _editing ? AppTheme.green : Colors.white,
          onTap: () => setState(() => _editing = !_editing)),
        const SizedBox(width: 8),
        GlassIconBtn(icon: Icons.copy_outlined,
          onTap: () => Clipboard.setData(ClipboardData(text: _ctrl.text))
              .then((_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Kopiert!'), duration: Duration(seconds: 1))))),
      ]),
      const SizedBox(height: 10),
      GlassCard(
        tint: LP.purple.withValues(alpha: 0.06),
        borderColor: _editing ? LP.purple.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(14),
        child: _editing
            ? TextField(
                controller: _ctrl,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.65),
                decoration: const InputDecoration(border: InputBorder.none),
              )
            : Text(_ctrl.text,
                style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.65)),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GlassActionBtn(
          icon: Icons.share_outlined, label: 'Teilen',
          color: AppTheme.blue, onTap: () {})),
        const SizedBox(width: 10),
        Expanded(child: GlassActionBtn(
          icon: Icons.print_outlined, label: 'Drucken',
          color: AppTheme.turquoise, onTap: () {})),
      ]),
    ]);
  }
}

// ─── Timeline Tab ─────────────────────────────────────────────────────────────

class _TimelineTab extends StatelessWidget {
  final ScannedDocument doc;
  final Function(String, TaskStatus) onTaskToggle;
  const _TimelineTab({required this.doc, required this.onTaskToggle});

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.fromLTRB(18, 4, 18, 18), children: [
      SectionHeader(title: 'DOKUMENTVERLAUF'),
      ...doc.timeline.asMap().entries.map((e) {
        final last = e.key == doc.timeline.length - 1;
        final ev = e.value;
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(color: LP.purple, shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: LP.purple.withValues(alpha: 0.5), blurRadius: 6)])),
            if (!last) Container(width: 1, height: 44, color: Colors.white.withValues(alpha: 0.1)),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(padding: const EdgeInsets.all(10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(ev.title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                if (ev.note != null) Text(ev.note!, style: const TextStyle(color: LP.label3, fontSize: 10)),
                const SizedBox(height: 4),
                Text('${ev.date.day}.${ev.date.month}.${ev.date.year}  ${ev.date.hour.toString().padLeft(2,'0')}:${ev.date.minute.toString().padLeft(2,'0')}',
                  style: const TextStyle(color: LP.label3, fontSize: 10)),
              ])),
          )),
        ]);
      }),
      if (doc.tasks.isNotEmpty) ...[
        const SizedBox(height: 8),
        SectionHeader(title: 'AUFGABEN', trailing: '${doc.tasks.length}'),
        ...doc.tasks.map((task) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(padding: const EdgeInsets.all(12),
            child: Row(children: [
              GestureDetector(
                onTap: () => onTaskToggle(task.id,
                  task.status == TaskStatus.completed ? TaskStatus.open : TaskStatus.completed),
                child: Container(width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: task.status == TaskStatus.completed ? AppTheme.green.withValues(alpha: 0.3) : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(color: task.status == TaskStatus.completed ? AppTheme.green : LP.label3, width: 1.5)),
                  child: task.status == TaskStatus.completed
                    ? const Icon(Icons.check, color: AppTheme.green, size: 14)
                    : null),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(task.title,
                style: TextStyle(
                  color: task.status == TaskStatus.completed ? LP.label3 : Colors.white,
                  fontSize: 12, fontWeight: FontWeight.w500,
                  decoration: task.status == TaskStatus.completed ? TextDecoration.lineThrough : null,
                ))),
              if (task.deadline != null)
                GlassBadge(label: '${task.deadline!.day}.${task.deadline!.month}',
                  color: task.status == TaskStatus.completed ? AppTheme.green : AppTheme.coral),
            ])),
        )),
      ],
    ]);
  }
}
