import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/skill_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _lessonPlanSelected = true;

  final List<SkillCategory> _categories = const [
    SkillCategory(
      id: 'technique',
      title: 'Technique',
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
      title: 'Coordination',
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
                      onTap: () {
                        // Navigate to category detail
                      },
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
                  leftLabel: 'Lesson Plan',
                  rightLabel: 'Your Progress',
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          // Handle navigation
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
