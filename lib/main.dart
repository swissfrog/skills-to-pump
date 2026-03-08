import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/goals_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/settings_screen.dart';

// ──────────────────────────────────────────────────────────
// Entry Point
// ──────────────────────────────────────────────────────────
void main() async {
 WidgetsFlutterBinding.ensureInitialized();

 SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
 SystemChrome.setSystemUIOverlayStyle(
 const SystemUiOverlayStyle(
 statusBarColor: Colors.transparent,
 statusBarIconBrightness: Brightness.light,
 systemNavigationBarColor: Colors.transparent,
 systemNavigationBarIconBrightness: Brightness.light,
 ),
 );

 // Global flutter_animate default
 Animate.restartOnHotReload = true;

 runApp(const ProviderScope(child: LifeNavApp()));
}

// ──────────────────────────────────────────────────────────
// Router Definition
// ──────────────────────────────────────────────────────────
final _router = GoRouter(
 initialLocation: '/',
 debugLogDiagnostics: false,
 routes: [
 ShellRoute(
 builder: (context, state, child) => _MainShell(
 location: state.matchedLocation,
 child: child,
 ),
 routes: [
 GoRoute(
 path: '/',
 pageBuilder: (_, __) =>
 const NoTransitionPage(child: HomeScreen()),
 ),
 GoRoute(
 path: '/goals',
 pageBuilder: (_, __) =>
 const NoTransitionPage(child: GoalsScreen()),
 ),
 GoRoute(
 path: '/journal',
 pageBuilder: (_, __) =>
 const NoTransitionPage(child: JournalScreen()),
 ),
 GoRoute(
 path: '/settings',
 pageBuilder: (_, __) =>
 const NoTransitionPage(child: SettingsScreen()),
 ),
 ],
 ),
 // Full-screen — no bottom nav
 GoRoute(
 path: '/upload',
 builder: (_, __) => const UploadScreen(),
 ),
 ],
);

// ──────────────────────────────────────────────────────────
// App Root
// ──────────────────────────────────────────────────────────
class LifeNavApp extends StatelessWidget {
 const LifeNavApp({super.key});

 @override
 Widget build(BuildContext context) {
 return MaterialApp.router(
 title: 'LifeNav',
 debugShowCheckedModeBanner: false,
 theme: AppTheme.dark,
 routerConfig: _router,
 );
 }
}

// ──────────────────────────────────────────────────────────
// Shell — Persistent Bottom Navigation
// ──────────────────────────────────────────────────────────
class _MainShell extends StatelessWidget {
 final String location;
 final Widget child;

 const _MainShell({required this.location, required this.child});

 int get _selectedIndex {
 if (location.startsWith('/goals')) return 1;
 if (location.startsWith('/journal')) return 2;
 if (location.startsWith('/settings')) return 3;
 return 0;
 }

 void _onTap(BuildContext ctx, int i) {
 const routes = ['/', '/goals', '/journal', '/settings'];
 if (i != _selectedIndex) ctx.go(routes[i]);
 }

 @override
 Widget build(BuildContext context) {
 return Scaffold(
 body: child,
 // ── Upload FAB (center) ──────────────────────────
 floatingActionButton: FloatingActionButton.extended(
 onPressed: () => context.push('/upload'),
 icon: const Icon(Icons.document_scanner_rounded),
 label: const Text('Scan'),
 elevation: 0,
 ),
 floatingActionButtonLocation:
 FloatingActionButtonLocation.centerDocked,

 // ── Bottom Navigation ────────────────────────────
 bottomNavigationBar: NavigationBar(
 selectedIndex: _selectedIndex,
 onDestinationSelected: (i) => _onTap(context, i),
 destinations: const [
 NavigationDestination(
 icon: Icon(Icons.home_outlined),
 selectedIcon: Icon(Icons.home_rounded),
 label: 'Home',
 ),
 NavigationDestination(
 icon: Icon(Icons.flag_outlined),
 selectedIcon: Icon(Icons.flag_rounded),
 label: 'Ziele',
 ),
 NavigationDestination(
 icon: Icon(Icons.book_outlined),
 selectedIcon: Icon(Icons.book_rounded),
 label: 'Journal',
 ),
 NavigationDestination(
 icon: Icon(Icons.settings_outlined),
 selectedIcon: Icon(Icons.settings_rounded),
 label: 'Settings',
 ),
 ],
 ),
 );
 }
}
