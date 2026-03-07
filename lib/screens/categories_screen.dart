import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/life_models.dart';
import '../services/life_store.dart';
import 'doc_detail_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Life Events')),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: LifeEventType.values.map((type) => _EventCard(type: type)).toList(),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final LifeEventType type;
  const _EventCard({required this.type});

  @override
  Widget build(BuildContext context) {
    final store = LifeStore();
    final color = LN.colorForEvent(type);
    final isActive = store.hasEvent(type);

    return GestureDetector(
      onTap: () {
        if (!isActive) {
          store.startEvent(type);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${type.label} gestartet!')),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: LN.surface,
          borderRadius: LN.r24,
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 2,
          ),
          boxShadow: isActive ? LN.shadow(color) : LN.shadow(),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LN.iconForEvent(type), color: color, size: 40),
            const SizedBox(height: 12),
            Text(type.label, style: LN.h3, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(isActive ? 'Aktiv' : 'Verfügbar', 
              style: LN.bodySmall.copyWith(color: isActive ? color : LN.label3)),
          ],
        ),
      ),
    );
  }
}
