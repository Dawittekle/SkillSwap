import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/chat_message.dart';
import 'package:skill_swap/data/repositories/chat_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    required this.arguments,
    super.key,
    this.authService,
    this.userRepository,
    this.chatRepository,
  });

  final ChatArguments? arguments;
  final AuthService? authService;
  final UserRepository? userRepository;
  final ChatRepository? chatRepository;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();

  AuthService get _authService => widget.authService ?? AuthService();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();
  ChatRepository get _chatRepository =>
      widget.chatRepository ?? ChatRepository();

  late final Future<_ChatStartData?> _chatFuture = _openChat();
  bool _isSending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<_ChatStartData?> _openChat() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return null;

    final args = widget.arguments;
    if (args?.conversationId.isNotEmpty == true) {
      return _ChatStartData(
        conversationId: args!.conversationId,
        currentUserId: currentUser.uid,
        title: args.otherUserName.isEmpty ? 'Chat' : args.otherUserName,
      );
    }

    if (args == null || args.otherUserId.isEmpty) return null;

    final appUser = await _userRepository.getUser(currentUser.uid);
    final currentName = _displayName(appUser, currentUser.email);
    final otherName = args.otherUserName.isEmpty
        ? 'Student'
        : args.otherUserName;
    final conversationId = await _chatRepository.createOrGetConversation(
      currentUser.uid,
      args.otherUserId,
      {currentUser.uid: currentName, args.otherUserId: otherName},
      relatedRequestId: args.relatedRequestId,
    );

    return _ChatStartData(
      conversationId: conversationId,
      currentUserId: currentUser.uid,
      title: otherName,
    );
  }

  Future<void> _sendMessage(_ChatStartData chat) async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      final now = DateTime.now();
      await _chatRepository.sendMessage(
        chat.conversationId,
        ChatMessage(
          id: '',
          conversationId: chat.conversationId,
          senderId: chat.currentUserId,
          text: text,
          createdAt: now,
          readBy: [chat.currentUserId],
        ),
      );
      _messageController.clear();
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ChatStartData?>(
      future: _chatFuture,
      builder: (context, snapshot) {
        final title = snapshot.data?.title ?? widget.arguments?.otherUserName;

        return Scaffold(
          appBar: AppBar(
            title: Text(title?.isNotEmpty == true ? title! : 'Chat'),
          ),
          body: SafeArea(child: _buildBody(snapshot)),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<_ChatStartData?> snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      );
    }

    if (snapshot.hasError) {
      return _ChatMessageState(message: snapshot.error.toString());
    }

    final chat = snapshot.data;
    if (chat == null) {
      return const _ChatMessageState(
        message: 'Choose a student or conversation to start chatting.',
      );
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder<List<ChatMessage>>(
            stream: _chatRepository.watchMessages(chat.conversationId),
            builder: (context, messageSnapshot) {
              if (messageSnapshot.connectionState == ConnectionState.waiting &&
                  !messageSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryGreen,
                  ),
                );
              }

              if (messageSnapshot.hasError) {
                return _ChatMessageState(
                  message: messageSnapshot.error.toString(),
                );
              }

              final messages = messageSnapshot.data ?? [];
              if (messages.isEmpty) {
                return const _ChatMessageState(
                  message: 'No messages yet. Send the first note.',
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _MessageBubble(
                    message: message,
                    isMine: message.senderId == chat.currentUserId,
                  );
                },
              );
            },
          ),
        ),
        _Composer(
          controller: _messageController,
          isSending: _isSending,
          onSend: () => _sendMessage(chat),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.isMine});

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primaryGreen : AppColors.cardWhite,
          border: Border.all(
            color: isMine ? AppColors.primaryGreen : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isMine ? AppColors.cardWhite : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _timeLabel(message.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isMine ? AppColors.softGold : AppColors.textGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Write a message...',
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.cardWhite,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              tooltip: 'Send message',
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageState extends StatelessWidget {
  const _ChatMessageState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}

class _ChatStartData {
  const _ChatStartData({
    required this.conversationId,
    required this.currentUserId,
    required this.title,
  });

  final String conversationId;
  final String currentUserId;
  final String title;
}

String _displayName(AppUser? user, String? fallbackEmail) {
  if (user != null && user.fullName.trim().isNotEmpty) {
    return user.fullName.trim();
  }

  return fallbackEmail ?? 'Student';
}

String _timeLabel(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
