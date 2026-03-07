import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PartnerIntegrationCard extends StatelessWidget {
  final String category; // moving, insurance, utilities
  const PartnerIntegrationCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: LN.surface3.withOpacity(0.3),
        borderRadius: LN.r24,
        border: Border.all(color: LN.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RECOMMENDED SERVICES', style: LN.label),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(backgroundColor: LN.primary, child: Icon(Icons.handshake, color: Colors.white)),
            title: Text('Compare $category offers', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Save up to 20% with LifeNav partners'),
            trailing: const Icon(Icons.open_in_new, size: 18, color: LN.label3),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
