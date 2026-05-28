import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/conversation.dart';
import 'package:skill_swap/data/repositories/chat_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key, this.authService, this.chatRepository});

  final AuthService? authService;
  final ChatRepository? chatRepository;

  @override
  Widget build(BuildContext context) {
    final auth = authService ?? AuthService();
    final chats = chatRepository ?? ChatRepository();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return const SafeArea(
        child: Center(child: Text('Please login to view messages.')),
      );
    }

    return SafeArea(
      child: StreamBuilder<List<Conversation>>(
        stream: chats.watchUserConversations(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return _MessagesState(message: snapshot.error.toString());
          }

          final conversations = [...(snapshot.data ?? [])]
            ..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
            children: [
              Text(
                'Messages',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 16),
              if (conversations.isEmpty)
                const _MessagesState(
                  message: 'No conversations yet. Message a student to start.',
                )
              else
                for (final conversation in conversations) ...[
                  _ConversationCard(
                    conversation: conversation,
                    currentUserId: currentUser.uid,
                  ),
                  const SizedBox(height: 12),
                ],
            ],
          );
        },
      ),
    );
  }
}

class _ConversationCard extends StatelessWidget {
  const _ConversationCard({
    required this.conversation,
    required this.currentUserId,
  });

  final Conversation conversation;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final otherUserId = conversation.participants.firstWhere(
      (uid) => uid != currentUserId,
      orElse: () => '',
    );
    final otherName = conversation.participantNames[otherUserId] ?? 'Student';
    final lastMessage = conversation.lastMessage.isEmpty
        ? 'No messages yet'
        : conversation.lastMessage;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          AppRoutes.chat,
          arguments: ChatArguments(
            conversationId: conversation.id,
            otherUserId: otherUserId,
            otherUserName: otherName,
            relatedRequestId: conversation.relatedRequestId,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.tealTint,
              child: Text(otherName.isEmpty ? '?' : otherName[0]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _timeLabel(conversation.lastMessageAt),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesState extends StatelessWidget {
  const _MessagesState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

String _timeLabel(DateTime date) {
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;

  if (!isToday) {
    return '${date.month}/${date.day}';
  }

  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
