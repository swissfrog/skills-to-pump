import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/skill_card.dart';
import '../screens/scan_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const HomeScreen({super.key, this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _lessonPlanSelected = true;

  final List<SkillCategory> _categories = const [
    SkillCategory(
      id: 'scan',
      title: 'Scannen',
      icon: 'camera',
      color: 'purple',
    ),
    SkillCategory(
      id: 'arsenal',
      title: 'Arsenal',
      icon: 'safe',
      color: 'coral',
    ),
    SkillCategory(
      id: 'coordination',
      title: 'Koordination',
      icon: 'joystick',
      color: 'turquoise',
    ),
    SkillCategory(
      id: 'songs',
      title: 'Songs',
      icon: 'turntable',
      color: 'yellow',
    ),
  ];

  void _onCategoryTap(SkillCategory category) {
    if (category.id == 'scan') {
      // Open scan screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanScreen()),
      );
    } else {
      // Show coming soon for other categories
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.title} kommt bald!'),
          backgroundColor: Colors.grey[800],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Skills To Pump!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // 2x2 Grid of skill cards
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return SkillCard(
                      category: _categories[index],
                      onTap: () => _onCategoryTap(_categories[index]),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Navigation row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: NavigationRow(
                  leftLabel: 'Lernplan',
                  rightLabel: 'Fortschritt',
                  leftSelected: _lessonPlanSelected,
                  onLeftTap: () => setState(() => _lessonPlanSelected = true),
                  onRightTap: () => setState(() => _lessonPlanSelected = false),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
