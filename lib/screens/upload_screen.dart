import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../theme/app_theme.dart';

enum _Status { idle, picking, processing, done, error }

class _ScanResult {
  final File imageFile;
  final String rawText;
  final String assignedEvent;
  const _ScanResult({required this.imageFile, required this.rawText, required this.assignedEvent});
}

class _UploadState {
  final _Status status;
  final File? image;
  final String? text;
  final String? error;
  final List<_ScanResult> history;
  const _UploadState({this.status = _Status.idle, this.image, this.text, this.error, this.history = const []});
  _UploadState copyWith({_Status? status, File? image, String? text, String? error, List<_ScanResult>? history}) => _UploadState(status: status ?? this.status, image: image ?? this.image, text: text ?? this.text, error: error ?? this.error, history: history ?? this.history);
}

class _UploadNotifier extends StateNotifier<_UploadState> {
  _UploadNotifier() : super(const _UploadState());
  final _picker = ImagePicker();
  final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<void> pickCamera() => _run(ImageSource.camera);
  Future<void> pickGallery() => _run(ImageSource.gallery);

  Future<void> _run(ImageSource src) async {
    try {
      state = state.copyWith(status: _Status.picking);
      final picked = await _picker.pickImage(source: src, imageQuality: 88, maxWidth: 2000);
      if (picked == null) { state = state.copyWith(status: _Status.idle); return; }
      final file = File(picked.path);
      state = state.copyWith(status: _Status.processing, image: file, text: null, error: null);
      final inputImage = InputImage.fromFile(file);
      final result = await _recognizer.processImage(inputImage);
      final raw = result.text.trim();
      final event = _autoAssign(raw);
      final saved = await _save(file);
      state = state.copyWith(status: _Status.done, text: raw.isEmpty ? '(Kein Text erkannt)' : raw, history: [_ScanResult(imageFile: saved, rawText: raw, assignedEvent: event), ...state.history]);
    } catch (e) { state = state.copyWith(status: _Status.error, error: e.toString()); }
  }

  String _autoAssign(String text) {
    final t = text.toLowerCase();
    if (t.contains('zeugnis') || t.contains('arbeit') || t.contains('bewerbung')) return 'Neue Stelle';
    if (t.contains('miet') || t.contains('wohnung') || t.contains('kaution')) return 'Wohnung mieten';
    if (t.contains('konto') || t.contains('iban') || t.contains('bank')) return 'Konto eröffnen';
    if (t.contains('versicherung') || t.contains('krankenkasse')) return 'Krankenversicherung';
    return 'Nicht zugewiesen';
  }

  Future<File> _save(File src) async {
    final dir = await getApplicationDocumentsDirectory();
    final dest = '${dir.path}/scans/${DateTime.now().millisecondsSinceEpoch}.jpg';
    await Directory('${dir.path}/scans').create(recursive: true);
    return src.copy(dest);
  }

  void reset() => state = const _UploadState();
  @override void dispose() { _recognizer.close(); super.dispose(); }
}

final _uploadProvider = StateNotifierProvider<_UploadNotifier, _UploadState>((_) => _UploadNotifier());

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});
  static const _bg = Color(0xFF0F1115);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(_uploadProvider);
    final loading = s.status == _Status.picking || s.status == _Status.processing;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg, surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.of(context).maybePop()),
        title: Text('Dokument scannen', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        actions: [if (s.status == _Status.done) TextButton(onPressed: () => ref.read(_uploadProvider.notifier).reset(), child: Text('Neu', style: GoogleFonts.inter(color: AppTheme.primary, fontWeight: FontWeight.w600))), const Gap(8)],
      ),
      body: AnimatedSwitcher(duration: const Duration(milliseconds: 380), switchInCurve: Curves.easeOutCubic, switchOutCurve: Curves.easeInCubic, child: switch (s.status) { _Status.idle => const _IdleView(key: ValueKey('idle')), _Status.picking => const _LoadingView(key: ValueKey('pick'), label: 'Bild wird geladen…'), _Status.processing => const _LoadingView(key: ValueKey('proc'), label: 'OCR wird ausgeführt…'), _Status.done => _ResultView(key: const ValueKey('done'), state: s), _Status.error => _ErrorView(key: const ValueKey('err'), message: s.error ?? 'Unbekannter Fehler') }),
      bottomNavigationBar: _BottomBar(loading: loading),
    );
  }
}

class _BottomBar extends ConsumerWidget {
  final bool loading; const _BottomBar({required this.loading});
  static const _card = Color(0xFF1B1F27);
  @override Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 20),
      decoration: const BoxDecoration(color: _card, border: Border(top: BorderSide(color: Color(0xFF252B36)))),
      child: Row(children: [
        Expanded(child: OutlinedButton.icon(onPressed: loading ? null : () => ref.read(_uploadProvider.notifier).pickGallery(), icon: const Icon(Icons.photo_library_rounded, size: 18), label: const Text('Galerie'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)))),
        const Gap(14),
        Expanded(flex: 2, child: FilledButton.icon(onPressed: loading ? null : () => ref.read(_uploadProvider.notifier).pickCamera(), icon: loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.camera_alt_rounded, size: 18), label: Text(loading ? 'Verarbeitung…' : 'Kamera'), style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, disabledBackgroundColor: AppTheme.primary.withOpacity(.4), disabledForegroundColor: Colors.white.withOpacity(.6), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600))))
      ]),
    );
  }
}

class _IdleView extends StatelessWidget {
  const _IdleView({super.key});
  @override Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const _DropZone(), const Gap(28),
        Text('Unterstützte Formate', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)), const Gap(14), const _FormatsRow(),
        const Gap(28), Text('Letzte Scans', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)), const Gap(14), const _EmptyHistory(),
      ]).animate().fadeIn(duration: 350.ms).slideY(begin: .04),
    );
  }
}

class _DropZone extends StatelessWidget {
  const _DropZone();
  static const _card = Color(0xFF1B1F27);
  @override Widget build(BuildContext context) {
    return Container(width: double.infinity, height: 200, decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.primary.withOpacity(.4), width: 1.5)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.10), shape: BoxShape.circle), child: const Icon(Icons.upload_file_rounded, color: AppTheme.primary, size: 36)),
        const Gap(16), Text('Dokument hier ablegen', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        const Gap(6), Text('JPEG · PNG · PDF · HEIC', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF6B7280))),
      ]),
    );
  }
}

class _FormatsRow extends StatelessWidget {
  const _FormatsRow();
  @override Widget build(BuildContext context) {
    final formats = [(icon: Icons.picture_as_pdf_rounded, label: 'PDF', color: AppTheme.tertiary), (icon: Icons.image_rounded, label: 'JPEG', color: AppTheme.primary), (icon: Icons.image_rounded, label: 'PNG', color: AppTheme.secondary), (icon: Icons.phone_iphone_rounded, label: 'HEIC', color: AppTheme.amber)];
    return Row(children: List.generate(formats.length, (i) { final f = formats[i]; return Expanded(child: Container(margin: EdgeInsets.only(right: i < formats.length - 1 ? 10 : 0), padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: f.color.withOpacity(.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: f.color.withOpacity(.18))), child: Column(children: [Icon(f.icon, color: f.color, size: 22), const Gap(6), Text(f.label, style: GoogleFonts.inter(fontSize: 12, color: f.color, fontWeight: FontWeight.w600))]))); }));
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();
  static const _card = Color(0xFF1B1F27);
  @override Widget build(BuildContext context) { return Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF252B36))), child: Column(children: [const Icon(Icons.history_rounded, color: Color(0xFF3D4450), size: 36), const Gap(12), Text('Noch keine Scans vorhanden', style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280)))])); }
}

class _LoadingView extends StatelessWidget {
  final String label; const _LoadingView({super.key, required this.label});
  @override Widget build(BuildContext context) { return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 3), const Gap(24), Text(label, style: GoogleFonts.inter(fontSize: 16, color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500))]).animate().fadeIn(duration: 300.ms)); }
}

class _ResultView extends ConsumerWidget {
  final _UploadState state; const _ResultView({super.key, required this.state});
  static const _card = Color(0xFF1B1F27);
  @override Widget build(BuildContext context, WidgetRef ref) {
    final img = state.image; final text = state.text ?? ''; final event = state.history.isNotEmpty ? state.history.first.assignedEvent : '—';
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), physics: const BouncingScrollPhysics(), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (img != null) ClipRRect(borderRadius: BorderRadius.circular(18), child: Image.file(img, width: double.infinity, height: 220, fit: BoxFit.cover)).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(.96, .96)),
      const Gap(20),
      Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: AppTheme.green.withOpacity(.10), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.green.withOpacity(.25))), child: Row(children: [const Icon(Icons.auto_awesome_rounded, color: AppTheme.green, size: 18), const Gap(10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Automatisch zugewiesen', style: GoogleFonts.inter(fontSize: 11, color: AppTheme.green, fontWeight: FontWeight.w600)), Text(event, style: GoogleFonts.inter(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700))])), TextButton(onPressed: () => _showEventPicker(context, ref), child: Text('Ändern', style: GoogleFonts.inter(color: AppTheme.primary, fontSize: 13, fontWeight: FontWeight.w600)))])),
      const Gap(20),
      Text('Erkannter Text', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)), const Gap(10),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), constraints: const BoxConstraints(maxHeight: 260), decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF252B36))), child: SingleChildScrollView(physics: const BouncingScrollPhysics(), child: SelectableText(text, style: GoogleFonts.sourceCodePro(fontSize: 12.5, color: const Color(0xFFD1D5DB), height: 1.6)))),
      const Gap(20),
      Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => _copy(context, text), icon: const Icon(Icons.copy_rounded, size: 16), label: const Text('Kopieren'), style: OutlinedButton.styleFrom(foregroundColor: AppTheme.primary, side: const BorderSide(color: AppTheme.primary, width: 1.5), padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)))), const Gap(12), Expanded(child: FilledButton.icon(onPressed: () => _showSaveSheet(context, ref), icon: const Icon(Icons.save_alt_rounded, size: 16), label: const Text('Speichern'), style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600))))]),
    ]));
  }

  Future<void> _copy(BuildContext ctx, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text('Text kopiert', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF21262F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }
  void _showSaveSheet(BuildContext ctx, WidgetRef ref) { showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFF1B1F27), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 40), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF3D4450), borderRadius: BorderRadius.circular(2))), const Gap(24), const Icon(Icons.check_circle_rounded, color: AppTheme.green, size: 52), const Gap(16), Text('Dokument gespeichert', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)), const Gap(8), Text('Das Dokument wurde gespeichert und dem Life Event zugewiesen.', textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF6B7280))), const Gap(28), SizedBox(width: double.infinity, child: FilledButton(onPressed: () { Navigator.pop(ctx); ref.read(_uploadProvider.notifier).reset(); }, style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)), child: const Text('Weiteres Dokument scannen')))]))); }
  void _showEventPicker(BuildContext ctx, WidgetRef ref) { const events = ['Neue Stelle', 'Wohnung mieten', 'Konto eröffnen', 'Krankenversicherung', 'Nicht zugewiesen']; showModalBottomSheet(context: ctx, backgroundColor: const Color(0xFF1B1F27), shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (_) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 40), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Life Event auswählen', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)), const Gap(16), ...events.map((e) => ListTile(title: Text(e, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w500)), trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF6B7280)), onTap: () => Navigator.pop(ctx), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))))]))); }
}

class _ErrorView extends ConsumerWidget {
  final String message; const _ErrorView({super.key, required this.message});
  @override Widget build(BuildContext context, WidgetRef ref) { return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.tertiary.withOpacity(.10), shape: BoxShape.circle), child: const Icon(Icons.error_outline_rounded, color: AppTheme.tertiary, size: 44)), const Gap(20), Text('Etwas ist schiefgelaufen', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)), const Gap(10), Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF9CA3AF))), const Gap(28), FilledButton.icon(onPressed: () => ref.read(_uploadProvider.notifier).reset(), icon: const Icon(Icons.refresh_rounded), label: const Text('Erneut versuchen'), style: FilledButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))])).animate().fadeIn(duration: 350.ms)); }
}
