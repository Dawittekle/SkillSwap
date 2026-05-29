import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/data/repositories/swap_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';

class SwapsTab extends StatelessWidget {
  const SwapsTab({
    super.key,
    this.authService,
    this.swapRepository,
    this.onSelectTab,
  });

  final AuthService? authService;
  final SwapRepository? swapRepository;
  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final auth = authService ?? AuthService();
    final swaps = swapRepository ?? SwapRepository();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return const SafeArea(
        child: Center(child: Text('Please login to view your swaps.')),
      );
    }

    return StreamBuilder<List<SwapRequest>>(
      stream: swaps.watchIncomingRequests(currentUser.uid),
      builder: (context, incomingSnapshot) {
        if (incomingSnapshot.connectionState == ConnectionState.waiting &&
            !incomingSnapshot.hasData) {
          return const _SwapsLoading();
        }

        if (incomingSnapshot.hasError) {
          return _SwapsMessage(message: incomingSnapshot.error.toString());
        }

        return StreamBuilder<List<SwapRequest>>(
          stream: swaps.watchOutgoingRequests(currentUser.uid),
          builder: (context, outgoingSnapshot) {
            if (outgoingSnapshot.connectionState == ConnectionState.waiting &&
                !outgoingSnapshot.hasData) {
              return const _SwapsLoading();
            }

            if (outgoingSnapshot.hasError) {
              return _SwapsMessage(message: outgoingSnapshot.error.toString());
            }

            final incoming = incomingSnapshot.data ?? [];
            final outgoing = outgoingSnapshot.data ?? [];
            final allRequests = [...incoming, ...outgoing]
              ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

            return _SwapsContent(
              currentUserId: currentUser.uid,
              requests: allRequests,
              swapRepository: swaps,
              onSelectTab: onSelectTab,
            );
          },
        );
      },
    );
  }
}

class _SwapsContent extends StatelessWidget {
  const _SwapsContent({
    required this.currentUserId,
    required this.requests,
    required this.swapRepository,
    required this.onSelectTab,
  });

  final String currentUserId;
  final List<SwapRequest> requests;
  final SwapRepository swapRepository;
  final ValueChanged<int>? onSelectTab;

  @override
  Widget build(BuildContext context) {
    final pending = requests
        .where((request) => request.status == 'pending')
        .toList();
    final upcoming = requests
        .where((request) => request.status == 'accepted')
        .toList();
    final completed = requests
        .where((request) => request.status == 'completed')
        .toList();

    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Swaps',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track active, pending, and completed skill exchanges.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
                  ),
                  const SizedBox(height: 18),
                  AppButton(
                    label: 'Find Swap Partner',
                    icon: Icons.add,
                    onPressed: () {
                      if (onSelectTab != null) {
                        onSelectTab!(1);
                        return;
                      }

                      Navigator.of(context).pushNamed(AppRoutes.discover);
                    },
                  ),
                  const SizedBox(height: 18),
                  const TabBar(
                    tabs: [
                      Tab(text: 'Requests'),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Completed'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SwapList(
                    requests: pending,
                    currentUserId: currentUserId,
                    swapRepository: swapRepository,
                    emptyMessage:
                        'No pending requests yet. Find a swap partner to start.',
                  ),
                  _SwapList(
                    requests: upcoming,
                    currentUserId: currentUserId,
                    swapRepository: swapRepository,
                    emptyMessage:
                        'No upcoming sessions yet. Accepted swaps will appear here after you schedule a time.',
                  ),
                  _SwapList(
                    requests: completed,
                    currentUserId: currentUserId,
                    swapRepository: swapRepository,
                    emptyMessage: 'No completed swaps yet.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwapList extends StatelessWidget {
  const _SwapList({
    required this.requests,
    required this.currentUserId,
    required this.swapRepository,
    required this.emptyMessage,
  });

  final List<SwapRequest> requests;
  final String currentUserId;
  final SwapRepository swapRepository;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _SwapsMessage(message: emptyMessage);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        return _SwapCard(
          request: requests[index],
          currentUserId: currentUserId,
          swapRepository: swapRepository,
        );
      },
    );
  }
}

class _SwapCard extends StatefulWidget {
  const _SwapCard({
    required this.request,
    required this.currentUserId,
    required this.swapRepository,
  });

  final SwapRequest request;
  final String currentUserId;
  final SwapRepository swapRepository;

  @override
  State<_SwapCard> createState() => _SwapCardState();
}

class _SwapCardState extends State<_SwapCard> {
  bool _isUpdating = false;

  bool get _isIncoming => widget.request.toUserId == widget.currentUserId;

  Future<void> _updateStatus(String status) async {
    setState(() => _isUpdating = true);
    try {
      await widget.swapRepository.updateRequestStatus(
        widget.request.id,
        status,
      );
      if (!mounted) return;
      showAuthMessage(context, 'Swap request updated.');
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = widget.request;
    final otherName = _isIncoming ? request.fromUserName : request.toUserName;
    final otherUserId = _isIncoming ? request.fromUserId : request.toUserId;
    final statusColor = _statusColor(request.status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: request.status.toUpperCase(),
                color: statusColor,
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: _isIncoming ? 'INCOMING' : 'OUTGOING',
                color: AppColors.primaryGreen,
              ),
              const Spacer(),
              Text(
                _dateLabel(request.suggestedTime),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
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
                      otherName.isEmpty ? 'Student' : otherName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      request.mode.isEmpty ? 'Mode not selected' : request.mode,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SwapSkillLine(
            label: _isIncoming ? 'They offer' : 'You offer',
            value: request.offeredSkillTitle,
            icon: Icons.south_west,
          ),
          const SizedBox(height: 10),
          _SwapSkillLine(
            label: _isIncoming ? 'They want' : 'You want',
            value: request.wantedSkillTitle,
            icon: Icons.north_east,
          ),
          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              request.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 18),
          _SwapActions(
            status: request.status,
            isIncoming: _isIncoming,
            isUpdating: _isUpdating,
            onAccept: () => _updateStatus('accepted'),
            onDecline: () => _updateStatus('declined'),
            onCancel: () => _updateStatus('cancelled'),
            onComplete: () => _updateStatus('completed'),
            onMessage: () => Navigator.of(context).pushNamed(
              AppRoutes.chat,
              arguments: ChatArguments(
                otherUserId: otherUserId,
                otherUserName: otherName,
                relatedRequestId: request.id,
              ),
            ),
            onReview: () => Navigator.of(context).pushNamed(
              AppRoutes.reviewSession,
              arguments: ReviewSessionArguments(request: request),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapActions extends StatelessWidget {
  const _SwapActions({
    required this.status,
    required this.isIncoming,
    required this.isUpdating,
    required this.onAccept,
    required this.onDecline,
    required this.onCancel,
    required this.onComplete,
    required this.onMessage,
    required this.onReview,
  });

  final String status;
  final bool isIncoming;
  final bool isUpdating;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onCancel;
  final VoidCallback onComplete;
  final VoidCallback onMessage;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    if (status == 'pending' && isIncoming) {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: isUpdating ? 'Updating...' : 'Accept',
              icon: Icons.check,
              onPressed: isUpdating ? null : onAccept,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: 'Decline',
              variant: AppButtonVariant.secondary,
              onPressed: isUpdating ? null : onDecline,
            ),
          ),
        ],
      );
    }

    if (status == 'pending' && !isIncoming) {
      return AppButton(
        label: isUpdating ? 'Updating...' : 'Cancel Request',
        icon: Icons.close,
        variant: AppButtonVariant.secondary,
        onPressed: isUpdating ? null : onCancel,
      );
    }

    if (status == 'accepted') {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Message',
              icon: Icons.mail_outline,
              onPressed: onMessage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: isUpdating ? 'Updating...' : 'Complete',
              icon: Icons.check_circle_outline,
              variant: AppButtonVariant.secondary,
              onPressed: isUpdating ? null : onComplete,
            ),
          ),
        ],
      );
    }

    if (status == 'completed') {
      return Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Message',
              icon: Icons.mail_outline,
              variant: AppButtonVariant.secondary,
              onPressed: onMessage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppButton(
              label: 'Review',
              icon: Icons.star_border_rounded,
              onPressed: onReview,
            ),
          ),
        ],
      );
    }

    return AppButton(
      label: 'Message',
      icon: Icons.mail_outline,
      variant: AppButtonVariant.secondary,
      onPressed: onMessage,
    );
  }
}

class _SwapSkillLine extends StatelessWidget {
  const _SwapSkillLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SwapsLoading extends StatelessWidget {
  const _SwapsLoading();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}

class _SwapsMessage extends StatelessWidget {
  const _SwapsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
        children: [
          AppCard(
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }
}

Color _statusColor(String status) {
  return switch (status) {
    'accepted' => AppColors.success,
    'completed' => AppColors.primaryGreen,
    'declined' || 'cancelled' => AppColors.danger,
    _ => AppColors.warning,
  };
}

String _dateLabel(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}
