import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart';

class DemoSeedResult {
  const DemoSeedResult({
    required this.createdUsers,
    required this.skippedUsers,
    required this.createdSkills,
    required this.skippedSkills,
  });

  final int createdUsers;
  final int skippedUsers;
  final int createdSkills;
  final int skippedSkills;

  String get message {
    return 'Seed complete: $createdUsers users created, $skippedUsers users skipped, $createdSkills skills created, $skippedSkills skills skipped.';
  }
}

/// DEVELOPMENT-ONLY helper for the final demo.
///
/// This creates deterministic sample Firestore documents for Ethiopian student
/// profiles and offered skills. Remove this file and the debug button that
/// calls it before final submission or production release.
class DemoSeedService {
  DemoSeedService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection('users');
  }

  CollectionReference<Map<String, dynamic>> get _skills {
    return _firestore.collection('skills');
  }

  Future<DemoSeedResult> seedDemoData() async {
    var createdUsers = 0;
    var skippedUsers = 0;
    var createdSkills = 0;
    var skippedSkills = 0;

    for (final user in _demoUsers) {
      final created = await _createDocumentIfMissing(
        collection: _users,
        id: user.uid,
        data: user.toMap(),
      );

      if (created) {
        createdUsers++;
      } else {
        skippedUsers++;
      }
    }

    for (final skill in _demoSkills) {
      final created = await _createDocumentIfMissing(
        collection: _skills,
        id: skill.id,
        data: skill.toMap(),
      );

      if (created) {
        createdSkills++;
      } else {
        skippedSkills++;
      }
    }

    return DemoSeedResult(
      createdUsers: createdUsers,
      skippedUsers: skippedUsers,
      createdSkills: createdSkills,
      skippedSkills: skippedSkills,
    );
  }

  Future<bool> _createDocumentIfMissing({
    required CollectionReference<Map<String, dynamic>> collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    final document = collection.doc(id);
    final snapshot = await document.get();

    if (snapshot.exists) return false;

    await document.set(data);
    return true;
  }
}

final _seedDate = DateTime(2026, 5, 28);

final _demoUsers = [
  AppUser(
    uid: 'demo_beka',
    fullName: 'Beka',
    email: 'beka.demo@skillswap.local',
    university: 'Addis Ababa University',
    department: 'Software Engineering',
    year: '3rd Year',
    bio:
        'Software engineering student who enjoys building mobile apps and helping classmates debug projects.',
    campus: 'Sidist Kilo Campus',
    photoUrl: '',
    rating: 4.8,
    completedSwaps: 6,
    profileCompleted: true,
    createdAt: _seedDate,
  ),
  AppUser(
    uid: 'demo_hana',
    fullName: 'Hana',
    email: 'hana.demo@skillswap.local',
    university: 'AASTU',
    department: 'Architecture',
    year: '2nd Year',
    bio:
        'Architecture student interested in visual design, sketching, and presentation boards.',
    campus: 'AASTU Campus',
    photoUrl: '',
    rating: 4.7,
    completedSwaps: 4,
    profileCompleted: true,
    createdAt: _seedDate,
  ),
  AppUser(
    uid: 'demo_meron',
    fullName: 'Meron',
    email: 'meron.demo@skillswap.local',
    university: 'Addis Ababa University',
    department: 'Accounting',
    year: '4th Year',
    bio:
        'Accounting student who likes clear examples, spreadsheets, and practical study plans.',
    campus: 'FBE Campus',
    photoUrl: '',
    rating: 4.9,
    completedSwaps: 8,
    profileCompleted: true,
    createdAt: _seedDate,
  ),
  AppUser(
    uid: 'demo_abel',
    fullName: 'Abel',
    email: 'abel.demo@skillswap.local',
    university: 'ASTU',
    department: 'Mechanical Engineering',
    year: '3rd Year',
    bio:
        'Mechanical engineering student who can explain math and engineering basics step by step.',
    campus: 'ASTU Main Campus',
    photoUrl: '',
    rating: 4.6,
    completedSwaps: 5,
    profileCompleted: true,
    createdAt: _seedDate,
  ),
  AppUser(
    uid: 'demo_selam',
    fullName: 'Selam',
    email: 'selam.demo@skillswap.local',
    university: 'Bahir Dar University',
    department: 'English',
    year: '2nd Year',
    bio:
        'English student focused on speaking confidence, pronunciation, and friendly practice sessions.',
    campus: 'Peda Campus',
    photoUrl: '',
    rating: 4.8,
    completedSwaps: 7,
    profileCompleted: true,
    createdAt: _seedDate,
  ),
  AppUser(
    uid: 'demo_lamesgnew',
    fullName: 'Lamesgnew',
    email: 'lamesgnew.demo@skillswap.local',
    university: 'Bahir Dar University',
    department: 'English',
    year: '3rd Year',
    bio:
        'English student who enjoys public speaking, debate practice, and peer feedback.',
    campus: 'Peda Campus',
    photoUrl: '',
    rating: 4.7,
    completedSwaps: 3,
    profileCompleted: true,
    createdAt: _seedDate,
  ),
];

final _demoSkills = [
  Skill(
    id: 'demo_skill_flutter_app_development',
    ownerId: 'demo_beka',
    ownerName: 'Beka',
    ownerPhotoUrl: '',
    university: 'Addis Ababa University',
    title: 'Flutter App Development',
    category: 'Tech',
    level: 'Intermediate',
    description:
        'Build simple Flutter screens, use reusable widgets, and connect basic Firebase features.',
    type: 'offered',
    exchangeFor: 'Graphic Design or Public Speaking',
    isActive: true,
    createdAt: _seedDate,
  ),
  Skill(
    id: 'demo_skill_calculus_tutoring',
    ownerId: 'demo_abel',
    ownerName: 'Abel',
    ownerPhotoUrl: '',
    university: 'ASTU',
    title: 'Calculus Tutoring',
    category: 'Academic',
    level: 'Advanced',
    description:
        'Practice limits, derivatives, integration, and exam-style problem solving.',
    type: 'offered',
    exchangeFor: 'English Speaking',
    isActive: true,
    createdAt: _seedDate,
  ),
  Skill(
    id: 'demo_skill_guitar_basics',
    ownerId: 'demo_hana',
    ownerName: 'Hana',
    ownerPhotoUrl: '',
    university: 'AASTU',
    title: 'Guitar Basics',
    category: 'Music',
    level: 'Beginner',
    description:
        'Learn tuning, simple chords, and a short weekly practice routine.',
    type: 'offered',
    exchangeFor: 'Flutter App Development',
    isActive: true,
    createdAt: _seedDate,
  ),
  Skill(
    id: 'demo_skill_english_speaking',
    ownerId: 'demo_selam',
    ownerName: 'Selam',
    ownerPhotoUrl: '',
    university: 'Bahir Dar University',
    title: 'English Speaking',
    category: 'Language',
    level: 'Intermediate',
    description:
        'Practice everyday conversation, pronunciation, and confident speaking.',
    type: 'offered',
    exchangeFor: 'Firebase Basics',
    isActive: true,
    createdAt: _seedDate,
  ),
  Skill(
    id: 'demo_skill_graphic_design',
    ownerId: 'demo_hana',
    ownerName: 'Hana',
    ownerPhotoUrl: '',
    university: 'AASTU',
    title: 'Graphic Design',
    category: 'Creative',
    level: 'Intermediate',
    description:
        'Create clean posters, presentation boards, and simple brand visuals.',
    type: 'offered',
    exchangeFor: 'Calculus Tutoring',
    isActive: true,
    createdAt: _seedDate,
  ),
  Skill(
    id: 'demo_skill_firebase_basics',
    ownerId: 'demo_beka',
    ownerName: 'Beka',
    ownerPhotoUrl: '',
    university: 'Addis Ababa University',
    title: 'Firebase Basics',
    category: 'Tech',
    level: 'Beginner',
    description:
        'Understand Firebase Auth, Firestore collections, and basic app integration.',
    type: 'offered',
    exchangeFor: 'Accounting or English Speaking',
    isActive: true,
    createdAt: _seedDate,
  ),
  Skill(
    id: 'demo_skill_public_speaking',
    ownerId: 'demo_lamesgnew',
    ownerName: 'Lamesgnew',
    ownerPhotoUrl: '',
    university: 'Bahir Dar University',
    title: 'Public Speaking',
    category: 'Language',
    level: 'Intermediate',
    description:
        'Practice speech structure, delivery, and constructive peer feedback.',
    type: 'offered',
    exchangeFor: 'Flutter App Development or Guitar Basics',
    isActive: true,
    createdAt: _seedDate,
  ),
];
