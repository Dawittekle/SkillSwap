import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/core/constants/app_constants.dart';
import 'package:skill_swap/data/models/review.dart';
import 'package:skill_swap/data/repositories/firestore_repository_helpers.dart';

// This file contains Firestore operations for session reviews.
class ReviewRepository {
  ReviewRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews {
    return _firestore.collection(AppConstants.reviewsCollection);
  }

  Future<void> createReview(Review review) async {
    try {
      final document = review.id.isEmpty
          ? _reviews.doc()
          : _reviews.doc(review.id);
      final existingReview = await document.get();
      if (existingReview.exists) {
        throw Exception('You already reviewed this session.');
      }

      final reviewToSave = review.id.isEmpty
          ? review.copyWith(id: document.id)
          : review;

      await document.set(reviewToSave.toMap());
      try {
        await _updateUserAverageRating(reviewToSave.revieweeId);
      } catch (_) {
        // Reviews should still save even if the demo rating summary update fails.
      }
    } catch (error) {
      if (error is Exception && error.toString().contains('already reviewed')) {
        rethrow;
      }

      throw friendlyFirestoreException(error, 'Could not create review.');
    }
  }

  Future<bool> hasReviewForSession(String sessionId, String reviewerId) async {
    try {
      final documentId = reviewDocumentId(sessionId, reviewerId);
      final document = await _reviews.doc(documentId).get();

      return document.exists;
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not check review status.');
    }
  }

  Stream<List<Review>> watchReviewsForUser(String userId) {
    return _reviews
        .where('revieweeId', isEqualTo: userId)
        .snapshots()
        .map(_reviewsFromSnapshot)
        .handleError((Object error) {
          throw friendlyFirestoreException(error, 'Could not load reviews.');
        });
  }

  List<Review> _reviewsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((document) {
      return Review.fromMap(dataWithDocumentId(document, 'id'));
    }).toList();
  }

  Future<void> _updateUserAverageRating(String userId) async {
    final snapshot = await _reviews
        .where('revieweeId', isEqualTo: userId)
        .get();
    final reviews = _reviewsFromSnapshot(snapshot);
    if (reviews.isEmpty) return;

    final total = reviews.fold<double>(
      0,
      (runningTotal, review) => runningTotal + review.rating,
    );
    final average = total / reviews.length;

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .update({'rating': average});
  }
}

String reviewDocumentId(String sessionId, String reviewerId) {
  return '${sessionId}_$reviewerId';
}
