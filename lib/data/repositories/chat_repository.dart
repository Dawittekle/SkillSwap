import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skill_swap/data/models/chat_message.dart';
import 'package:skill_swap/data/models/conversation.dart';
import 'package:skill_swap/data/repositories/firestore_repository_helpers.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _conversations {
    return _firestore.collection('conversations');
  }

  Future<String> createOrGetConversation(
    String currentUserId,
    String otherUserId,
    Map<String, String> participantNames, {
    String? relatedRequestId,
  }) async {
    try {
      final conversationId = conversationIdForUsers(currentUserId, otherUserId);
      final document = _conversations.doc(conversationId);
      final existingConversation = await document.get();

      if (existingConversation.exists) {
        await document.set({
          'participants': _sortedParticipants(currentUserId, otherUserId),
          'participantNames': participantNames,
          if (relatedRequestId != null && relatedRequestId.isNotEmpty)
            'relatedRequestId': relatedRequestId,
        }, SetOptions(merge: true));

        return conversationId;
      }

      final conversation = Conversation(
        id: conversationId,
        participants: _sortedParticipants(currentUserId, otherUserId),
        participantNames: participantNames,
        lastMessage: '',
        lastMessageAt: DateTime.now(),
        relatedRequestId: relatedRequestId ?? '',
        lastSenderId: '',
        unreadBy: const [],
      );

      await document.set(conversation.toMap());
      return conversationId;
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not create conversation.');
    }
  }

  Stream<List<Conversation>> watchUserConversations(String uid) {
    return _conversations
        .where('participants', arrayContains: uid)
        .snapshots()
        .map(_conversationsFromSnapshot)
        .handleError((Object error) {
          throw friendlyFirestoreException(
            error,
            'Could not load conversations.',
          );
        });
  }

  Stream<int> watchUnreadConversationCount(String uid) {
    return watchUserConversations(uid).map((conversations) {
      return conversations.where((conversation) {
        return conversation.unreadBy.contains(uid);
      }).length;
    });
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _messages(conversationId)
        .orderBy('createdAt')
        .snapshots()
        .map(_messagesFromSnapshot)
        .handleError((Object error) {
          throw friendlyFirestoreException(error, 'Could not load messages.');
        });
  }

  Future<void> sendMessage(String conversationId, ChatMessage message) async {
    try {
      final conversationDocument = _conversations.doc(conversationId);
      final conversationSnapshot = await conversationDocument.get();
      final conversation = Conversation.fromMap(
        dataWithDocumentId(conversationSnapshot, 'id'),
      );
      final unreadBy = conversation.participants.where((userId) {
        return userId != message.senderId;
      }).toList();
      final messageDocument = message.id.isEmpty
          ? _messages(conversationId).doc()
          : _messages(conversationId).doc(message.id);
      final messageToSave = message.copyWith(
        id: messageDocument.id,
        conversationId: conversationId,
      );

      final batch = _firestore.batch();
      batch.set(messageDocument, messageToSave.toMap());
      batch.update(conversationDocument, {
        'lastMessage': message.text,
        'lastMessageAt': Timestamp.fromDate(message.createdAt),
        'lastSenderId': message.senderId,
        'unreadBy': unreadBy,
      });

      await batch.commit();
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not send message.');
    }
  }

  Future<void> markConversationRead(String conversationId, String uid) async {
    try {
      final unreadMessages = await _messages(conversationId).get();
      final batch = _firestore.batch();

      batch.update(_conversations.doc(conversationId), {
        'unreadBy': FieldValue.arrayRemove([uid]),
      });

      for (final document in unreadMessages.docs) {
        final message = ChatMessage.fromMap(dataWithDocumentId(document, 'id'));
        final shouldMarkRead =
            message.senderId != uid && !message.readBy.contains(uid);

        if (shouldMarkRead) {
          batch.update(document.reference, {
            'readBy': FieldValue.arrayUnion([uid]),
          });
        }
      }

      await batch.commit();
    } catch (error) {
      throw friendlyFirestoreException(error, 'Could not mark messages read.');
    }
  }

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) {
    return _conversations.doc(conversationId).collection('messages');
  }

  List<Conversation> _conversationsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((document) {
      return Conversation.fromMap(dataWithDocumentId(document, 'id'));
    }).toList();
  }

  List<ChatMessage> _messagesFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs.map((document) {
      return ChatMessage.fromMap(dataWithDocumentId(document, 'id'));
    }).toList();
  }
}

String conversationIdForUsers(String firstUserId, String secondUserId) {
  return _sortedParticipants(firstUserId, secondUserId).join('_');
}

List<String> _sortedParticipants(String firstUserId, String secondUserId) {
  return [firstUserId, secondUserId]..sort();
}
