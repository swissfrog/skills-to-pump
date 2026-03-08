import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../models/models.dart';
import '../services/life_store.dart';
import '../services/doc_store.dart';
import 'scan_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();
    final docStore = DocStore();

    return ListenableBuilder(
      listenable: Listenable.merge([store, docStore]),
      builder: (context, _) {
        final allDocs = store.events
            .expand((e) => e.tasks)
            .expand((t) => t.requiredDocs)
            .toSet()
            .toList();
        final uploadedFor = docStore.docs
            .where((d) => d.linkedRequiredDoc != null)
            .map((d) => d.linkedRequiredDoc!)
            .toSet();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Documents'),
            actions: [
              IconButton(
                icon: const Icon(Icons.document_scanner_outlined),
                tooltip: 'Dokument scannen (OCR)',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                ),
              ),
            ],
          ),
          body: allDocs.isEmpty
              ? _EmptyDocs()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: allDocs.length,
                  itemBuilder: (context, i) => _DocTile(
                    name: allDocs[i],
                    isUploaded: uploadedFor.contains(allDocs[i]),
                    onUpload: () => _pickAndSaveImage(context, allDocs[i], docStore),
                  ),
                ),
        );
      },
    );
  }

  static Future<void> _pickAndSaveImage(
    BuildContext context,
    String requiredDocName,
    DocStore docStore,
  ) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery);
    if (xFile == null || !context.mounted) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final docsDir = Directory(path.join(dir.path, 'scanned_docs'));
      if (!await docsDir.exists()) await docsDir.create(recursive: true);

      final ext = path.extension(xFile.path).isEmpty ? '.jpg' : path.extension(xFile.path);
      final fileName = 'doc_${DateTime.now().millisecondsSinceEpoch}$ext';
      final destPath = path.join(docsDir.path, fileName);
      await File(xFile.path).copy(destPath);

      final doc = ScannedDocument(
        id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
        name: requiredDocName,
        imagePath: destPath,
        scannedAt: DateTime.now(),
        linkedRequiredDoc: requiredDocName,
      );
      docStore.addDocument(doc);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$requiredDocName hochgeladen'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: LN.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: LN.danger,
          ),
        );
      }
    }
  }
}

class _DocTile extends StatelessWidget {
  final String name;
  final bool isUploaded;
  final VoidCallback onUpload;

  const _DocTile({
    required this.name,
    required this.isUploaded,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LN.surface,
        borderRadius: LN.r16,
        border: isUploaded ? Border.all(color: LN.success.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isUploaded ? LN.success : LN.primary).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUploaded ? Icons.check_circle : Icons.description,
              color: isUploaded ? LN.success : LN.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: LN.body.copyWith(fontWeight: FontWeight.w600)),
                Text(
                  isUploaded ? 'Hochgeladen' : 'Fehlt',
                  style: TextStyle(
                    color: isUploaded ? LN.success : LN.danger,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: isUploaded ? null : onUpload,
            icon: Icon(
              isUploaded ? Icons.check : Icons.file_upload_outlined,
              color: isUploaded ? LN.success : LN.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyDocs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open, size: 64, color: LN.label3.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text('No documents required yet', style: LN.bodySmall),
          const SizedBox(height: 8),
          const Text('Start a Life Event to see required docs.', style: TextStyle(color: LN.label3, fontSize: 12)),
        ],
      ),
    );
  }
}
