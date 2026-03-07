import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        // Collect all unique docs from all tasks
        final allDocs = store.events
            .expand((e) => e.tasks)
            .expand((t) => t.requiredDocs)
            .toSet()
            .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Documents')),
          body: allDocs.isEmpty
              ? _EmptyDocs()
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: allDocs.length,
                  itemBuilder: (context, i) => _DocTile(name: allDocs[i]),
                ),
        );
      },
    );
  }
}

class _DocTile extends StatelessWidget {
  final String name;
  const _DocTile({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LN.surface,
        borderRadius: LN.r16,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: LN.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.description, color: LN.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: LN.body.copyWith(fontWeight: FontWeight.w600)),
                const Text('Missing', style: TextStyle(color: LN.danger, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {}, 
            icon: const Icon(Icons.file_upload_outlined, color: LN.label3)
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
