class Student {
  const Student({
    required this.id,
    required this.name,
    required this.school,
    required this.year,
    required this.bio,
    required this.teaches,
    required this.wantsToLearn,
    required this.rating,
    required this.reviewCount,
    required this.matchPercent,
  });

  final String id;
  final String name;
  final String school;
  final String year;
  final String bio;
  final List<String> teaches;
  final List<String> wantsToLearn;
  final double rating;
  final int reviewCount;
  final int matchPercent;
}
