import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final ImagePicker _picker = ImagePicker();
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
    await Permission.photos.request();
  }

  Future<void> _loadDocuments() async {
    try {
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
    } catch (e) {
      debugPrint('Error loading documents: $e');
    }
  }

  Future<void> _scanDocument({required ImageSource source}) async {
    if (_isScanning) return;
    
    setState(() {
      _isScanning = true;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );
      
      if (image != null) {
        final directory = await getApplicationDocumentsDirectory();
        final docDir = Directory('${directory.path}/scanned_documents');
        if (!await docDir.exists()) {
          await docDir.create(recursive: true);
        }

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final fileName = 'document_$timestamp.jpg';
        final newPath = '${docDir.path}/$fileName';
        
        // Copy the image to our app directory
        final imageFile = File(image.path);
        await imageFile.copy(newPath);

        setState(() {
          _documents.add(ScannedDocument(
            id: newPath,
            name: 'Dokument ${_documents.length + 1}',
            imagePath: newPath,
            scannedAt: DateTime.now(),
          ));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Dokument erfolgreich gescannt!'),
              backgroundColor: AppTheme.turquoise,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler: $e'),
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

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Dokument scannen',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.purple,
                child: Icon(Icons.camera_alt, color: Colors.white),
              ),
              title: const Text('Kamera'),
              subtitle: const Text('Mit der Kamera aufnehmen'),
              onTap: () {
                Navigator.pop(context);
                _scanDocument(source: ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppTheme.turquoise,
                child: Icon(Icons.photo_library, color: Colors.white),
              ),
              title: const Text('Galerie'),
              subtitle: const Text('Aus der Galerie wählen'),
              onTap: () {
                Navigator.pop(context);
                _scanDocument(source: ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
      try {
        await File(doc.imagePath).delete();
        setState(() {
          _documents.removeWhere((d) => d.id == doc.id);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fehler beim Löschen: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
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
              onTap: _isScanning ? null : _showSourcePicker,
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
