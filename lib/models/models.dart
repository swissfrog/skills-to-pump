class SkillCategory {
  final String id;
  final String title;
  final String icon;
  final String color;

  const SkillCategory({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
  });
}

class Skill {
  final String id;
  final String title;
  final SkillCategory category;
  final String description;
  final int lessonCount;
  final bool isUnlocked;

  const Skill({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.lessonCount,
    this.isUnlocked = true,
  });
}

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final int order;
  final bool isUnlocked;
  final bool isCompleted;

  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.order,
    this.isUnlocked = false,
    this.isCompleted = false,
  });
}

class Stage {
  final int number;
  final String label;
  final bool isCompleted;
  final bool isCurrent;

  const Stage({
    required this.number,
    required this.label,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}
