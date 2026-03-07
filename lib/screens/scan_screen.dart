import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import '../models/models.dart';
import '../services/doc_intelligence.dart';
import '../services/doc_store.dart';
import 'doc_detail_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  final _ocr = TextRecognizer(script: TextRecognitionScript.latin);
  final _store = DocStore();
  bool _busy = false;
  String _step = '';
  int _stepIdx = 0;

  static const _steps = [
    'Bild laden…', 'Bild speichern…', 'OCR läuft…', 'KI analysiert…', 'Fertig!'
  ];

  @override
  void initState() {
    super.initState();
    _store.addListener(() { if (mounted) setState(() {}); });
    _requestPermissions();
  }

  @override
  void dispose() {
    _ocr.close();
    _store.removeListener(() {});
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
  }

  void _setStep(int i) => setState(() { _stepIdx = i; _step = _steps[i]; });

  Future<void> _scan(ImageSource source) async {
    if (_busy) return;
    setState(() { _busy = true; });
    _setStep(0);
    try {
      final XFile? img = await _picker.pickImage(source: source, imageQuality: 95);
      if (img == null) { setState(() { _busy = false; _step = ''; }); return; }

      _setStep(1);
      final dir = await getApplicationDocumentsDirectory();
      final docDir = Directory('${dir.path}/scanned_documents');
      if (!await docDir.exists()) await docDir.create(recursive: true);
      final ts = DateTime.now().millisecondsSinceEpoch;
      final savePath = '${docDir.path}/doc_$ts.jpg';
      await File(img.path).copy(savePath);

      _setStep(2);
      final inputImg = InputImage.fromFilePath(savePath);
      final recognized = await _ocr.processImage(inputImg);
      final ocrText = recognized.text.trim();

      _setStep(3);
      await Future.delayed(const Duration(milliseconds: 400)); // allow UI update
      final docId = 'doc_$ts';
      var doc = ScannedDocument(
        id: docId,
        name: 'Dokument ${_store.totalDocs + 1}',
        imagePath: savePath,
        scannedAt: DateTime.now(),
        ocrText: ocrText.isEmpty ? null : ocrText,
      );
      doc = DocIntelligence.analyze(doc);
      _store.addDocument(doc);

      _setStep(4);
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DocDetailScreen(doc: doc)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e'), backgroundColor: Colors.red));
    } finally {
      setState(() { _busy = false; _step = ''; _stepIdx = 0; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = _store.docs;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassBackground(
        child: SafeArea(
          child: Column(children: [
            GlassAppBar(
              title: 'Dokument scannen',
              subtitle: 'OCR • KI-Analyse • Auto-Kategorisierung',
              actions: [GlassIconBtn(icon: Icons.info_outline, onTap: _showInfo)],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(children: [
                Expanded(child: _ScanBtn(
                  icon: Icons.camera_alt_outlined, label: 'Kamera',
                  subtitle: 'Jetzt fotografieren', color: LP.purple,
                  onTap: _busy ? null : () => _scan(ImageSource.camera),
                )),
                const SizedBox(width: 12),
                Expanded(child: _ScanBtn(
                  icon: Icons.photo_library_outlined, label: 'Galerie',
                  subtitle: 'Bild importieren', color: AppTheme.blue,
                  onTap: _busy ? null : () => _scan(ImageSource.gallery),
                )),
              ]),
            ),
            if (_busy) ...[
              const SizedBox(height: 14),
              _ProgressBar(stepIdx: _stepIdx, steps: _steps, currentStep: _step),
            ],
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SectionHeader(title: 'GESCANNTE DOKUMENTE', trailing: '${docs.length}'),
            ),
            Expanded(
              child: docs.isEmpty
                  ? _EmptyState(onScan: () => _scan(ImageSource.camera))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      itemCount: docs.length,
                      itemBuilder: (_, i) => _DocTile(
                        doc: docs[i],
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => DocDetailScreen(doc: docs[i]))),
                      ),
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  void _showInfo() {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('OCR & KI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      content: const Text(
        'Die App erkennt Text in gescannten Dokumenten (OCR) und analysiert ihn automatisch mit KI:\n\n'
        '• Dokumenttyp erkennen\n• Absender ermitteln\n• Fristen & Aufgaben erkennen\n'
        '• Zusammenfassung erstellen\n• Antwortbrief vorschlagen',
        style: TextStyle(color: LP.label2, height: 1.6),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context),
        child: const Text('OK', style: TextStyle(color: LP.purple)))],
    ));
  }
}

class _ProgressBar extends StatelessWidget {
  final int stepIdx;
  final List<String> steps;
  final String currentStep;
  const _ProgressBar({required this.stepIdx, required this.steps, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: GlassCard(
        tint: LP.purple.withValues(alpha: 0.12),
        borderColor: LP.purple.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: LP.purple)),
            const SizedBox(width: 12),
            Text(currentStep, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('${stepIdx + 1}/${steps.length}', style: const TextStyle(color: LP.label3, fontSize: 11)),
          ]),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (stepIdx + 1) / steps.length,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation(LP.purple),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          Row(children: steps.asMap().entries.map((e) {
            final done = e.key <= stepIdx;
            return Expanded(child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              height: 3,
              decoration: BoxDecoration(
                color: done ? LP.purple : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ));
          }).toList()),
        ]),
      ),
    );
  }
}

class _ScanBtn extends StatelessWidget {
  final IconData icon; final String label, subtitle; final Color color; final VoidCallback? onTap;
  const _ScanBtn({required this.icon, required this.label, required this.subtitle, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.38), color.withValues(alpha: 0.18)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
              boxShadow: [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 6))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 26)),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
              Text(subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 10)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final ScannedDocument doc; final VoidCallback onTap;
  const _DocTile({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasOcr = doc.ocrText?.isNotEmpty == true;
    final cfg = AppTheme.getCardConfig(_docTypeId(doc.docType));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.all(13),
          child: Row(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10),
              child: SizedBox(width: 52, height: 52,
                child: Image.file(File(doc.imagePath), fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: cfg.glow.withValues(alpha: 0.2),
                    child: Icon(cfg.icon, color: cfg.glow, size: 24))))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(doc.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(doc.docType.label,
                style: TextStyle(color: cfg.glow, fontSize: 10, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              if (hasOcr)
                Text(doc.ocrText!, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: LP.label3, fontSize: 10))
              else
                const Text('Kein Text erkannt', style: TextStyle(color: LP.label3, fontSize: 10)),
            ])),
            Column(children: [
              GlassBadge(label: hasOcr ? 'OCR ✓' : 'Kein Text',
                color: hasOcr ? AppTheme.green : LP.label3),
              const SizedBox(height: 6),
              if (doc.tasks.isNotEmpty)
                GlassBadge(label: '${doc.tasks.length} Aufg.', color: AppTheme.coral),
              const SizedBox(height: 6),
              const Icon(Icons.chevron_right_rounded, color: LP.label3, size: 18),
            ]),
          ]),
        ),
      ),
    );
  }

  String _docTypeId(DocType t) {
    switch (t) {
      case DocType.invoice: return 'tasks';
      case DocType.govLetter: return 'categories';
      case DocType.contract: return 'categories';
      case DocType.insurance: return 'categories';
      case DocType.appointment: return 'tasks';
      case DocType.form: return 'ai';
      default: return 'scan';
    }
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onScan;
  const _EmptyState({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: LP.purple.withValues(alpha: 0.1), shape: BoxShape.circle,
          border: Border.all(color: LP.purple.withValues(alpha: 0.2), width: 1)),
        child: const Icon(Icons.document_scanner_outlined, color: LP.purple, size: 44)),
      const SizedBox(height: 16),
      const Text('Noch keine Dokumente', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      const SizedBox(height: 6),
      const Text('Kamera oder Galerie verwenden', style: TextStyle(color: LP.label3, fontSize: 12)),
      const SizedBox(height: 20),
      GestureDetector(onTap: onScan,
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(color: LP.purple, borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: LP.purple.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))]),
          child: const Text('Erstes Dokument scannen',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)))),
    ]));
  }
}
