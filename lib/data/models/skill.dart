import 'package:skill_swap/data/models/model_helpers.dart';

// Represents one teachable or wanted skill stored in the skills collection.
class Skill {
  const Skill({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerPhotoUrl,
    required this.university,
    required this.title,
    required this.category,
    required this.level,
    required this.description,
    required this.type,
    required this.exchangeFor,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerPhotoUrl;
  final String university;
  final String title;
  final String category;
  final String level;
  final String description;
  final String type;
  final String exchangeFor;
  final bool isActive;
  final DateTime createdAt;

  factory Skill.fromMap(Map<String, dynamic>? map) {
    final data = map ?? {};

    return Skill(
      id: readString(data, 'id'),
      ownerId: readString(data, 'ownerId'),
      ownerName: readString(data, 'ownerName'),
      ownerPhotoUrl: readString(data, 'ownerPhotoUrl'),
      university: readString(data, 'university'),
      title: readString(data, 'title'),
      category: readString(data, 'category'),
      level: readString(data, 'level'),
      description: readString(data, 'description'),
      type: readString(data, 'type'),
      exchangeFor: readString(data, 'exchangeFor'),
      isActive: readBool(data, 'isActive'),
      createdAt: readDateTime(data, 'createdAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'ownerPhotoUrl': ownerPhotoUrl,
      'university': university,
      'title': title,
      'category': category,
      'level': level,
      'description': description,
      'type': type,
      'exchangeFor': exchangeFor,
      'isActive': isActive,
      'createdAt': dateTimeToTimestamp(createdAt),
    };
  }

  Skill copyWith({
    String? id,
    String? ownerId,
    String? ownerName,
    String? ownerPhotoUrl,
    String? university,
    String? title,
    String? category,
    String? level,
    String? description,
    String? type,
    String? exchangeFor,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Skill(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      ownerPhotoUrl: ownerPhotoUrl ?? this.ownerPhotoUrl,
      university: university ?? this.university,
      title: title ?? this.title,
      category: category ?? this.category,
      level: level ?? this.level,
      description: description ?? this.description,
      type: type ?? this.type,
      exchangeFor: exchangeFor ?? this.exchangeFor,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
