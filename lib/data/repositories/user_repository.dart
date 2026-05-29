import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/repositories/firestore_repository_helpers.dart';

// This file contains Firestore operations for student profiles.
class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users {
    return _firestore.collection(AppConstants.usersCollection);
  }

  Future<AppUser?> getUser(String uid) async {
    try {
      final document = await _users.doc(uid).get();
      if (!document.exists) return null;

      return AppUser.fromMap(dataWithDocumentId(document, 'uid'));
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not load user profile.');
    }
  }

  Stream<AppUser?> watchUser(String uid) {
    return _users
        .doc(uid)
        .snapshots()
        .map((document) {
          if (!document.exists) return null;

          return AppUser.fromMap(dataWithDocumentId(document, 'uid'));
        })
        .handleError((Object error) {
          throw friendlyFirestoreException(
            error,
            'Could not watch user profile.',
          );
        });
  }

  Future<void> createUserProfile(AppUser user) async {
    try {
      await _users.doc(user.uid).set(user.toMap());
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not create user profile.');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(firestoreUpdateData(data));
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not update user profile.');
    }
  }
}
