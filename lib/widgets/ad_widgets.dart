import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/premium_service.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PremiumService(),
      builder: (context, _) {
        if (!PremiumService().showAds) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          height: 60,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: LN.surface2,
            border: Border.all(color: LN.divider),
          ),
          child: const Center(
            child: Text('ADVERTISEMENT', style: TextStyle(color: LN.label3, fontSize: 10, letterSpacing: 2)),
          ),
        );
      },
    );
  }
}
