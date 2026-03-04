import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/app_theme.dart';

class ScannedDocument {
  final String id;
  final String name;
  final String imagePath;
  final DateTime scannedAt;

  ScannedDocument({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.scannedAt,
  });
}

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final DocumentScanner _documentScanner = DocumentScanner();
  final List<ScannedDocument> _documents = [];
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _loadDocuments();
  }

  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.storage.request();
  }

  Future<void> _loadDocuments() async {
    // Load previously saved documents
    final directory = await getApplicationDocumentsDirectory();
    final docDir = Directory('${directory.path}/scanned_documents');
    if (await docDir.exists()) {
      final files = docDir.listSync();
      for (var file in files) {
        if (file is File && file.path.endsWith('.jpg')) {
          final name = file.path.split('/').last.replaceAll('.jpg', '');
          _documents.add(ScannedDocument(
            id: file.path,
            name: name,
            imagePath: file.path,
            scannedAt: file.statSync().modified,
          ));
        }
      }
      setState(() {});
    }
  }

  Future<void> _scanDocument() async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
    });

    try {
      final DocumentScannerOptions options = DocumentScannerOptions(
        documentFormat: DocumentFormat.jpeg,
        mode: ScannerMode.filter,
        isGalleryImportEnabled: true,
      );

      final scannedDocs = await _documentScanner.scanDocument(options);
      
      if (scannedDocs.isNotEmpty) {
        final directory = await getApplicationDocumentsDirectory();
        final docDir = Directory('${directory.path}/scanned_documents');
        if (!await docDir.exists()) {
          await docDir.create(recursive: true);
        }

        for (var doc in scannedDocs) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'document_$timestamp.jpg';
          final newPath = '${docDir.path}/$fileName';
          
          // Copy the scanned image to our app directory
          final imageFile = File(doc.images.first);
          await imageFile.copy(newPath);

          setState(() {
            _documents.add(ScannedDocument(
              id: newPath,
              name: 'Dokument ${_documents.length + 1}',
              imagePath: newPath,
              scannedAt: DateTime.now(),
            ));
          });
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${scannedDocs.length} Dokument(e) gescannt!'),
              backgroundColor: AppTheme.turquoise,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Scannen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  Future<void> _deleteDocument(ScannedDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dokument löschen?'),
        content: Text('Möchtest du "${doc.name}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await File(doc.imagePath).delete();
      setState(() {
        _documents.removeWhere((d) => d.id == doc.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dokumente scannen'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scan button
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: _isScanning ? null : _scanDocument,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.purple, AppTheme.turquoise],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.purple.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    if (_isScanning)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      const Icon(
                        Icons.document_scanner,
                        size: 48,
                        color: Colors.white,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      _isScanning ? 'Scanne...' : 'Dokument scannen',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tippen um zu starten',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Documents header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.folder, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Archivierte Dokumente (${_documents.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Documents list
          Expanded(
            child: _documents.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Noch keine Dokumente',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Scanne dein erstes Dokument!',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[_documents.length - 1 - index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(doc.imagePath),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: AppTheme.darkCardLocked,
                                child: const Icon(Icons.image, color: AppTheme.textSecondary),
                              ),
                            ),
                          ),
                          title: Text(
                            doc.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            _formatDate(doc.scannedAt),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => _deleteDocument(doc),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
