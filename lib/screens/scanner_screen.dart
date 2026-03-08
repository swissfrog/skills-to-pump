import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: Text('Scanner', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 64, color: AppTheme.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Scanner', style: GoogleFonts.inter(color: Colors.white, fontSize: 20)),
            const SizedBox(height: 8),
            Text('Dokumente scannen...', style: GoogleFonts.inter(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
