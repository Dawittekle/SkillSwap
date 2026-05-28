import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/src/data/models/skill.dart' as ui_skill;
import 'package:skill_swap/src/data/models/student.dart';

ui_skill.Skill uiSkillFromFirestore(firestore_skill.Skill skill) {
  final exchangeTags = [
    skill.category,
    skill.level,
    if (skill.exchangeFor.trim().isNotEmpty) skill.exchangeFor,
  ];

  return ui_skill.Skill(
    id: skill.id,
    title: skill.title,
    category: skill.category,
    level: uiSkillLevelFromText(skill.level),
    description: skill.description,
    ownerId: skill.ownerId,
    duration: 'Flexible',
    meetingFormat: 'Campus or online',
    outcomes: [
      'Practice ${skill.title}',
      if (skill.exchangeFor.trim().isNotEmpty) 'Swap for ${skill.exchangeFor}',
      'Learn with another student',
    ],
    tags: exchangeTags,
  );
}

ui_skill.SkillLevel uiSkillLevelFromText(String level) {
  return switch (level.trim().toLowerCase()) {
    'advanced' => ui_skill.SkillLevel.advanced,
    'intermediate' => ui_skill.SkillLevel.intermediate,
    _ => ui_skill.SkillLevel.beginner,
  };
}

Student studentFromSkillOwner(firestore_skill.Skill skill, {AppUser? user}) {
  return Student(
    id: skill.ownerId,
    name: user?.fullName.isNotEmpty == true ? user!.fullName : skill.ownerName,
    school: user?.university.isNotEmpty == true
        ? user!.university
        : skill.university,
    year: user?.year ?? '',
    bio: user?.bio ?? '',
    teaches: const [],
    wantsToLearn: const [],
    rating: user?.rating ?? 0,
    reviewCount: user?.completedSwaps ?? 0,
    matchPercent: 0,
  );
}
