import 'package:skill_swap/data/models/model_helpers.dart';

// Represents a SkillSwap student profile stored in the users collection.
class AppUser {
  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.university,
    required this.department,
    required this.year,
    required this.bio,
    required this.campus,
    required this.photoUrl,
    required this.rating,
    required this.completedSwaps,
    required this.profileCompleted,
    required this.createdAt,
  });

  final String uid;
  final String fullName;
  final String email;
  final String university;
  final String department;
  final String year;
  final String bio;
  final String campus;
  final String photoUrl;
  final double rating;
  final int completedSwaps;
  final bool profileCompleted;
  final DateTime createdAt;

  factory AppUser.fromMap(Map<String, dynamic>? map) {
    final data = map ?? {};

    return AppUser(
      uid: readString(data, 'uid'),
      fullName: readString(data, 'fullName'),
      email: readString(data, 'email'),
      university: readString(data, 'university'),
      department: readString(data, 'department'),
      year: readString(data, 'year'),
      bio: readString(data, 'bio'),
      campus: readString(data, 'campus'),
      photoUrl: readString(data, 'photoUrl'),
      rating: readDouble(data, 'rating'),
      completedSwaps: readInt(data, 'completedSwaps'),
      profileCompleted: readBool(data, 'profileCompleted'),
      createdAt: readDateTime(data, 'createdAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'university': university,
      'department': department,
      'year': year,
      'bio': bio,
      'campus': campus,
      'photoUrl': photoUrl,
      'rating': rating,
      'completedSwaps': completedSwaps,
      'profileCompleted': profileCompleted,
      'createdAt': dateTimeToTimestamp(createdAt),
    };
  }

  AppUser copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? university,
    String? department,
    String? year,
    String? bio,
    String? campus,
    String? photoUrl,
    double? rating,
    int? completedSwaps,
    bool? profileCompleted,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      university: university ?? this.university,
      department: department ?? this.department,
      year: year ?? this.year,
      bio: bio ?? this.bio,
      campus: campus ?? this.campus,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      completedSwaps: completedSwaps ?? this.completedSwaps,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
