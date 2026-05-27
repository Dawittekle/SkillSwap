import 'package:skill_swap/data/models/model_helpers.dart';

class Conversation {
  const Conversation({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.relatedRequestId,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String relatedRequestId;

  factory Conversation.fromMap(Map<String, dynamic>? map) {
    final data = map ?? {};

    return Conversation(
      id: readString(data, 'id'),
      participants: readStringList(data, 'participants'),
      participantNames: readStringMap(data, 'participantNames'),
      lastMessage: readString(data, 'lastMessage'),
      lastMessageAt: readDateTime(data, 'lastMessageAt'),
      relatedRequestId: readString(data, 'relatedRequestId'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'participantNames': participantNames,
      'lastMessage': lastMessage,
      'lastMessageAt': dateTimeToTimestamp(lastMessageAt),
      'relatedRequestId': relatedRequestId,
    };
  }

  Conversation copyWith({
    String? id,
    List<String>? participants,
    Map<String, String>? participantNames,
    String? lastMessage,
    DateTime? lastMessageAt,
    String? relatedRequestId,
  }) {
    return Conversation(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      participantNames: participantNames ?? this.participantNames,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      relatedRequestId: relatedRequestId ?? this.relatedRequestId,
    );
  }
}
