import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 64, color: LN.highlight),
            SizedBox(height: 16),
            Text('Premium Features', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Upgrade to unlock all features'),
          ],
        ),
      ),
    );
  }
}