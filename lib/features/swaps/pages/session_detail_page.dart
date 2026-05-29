import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/data/repositories/swap_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/routing/app_routes.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/widgets/app_chip.dart';
import 'package:skill_swap/core/utils/app_validators.dart';

class SessionDetailPage extends StatefulWidget {
  const SessionDetailPage({
    required this.request,
    super.key,
    this.authService,
    this.swapRepository,
  });

  final SwapRequest? request;
  final AuthService? authService;
  final SwapRepository? swapRepository;

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  bool _isUpdating = false;

  AuthService get _authService => widget.authService ?? AuthService();
  SwapRepository get _swapRepository =>
      widget.swapRepository ?? SwapRepository();

  Future<void> _updateStatus(String status) async {
    final request = widget.request;
    if (request == null) return;

    setState(() => _isUpdating = true);
    try {
      await _swapRepository.updateRequestStatus(request.id, status);
      if (!mounted) return;
      showAuthMessage(context, 'Swap updated.');
      Navigator.of(context).pop();
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
    final currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (currentUser == null) {
              return const _DetailMessage(
                message: 'Please login to view session details.',
              );
            }

            if (request == null) {
              return const _DetailMessage(message: 'Session not found.');
            }

            final isIncoming = request.toUserId == currentUser.uid;
            final otherUserId = isIncoming
                ? request.fromUserId
                : request.toUserId;
            final otherName = isIncoming
                ? request.fromUserName
                : request.toUserName;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusChip(
                                    label: request.status.toUpperCase(),
                                    color: _statusColor(request.status),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _dateLabel(request.suggestedTime),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.labelMedium,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Text(
                                otherName.isEmpty ? 'Student' : otherName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              _DetailRow(
                                icon: Icons.north_east,
                                label: isIncoming ? 'They want' : 'You want',
                                value: request.wantedSkillTitle,
                              ),
                              _DetailRow(
                                icon: Icons.south_west,
                                label: isIncoming ? 'They offer' : 'You offer',
                                value: request.offeredSkillTitle,
                              ),
                              _DetailRow(
                                icon: Icons.schedule,
                                label: 'Suggested time',
                                value:
                                    '${_dateLabel(request.suggestedTime)} ${_timeLabel(request.suggestedTime)}',
                              ),
                              _DetailRow(
                                icon: Icons.place_outlined,
                                label: 'Mode',
                                value: request.mode.isEmpty
                                    ? 'Not selected'
                                    : request.mode,
                              ),
                              if (request.message.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  request.message,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppButton(
                          label: 'Message',
                          icon: Icons.mail_outline,
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.chat,
                            arguments: ChatArguments(
                              otherUserId: otherUserId,
                              otherUserName: otherName,
                              relatedRequestId: request.id,
                            ),
                          ),
                        ),
                        if (request.status == 'accepted') ...[
                          const SizedBox(height: 12),
                          AppButton(
                            label: _isUpdating ? 'Updating...' : 'Complete',
                            icon: Icons.check_circle_outline,
                            variant: AppButtonVariant.secondary,
                            onPressed: _isUpdating
                                ? null
                                : () => _updateStatus('completed'),
                          ),
                        ],
                        if (request.status == 'completed') ...[
                          const SizedBox(height: 12),
                          AppButton(
                            label: 'Review Session',
                            icon: Icons.star_border_rounded,
                            variant: AppButtonVariant.secondary,
                            onPressed: () => Navigator.of(context).pushNamed(
                              AppRoutes.reviewSession,
                              arguments: ReviewSessionArguments(
                                request: request,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMessage extends StatelessWidget {
  const _DetailMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
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

String _timeLabel(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}
