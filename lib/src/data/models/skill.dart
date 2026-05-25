enum SkillLevel { beginner, intermediate, advanced }

class Skill {
  const Skill({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.ownerId,
  });

  final String id;
  final String title;
  final String category;
  final SkillLevel level;
  final String description;
  final String ownerId;
}
