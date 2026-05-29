import 'package:skill_swap/data/models/model_helpers.dart';

// Represents one text message inside a conversation.
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.readBy,
  });

  final String id;
  final String conversationId;
  final String senderId;
  final String text;
  final DateTime createdAt;
  final List<String> readBy;

  factory ChatMessage.fromMap(Map<String, dynamic>? map) {
    final data = map ?? {};

    return ChatMessage(
      id: readString(data, 'id'),
      conversationId: readString(data, 'conversationId'),
      senderId: readString(data, 'senderId'),
      text: readString(data, 'text'),
      createdAt: readDateTime(data, 'createdAt'),
      readBy: readStringList(data, 'readBy'),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'text': text,
      'createdAt': dateTimeToTimestamp(createdAt),
      'readBy': readBy,
    };
  }

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? text,
    DateTime? createdAt,
    List<String>? readBy,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      readBy: readBy ?? this.readBy,
    );
  }
}
