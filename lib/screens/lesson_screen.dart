import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/lesson_card.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _currentStage = 2;

  final List<Stage> _stages = const [
    Stage(number: 1, label: 'Stage', isCompleted: true),
    Stage(number: 2, label: 'Stage', isCurrent: true),
    Stage(number: 3, label: 'Stage', isCompleted: false),
    Stage(number: 4, label: 'Stage', isCompleted: false),
  ];

  final List<Lesson> _lessons = const [
    Lesson(
      id: '1',
      title: 'Breaks. Good Place To Show Off',
      subtitle: '4th lesson',
      order: 4,
      isUnlocked: true,
      isCompleted: false,
    ),
    Lesson(
      id: '2',
      title: 'Break Inside The Rhythm',
      subtitle: '5th lesson',
      order: 5,
      isUnlocked: false,
    ),
    Lesson(
      id: '3',
      title: 'Advanced Breaks',
      subtitle: '6th lesson',
      order: 6,
      isUnlocked: false,
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
              // Stage progress navigation
              StageProgress(
                stages: _stages,
                onStageTap: (stage) {
                  setState(() {
                    _currentStage = stage;
                  });
                },
              ),
              const SizedBox(height: 24),
              // Lessons list
              Expanded(
                child: ListView.builder(
                  itemCount: _lessons.length,
                  itemBuilder: (context, index) {
                    return LessonCard(
                      lesson: _lessons[index],
                      onTap: () {
                        if (_lessons[index].isUnlocked) {
                          // Open lesson
                        }
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // More button
              const Center(
                child: MoreButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
