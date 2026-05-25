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
    duration: '60 min',
    meetingFormat: 'Online or campus lab',
    outcomes: [
      'Write clean Python basics',
      'Understand loops and functions',
      'Build one small automation script',
    ],
    tags: ['Python', 'Programming', 'Beginner friendly'],
  ),
  Skill(
    id: 'ui-design-basics',
    title: 'UI Design Basics',
    category: 'Creative',
    level: SkillLevel.beginner,
    description:
        'Learn Figma fundamentals and mobile layout thinking from scratch.',
    ownerId: 'hana',
    duration: '45 min',
    meetingFormat: 'Online screen share',
    outcomes: [
      'Create a simple mobile wireframe',
      'Use spacing and color tokens',
      'Prepare a clean handoff frame',
    ],
    tags: ['Figma', 'Mobile UI', 'Design'],
  ),
  Skill(
    id: 'calculus-two',
    title: 'Calculus II',
    category: 'Academic',
    level: SkillLevel.advanced,
    description:
        'Practice integration techniques, series, and exam problem solving.',
    ownerId: 'marcus',
    duration: '90 min',
    meetingFormat: 'Campus library',
    outcomes: [
      'Review integration patterns',
      'Solve series practice questions',
      'Plan exam revision steps',
    ],
    tags: ['Calculus', 'Exam prep', 'Math'],
  ),
  Skill(
    id: 'conversational-amharic',
    title: 'Conversational Amharic',
    category: 'Language',
    level: SkillLevel.advanced,
    description:
        'Practice pronunciation, common phrases, and everyday student conversation.',
    ownerId: 'selam',
    duration: '40 min',
    meetingFormat: 'Coffee chat',
    outcomes: [
      'Practice everyday greetings',
      'Improve pronunciation confidence',
      'Learn useful campus phrases',
    ],
    tags: ['Amharic', 'Speaking', 'Language'],
  ),
  Skill(
    id: 'guitar-basics',
    title: 'Guitar Basics',
    category: 'Music',
    level: SkillLevel.beginner,
    description:
        'Learn tuning, simple chords, and a first practice routine for beginners.',
    ownerId: 'marcus',
    duration: '50 min',
    meetingFormat: 'Campus common room',
    outcomes: [
      'Tune a guitar',
      'Play three beginner chords',
      'Follow a weekly practice routine',
    ],
    tags: ['Guitar', 'Music', 'Practice'],
  ),
];
