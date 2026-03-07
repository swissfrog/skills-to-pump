import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LN.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg', width: 120, height: 120),
            const SizedBox(height: 24),
            Text('LifeNav', style: LN.h1.copyWith(color: Colors.white, fontSize: 32)),
            const SizedBox(height: 8),
            Text('Life Organizer', style: LN.body.copyWith(color: Colors.white70, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
