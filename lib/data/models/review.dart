import 'package:skill_swap/data/models/model_helpers.dart';

class Review {
  const Review({
    required this.id,
    required this.sessionId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    required this.tags,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String reviewerId;
  final String revieweeId;
  final double rating;
  final List<String> tags;
  final String comment;
  final DateTime createdAt;

  factory Review.fromMap(Map<String, dynamic>? map) {
    final data = map ?? {};

    return Review(
      id: readString(data, 'id'),
      sessionId: readString(data, 'sessionId'),
      reviewerId: readString(data, 'reviewerId'),
      revieweeId: readString(data, 'revieweeId'),
      rating: readDouble(data, 'rating'),
      tags: readStringList(data, 'tags'),
      comment: readString(data, 'comment'),
      createdAt: readDateTime(data, 'createdAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sessionId': sessionId,
      'reviewerId': reviewerId,
      'revieweeId': revieweeId,
      'rating': rating,
      'tags': tags,
      'comment': comment,
      'createdAt': dateTimeToTimestamp(createdAt),
    };
  }

  Review copyWith({
    String? id,
    String? sessionId,
    String? reviewerId,
    String? revieweeId,
    double? rating,
    List<String>? tags,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      reviewerId: reviewerId ?? this.reviewerId,
      revieweeId: revieweeId ?? this.revieweeId,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
