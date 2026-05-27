import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/data/models/skill.dart';
import 'package:skill_swap/data/repositories/firestore_repository_helpers.dart';

class SkillRepository {
  SkillRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _skills {
    return _firestore.collection('skills');
  }

  Future<void> createSkill(Skill skill) async {
    try {
      final document = skill.id.isEmpty ? _skills.doc() : _skills.doc(skill.id);
      final skillToSave = skill.id.isEmpty
          ? skill.copyWith(id: document.id)
          : skill;

      await document.set(skillToSave.toMap());
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not create skill.');
    }
  }

  Stream<List<Skill>> watchCurrentUserSkills(String uid) {
    return _skills
        .where('ownerId', isEqualTo: uid)
        .snapshots()
        .map(_skillsFromSnapshot)
        .handleError((Object error) {
          throw friendlyFirestoreException(
            error,
            'Could not load your skills.',
          );
        });
  }

  Stream<List<Skill>> watchOfferedSkillsExcludingUser(String uid) {
    return _skills
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return _skillsFromSnapshot(
            snapshot,
          ).where((skill) => skill.ownerId != uid).toList();
        })
        .handleError((Object error) {
          throw friendlyFirestoreException(
            error,
            'Could not load offered skills.',
          );
        });
  }

  Future<void> updateSkill(String skillId, Map<String, dynamic> data) async {
    try {
      await _skills.doc(skillId).update(firestoreUpdateData(data));
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not update skill.');
    }
  }

  Future<void> deleteSkill(String skillId) async {
    try {
      await _skills.doc(skillId).delete();
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not delete skill.');
    }
  }

  List<Skill> _skillsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((document) {
      return Skill.fromMap(dataWithDocumentId(document, 'id'));
    }).toList();
  }
}
