import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const LifeNavApp());
}

class LifeNavApp extends StatelessWidget {
  const LifeNavApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'LifeNav',
    theme: LN.theme,
    debugShowCheckedModeBanner: false,
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LN.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.explore, size: 80, color: LN.primary),
            const SizedBox(height: 24),
            Text('LifeNav', style: LN.h2),
            const SizedBox(height: 16),
            const Text('App loaded!', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}