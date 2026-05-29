import 'package:skill_swap/data/models/model_helpers.dart';

// Represents a request to exchange one student's skill for another.
class SwapRequest {
  const SwapRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.offeredSkillId,
    required this.offeredSkillTitle,
    required this.wantedSkillId,
    required this.wantedSkillTitle,
    required this.message,
    required this.status,
    required this.suggestedTime,
    required this.mode,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final String offeredSkillId;
  final String offeredSkillTitle;
  final String wantedSkillId;
  final String wantedSkillTitle;
  final String message;
  final String status;
  final DateTime suggestedTime;
  final String mode;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SwapRequest.fromMap(Map<String, dynamic>? map) {
    final data = map ?? {};

    return SwapRequest(
      id: readString(data, 'id'),
      fromUserId: readString(data, 'fromUserId'),
      fromUserName: readString(data, 'fromUserName'),
      toUserId: readString(data, 'toUserId'),
      toUserName: readString(data, 'toUserName'),
      offeredSkillId: readString(data, 'offeredSkillId'),
      offeredSkillTitle: readString(data, 'offeredSkillTitle'),
      wantedSkillId: readString(data, 'wantedSkillId'),
      wantedSkillTitle: readString(data, 'wantedSkillTitle'),
      message: readString(data, 'message'),
      status: readString(data, 'status'),
      suggestedTime: readDateTime(data, 'suggestedTime'),
      mode: readString(data, 'mode'),
      createdAt: readDateTime(data, 'createdAt'),
      updatedAt: readDateTime(data, 'updatedAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'offeredSkillId': offeredSkillId,
      'offeredSkillTitle': offeredSkillTitle,
      'wantedSkillId': wantedSkillId,
      'wantedSkillTitle': wantedSkillTitle,
      'message': message,
      'status': status,
      'suggestedTime': dateTimeToTimestamp(suggestedTime),
      'mode': mode,
      'createdAt': dateTimeToTimestamp(createdAt),
      'updatedAt': dateTimeToTimestamp(updatedAt),
    };
  }

  SwapRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    String? offeredSkillId,
    String? offeredSkillTitle,
    String? wantedSkillId,
    String? wantedSkillTitle,
    String? message,
    String? status,
    DateTime? suggestedTime,
    String? mode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SwapRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      offeredSkillId: offeredSkillId ?? this.offeredSkillId,
      offeredSkillTitle: offeredSkillTitle ?? this.offeredSkillTitle,
      wantedSkillId: wantedSkillId ?? this.wantedSkillId,
      wantedSkillTitle: wantedSkillTitle ?? this.wantedSkillTitle,
      message: message ?? this.message,
      status: status ?? this.status,
      suggestedTime: suggestedTime ?? this.suggestedTime,
      mode: mode ?? this.mode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
