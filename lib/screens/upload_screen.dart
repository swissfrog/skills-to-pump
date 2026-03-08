import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../theme/app_theme.dart';
import '../services/life_store.dart';
import '../services/doc_store.dart';
import 'scan_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isUploading ? null : _showSourceDialog,
        icon: Icon(isUploading ? Icons.hourglass_empty : Icons.add_photo_alternate),
        label: Text(isUploading ? 'Uploading...' : 'Add Document'),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([LifeStore(), DocStore()]),
        builder: (context, _) {
          final allDocs = LifeStore().events
              .expand((e) => e.tasks)
              .expand((t) => t.requiredDocs)
              .toSet()
              .toList();
          
          if (allDocs.isEmpty) return _EmptyState();

          return RefreshIndicator(
            onRefresh: () async {},
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: allDocs.length,
              itemBuilder: (context, i) => _DocTile(docName: allDocs[i]),
            ),
          );
        },
      ),
    );
  }

  Future<void> _showSourceDialog() async {
    if (!mounted) return;
    final result = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (_) => _SourceDialog(),
    );
    if (result != null && mounted) _uploadImage(result);
  }

  Future<void> _uploadImage(ImageSource source) async {
    if (!mounted) return;
    setState(() => isUploading = true);
    try {
      final picker = ImagePicker();
      final xfile = await picker.pickImage(source: source);
      if (!mounted) return;
      if (xfile != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Document uploaded!')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isUploading = false);
      }
    }
  }
}

class _SourceDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
          leading: const Icon(Icons.photo_library),
          title: const Text('Gallery'),
          onTap: () => Navigator.pop(context, ImageSource.gallery),
        ),
        ListTile(
          leading: const Icon(Icons.camera_alt),
          title: const Text('Camera'),
          onTap: () => Navigator.pop(context, ImageSource.camera),
        ),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/animations/empty.json', width: 150), // Füge Animation hinzu
          const Text('No documents needed', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Start a Life Event!', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

// _DocTile widget for document list
class _DocTile extends StatelessWidget {
  final String docName;
  const _DocTile({required this.docName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.description),
        title: Text(docName),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
