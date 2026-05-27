import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/data/models/review.dart';
import 'package:skill_swap/data/repositories/firestore_repository_helpers.dart';

class ReviewRepository {
  ReviewRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews {
    return _firestore.collection('reviews');
  }

  Future<void> createReview(Review review) async {
    try {
      final document = review.id.isEmpty
          ? _reviews.doc()
          : _reviews.doc(review.id);
      final reviewToSave = review.id.isEmpty
          ? review.copyWith(id: document.id)
          : review;

      await document.set(reviewToSave.toMap());
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not create review.');
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
}
