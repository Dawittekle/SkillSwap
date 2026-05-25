import 'package:skill_swap/src/data/models/skill.dart';

const mockSkills = [
  Skill(
    id: 'python-beginners',
    title: 'Python for Beginners',
    category: 'Tech',
    level: SkillLevel.intermediate,
    description:
        'Master data types, loops, functions, and simple automation projects.',
    ownerId: 'selam',
  ),
  Skill(
    id: 'ui-design-basics',
    title: 'UI Design Basics',
    category: 'Creative',
    level: SkillLevel.beginner,
    description:
        'Learn Figma fundamentals and mobile layout thinking from scratch.',
    ownerId: 'hana',
  ),
  Skill(
    id: 'calculus-two',
    title: 'Calculus II',
    category: 'Academic',
    level: SkillLevel.advanced,
    description:
        'Practice integration techniques, series, and exam problem solving.',
    ownerId: 'marcus',
  ),
];
