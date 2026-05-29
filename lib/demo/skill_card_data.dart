enum SkillCardLevel { beginner, intermediate, advanced }

class SkillCardData {
  const SkillCardData({
    required this.id,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.ownerId,
    required this.duration,
    required this.meetingFormat,
    required this.outcomes,
    required this.tags,
  });

  final String id;
  final String title;
  final String category;
  final SkillCardLevel level;
  final String description;
  final String ownerId;
  final String duration;
  final String meetingFormat;
  final List<String> outcomes;
  final List<String> tags;
}
