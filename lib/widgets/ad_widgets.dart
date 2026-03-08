import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: LN.surface2,
      child: const Center(
        child: Text('Advertisement'),
      ),
    );
  }
}