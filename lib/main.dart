import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/upload_screen.dart';
import 'screens/profile_screen.dart';

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
    initialRoute: '/',
    routes: {
      '/': (context) => const SplashScreen(),
      '/home': (context) => const MainNavigator(),
    },
  );
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _idx = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const TasksScreen(),
    const CategoriesScreen(),
    const UploadScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _idx, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: LN.surface,
        selectedItemColor: LN.primary,
        unselectedItemColor: LN.label3,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), activeIcon: Icon(Icons.check_circle), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), activeIcon: Icon(Icons.description), label: 'Documents'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
