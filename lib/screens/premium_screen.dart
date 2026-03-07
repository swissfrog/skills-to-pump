import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/premium_service.dart';

class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LN.bg,
      appBar: AppBar(leading: const BackButton(color: Colors.white)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.auto_awesome, size: 80, color: LN.highlight),
            const SizedBox(height: 24),
            const Text('LifeNav Premium', style: LN.h1),
            const SizedBox(height: 8),
            Text('Upgrade for the full experience', style: LN.bodySmall.copyWith(color: LN.label2)),
            const SizedBox(height: 40),
            
            _FeatureRow(icon: Icons.psychology, title: 'AI Bureaucracy Assistant', desc: 'Ask complex legal and process questions.'),
            _FeatureRow(icon: Icons.notifications_active, title: 'Advanced Reminders', desc: 'Multi-stage alerts before important deadlines.'),
            _FeatureRow(icon: Icons.all_inclusive, title: 'Unlimited Events', desc: 'Manage as many life situations as you need.'),
            _FeatureRow(icon: Icons.cloud_upload, title: 'Document Storage', desc: 'Securely store and sync your important papers.'),
            _FeatureRow(icon: Icons.block, title: 'No Advertisements', desc: 'Focus on your tasks without any distractions.'),

            const SizedBox(height: 60),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: LN.surface,
                borderRadius: LN.r24,
                border: Border.all(color: LN.highlight.withOpacity(0.5), width: 2),
              ),
              child: Column(
                children: [
                  const Text('Monthly Plan', style: LN.h3),
                  const SizedBox(height: 8),
                  const Text('3,99 € / Month', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: LN.highlight)),
                  const SizedBox(height: 4),
                  const Text('Cancel anytime. Secure checkout.', style: TextStyle(fontSize: 12, color: LN.label3)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        PremiumService().upgrade();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Welcome to LifeNav Premium! 🚀'), backgroundColor: LN.success)
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LN.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: LN.r16),
                      ),
                      child: const Text('Subscribe Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe later', style: TextStyle(color: LN.label3))),
          ],
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon; final String title, desc;
  const _FeatureRow({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Icon(icon, color: LN.primary, size: 32),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(desc, style: LN.bodySmall),
              ],
            ),
          )
        ],
      ),
    );
  }
}
