import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/conversation.dart';
import 'package:skill_swap/data/models/review.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/data/repositories/chat_repository.dart';
import 'package:skill_swap/data/repositories/review_repository.dart';
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/swap_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({
    super.key,
    this.authService,
    this.userRepository,
    this.skillRepository,
    this.swapRepository,
    this.reviewRepository,
    this.chatRepository,
    this.previewData = false,
    this.onSelectTab,
    this.onDiscoverSearch,
  });

  final AuthService? authService;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;
  final SwapRepository? swapRepository;
  final ReviewRepository? reviewRepository;
  final ChatRepository? chatRepository;
  final bool previewData;
  final ValueChanged<int>? onSelectTab;
  final ValueChanged<String>? onDiscoverSearch;

  @override
  Widget build(BuildContext context) {
    if (previewData) {
      return _HomeContent(data: _HomeData.preview());
    }

    final auth = authService ?? AuthService();
    final users = userRepository ?? UserRepository();
    final currentUser = auth.currentUser;

    if (currentUser == null) {
      return const SafeArea(
        child: Center(child: Text('Please login to view your home page.')),
      );
    }

    return StreamBuilder<AppUser?>(
      stream: users.watchUser(currentUser.uid),
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting &&
            !userSnapshot.hasData) {
          return const _HomeLoading();
        }

        if (userSnapshot.hasError) {
          return _HomeMessage(message: userSnapshot.error.toString());
        }

        final user = userSnapshot.data;
        if (user == null) {
          return const _HomeMessage(
            message: 'Complete your profile to see personalized matches.',
          );
        }

        return _HomeDataStreams(
          user: user,
          skillRepository: skillRepository ?? SkillRepository(),
          swapRepository: swapRepository ?? SwapRepository(),
          reviewRepository: reviewRepository ?? ReviewRepository(),
          chatRepository: chatRepository ?? ChatRepository(),
          onSelectTab: onSelectTab,
          onDiscoverSearch: onDiscoverSearch,
        );
      },
    );
  }
}

class _HomeDataStreams extends StatelessWidget {
  const _HomeDataStreams({
    required this.user,
    required this.skillRepository,
    required this.swapRepository,
    required this.reviewRepository,
    required this.chatRepository,
    required this.onSelectTab,
    required this.onDiscoverSearch,
  });

  final AppUser user;
  final SkillRepository skillRepository;
  final SwapRepository swapRepository;
  final ReviewRepository reviewRepository;
  final ChatRepository chatRepository;
  final ValueChanged<int>? onSelectTab;
  final ValueChanged<String>? onDiscoverSearch;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<firestore_skill.Skill>>(
      stream: skillRepository.watchCurrentUserSkills(user.uid),
      builder: (context, mySkillsSnapshot) {
        return StreamBuilder<List<firestore_skill.Skill>>(
          stream: skillRepository.watchOfferedSkillsExcludingUser(user.uid),
          builder: (context, offeredSnapshot) {
            return StreamBuilder<List<SwapRequest>>(
              stream: swapRepository.watchIncomingRequests(user.uid),
              builder: (context, incomingSnapshot) {
                return StreamBuilder<List<SwapRequest>>(
                  stream: swapRepository.watchOutgoingRequests(user.uid),
                  builder: (context, outgoingSnapshot) {
                    return StreamBuilder<List<Review>>(
                      stream: reviewRepository.watchReviewsForUser(user.uid),
                      builder: (context, reviewSnapshot) {
                        return StreamBuilder<List<Conversation>>(
                          stream: chatRepository.watchUserConversations(
                            user.uid,
                          ),
                          builder: (context, conversationSnapshot) {
                            final error =
                                mySkillsSnapshot.error ??
                                offeredSnapshot.error ??
                                incomingSnapshot.error ??
                                outgoingSnapshot.error ??
                                reviewSnapshot.error ??
                                conversationSnapshot.error;
                            if (error != null) {
                              return _HomeMessage(message: error.toString());
                            }

                            final mySkills = mySkillsSnapshot.data ?? [];
                            final offeredSkills = offeredSnapshot.data ?? [];
                            final incoming = incomingSnapshot.data ?? [];
                            final outgoing = outgoingSnapshot.data ?? [];
                            final reviews = reviewSnapshot.data ?? [];
                            final conversations =
                                conversationSnapshot.data ?? [];
                            final allRequests = [...incoming, ...outgoing];
                            final homeData = _HomeData.fromFirestore(
                              user: user,
                              mySkills: mySkills,
                              offeredSkills: offeredSkills,
                              requests: allRequests,
                              reviews: reviews,
                              conversations: conversations,
                            );

                            return _HomeContent(
                              data: homeData,
                              onSelectTab: onSelectTab,
                              onDiscoverSearch: onDiscoverSearch,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.data,
    this.onSelectTab,
    this.onDiscoverSearch,
  });

  final _HomeData data;
  final ValueChanged<int>? onSelectTab;
  final ValueChanged<String>? onDiscoverSearch;

  void _openDiscover(BuildContext context, {String query = ''}) {
    if (onDiscoverSearch != null) {
      onDiscoverSearch!(query);
      return;
    }

    if (onSelectTab != null) {
      onSelectTab!(1);
      return;
    }

    Navigator.of(context).pushNamed(AppRoutes.discover, arguments: query);
  }

  void _openMessages(BuildContext context) {
    if (onSelectTab != null) {
      onSelectTab!(3);
      return;
    }

    Navigator.of(context).pushNamed(AppRoutes.messages);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          return ListView(
            padding: EdgeInsets.fromLTRB(
              isWide ? 32 : 16,
              12,
              isWide ? 32 : 16,
              96,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HomeHeader(
                        user: data.user,
                        onOpenMessages: () => _openMessages(context),
                      ),
                      const SizedBox(height: 26),
                      _Greeting(summary: data.summary),
                      const SizedBox(height: 16),
                      _SearchField(
                        onOpenDiscover: (query) {
                          _openDiscover(context, query: query);
                        },
                      ),
                      const SizedBox(height: 24),
                      _MatchSummary(
                        summary: data.summary,
                        onOpenDiscover: () => _openDiscover(context),
                      ),
                      const SizedBox(height: 24),
                      _CategoryRail(
                        categories: data.categories,
                        onOpenDiscover: (category) {
                          _openDiscover(context, query: category);
                        },
                      ),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: 'Best matches for you',
                        actionLabel: 'See all',
                        onAction: () => _openDiscover(context),
                      ),
                      const SizedBox(height: 12),
                      _ResponsiveMatchGrid(
                        matches: data.matches.take(isWide ? 3 : 2).toList(),
                        isWide: isWide,
                      ),
                      const SizedBox(height: 28),
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _UpcomingSessionCard(
                                request: data.upcomingSession,
                                currentUserId: data.user.uid,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _RecentActivityList(
                                activities: data.activities,
                              ),
                            ),
                          ],
                        )
                      else ...[
                        Text(
                          'Upcoming session',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        _UpcomingSessionCard(
                          request: data.upcomingSession,
                          currentUserId: data.user.uid,
                        ),
                        const SizedBox(height: 26),
                        _RecentActivityList(activities: data.activities),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.user, required this.onOpenMessages});

  final AppUser user;
  final VoidCallback onOpenMessages;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.tealTint,
          backgroundImage: user.photoUrl.isEmpty
              ? null
              : NetworkImage(user.photoUrl),
          child: user.photoUrl.isEmpty
              ? const Icon(Icons.person, color: AppColors.primaryDark)
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          'SkillSwap',
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.primaryDark,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: onOpenMessages,
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Notifications',
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.summary});

  final _HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${summary.studentName}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Find a student who can learn from you and teach you something back.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _MetricPill(
          value: summary.activeSwapCount.toString(),
          label: 'Active',
          color: AppColors.primaryGreen,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onOpenDiscover});

  final ValueChanged<String> onOpenDiscover;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: onOpenDiscover,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search skills or students',
        suffixIcon: IconButton(
          onPressed: () => onOpenDiscover(''),
          icon: const Icon(Icons.tune),
          tooltip: 'Filters',
        ),
      ),
    );
  }
}

class _MatchSummary extends StatelessWidget {
  const _MatchSummary({required this.summary, required this.onOpenDiscover});

  final _HomeSummary summary;
  final VoidCallback onOpenDiscover;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      backgroundColor: AppColors.primaryGreen,
      borderColor: AppColors.primaryGreen,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'You have ${summary.potentialSwapCount} new potential swaps',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.cardWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'These students match what you can teach and what you want to learn.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.cardWhite),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: onOpenDiscover,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cardWhite,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                child: const Text('View matches'),
              ),
              _SummaryChip(
                label: '${summary.completedSessionCount} sessions completed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.categories, required this.onOpenDiscover});

  final List<String> categories;
  final ValueChanged<String> onOpenDiscover;

  @override
  Widget build(BuildContext context) {
    final visibleCategories = categories.isEmpty
        ? const ['Academic', 'Tech', 'Creative', 'Language']
        : categories;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in visibleCategories) ...[
            CategoryChip(
              label: category,
              selected: category == visibleCategories.first,
              onTap: () => onOpenDiscover(category),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveMatchGrid extends StatelessWidget {
  const _ResponsiveMatchGrid({required this.matches, required this.isWide});

  final List<_HomeMatch> matches;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (matches.isEmpty) {
      return const AppCard(
        child: Text(
          'No matches yet. Add wanted skills or seed demo data to discover students.',
        ),
      );
    }

    if (!isWide) {
      return Column(
        children: [
          for (final match in matches) ...[
            _HomeMatchCard(match: match),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return GridView.builder(
      itemCount: matches.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 318,
      ),
      itemBuilder: (context, index) => _HomeMatchCard(match: matches[index]),
    );
  }
}

class _HomeMatchCard extends StatelessWidget {
  const _HomeMatchCard({required this.match});

  final _HomeMatch match;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.tealTint,
                    child: Text(
                      match.teacherName.characters.first,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.teacherName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          match.university,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: '${match.matchPercent}% Match',
                  color: AppColors.warning,
                  icon: Icons.star_border_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SkillExchangePanel(match: match),
          const SizedBox(height: 16),
          AppButton(
            label: 'Request Swap',
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.requestSwap,
              arguments: RequestSwapArguments(
                selectedSkill: match.skill,
                teacherId: match.skill.ownerId,
                teacherName: match.teacherName,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillExchangePanel extends StatelessWidget {
  const _SkillExchangePanel({required this.match});

  final _HomeMatch match;

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
          Expanded(
            child: _SkillPair(
              label: 'Teaches',
              value: match.skill.title,
              icon: Icons.school_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SkillPair(
              label: 'Wants',
              value: match.wantsLabel,
              icon: Icons.code,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillPair extends StatelessWidget {
  const _SkillPair({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primaryDark,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({
    required this.request,
    required this.currentUserId,
  });

  final SwapRequest? request;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final session = request;
    final textTheme = Theme.of(context).textTheme;

    if (session == null) {
      return const AppCard(
        borderColor: AppColors.accentGold,
        child: Text('No upcoming accepted sessions yet.'),
      );
    }

    final isIncoming = session.toUserId == currentUserId;
    final partnerName = isIncoming ? session.fromUserName : session.toUserName;
    final skill = isIncoming
        ? session.offeredSkillTitle
        : session.wantedSkillTitle;

    return AppCard(
      borderColor: AppColors.accentGold,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.softGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: AppColors.primaryDark),
              ),
              const Spacer(),
              StatusChip(
                label: _sessionDayLabel(session.suggestedTime).toUpperCase(),
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text('$skill with $partnerName', style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '$partnerName teaches $skill',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
          ),
          const SizedBox(height: 14),
          _SessionDetail(
            icon: Icons.schedule,
            label: _timeLabel(session.suggestedTime),
          ),
          const SizedBox(height: 8),
          _SessionDetail(icon: Icons.videocam_outlined, label: session.mode),
          const SizedBox(height: 18),
          AppButton(
            label: 'Session Details',
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.swapDetails, arguments: session),
          ),
        ],
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textDark),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList({required this.activities});

  final List<_HomeActivity> activities;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent activity', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: activities.isEmpty
              ? Text(
                  'Your messages, swaps, and reviews will appear here.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                  ),
                )
              : Column(
                  children: [
                    for (final activity in activities) ...[
                      _ActivityTile(activity: activity),
                      if (activity != activities.last)
                        const Divider(height: 1, color: AppColors.border),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final _HomeActivity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: activity.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.icon, size: 20, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardWhite.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.cardWhite),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCard(
            child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}

class _HomeData {
  const _HomeData({
    required this.user,
    required this.summary,
    required this.categories,
    required this.matches,
    required this.upcomingSession,
    required this.activities,
  });

  final AppUser user;
  final _HomeSummary summary;
  final List<String> categories;
  final List<_HomeMatch> matches;
  final SwapRequest? upcomingSession;
  final List<_HomeActivity> activities;

  factory _HomeData.fromFirestore({
    required AppUser user,
    required List<firestore_skill.Skill> mySkills,
    required List<firestore_skill.Skill> offeredSkills,
    required List<SwapRequest> requests,
    required List<Review> reviews,
    required List<Conversation> conversations,
  }) {
    final activeRequests = requests.where((request) {
      return request.status == 'accepted';
    }).toList();
    final completedRequests = requests.where((request) {
      return request.status == 'completed';
    }).toList();
    final matches = _buildMatches(mySkills, offeredSkills);
    final upcomingSession = activeRequests.isEmpty
        ? null
        : (activeRequests..sort((a, b) {
                return a.suggestedTime.compareTo(b.suggestedTime);
              }))
              .first;
    final completedCount = completedRequests.length > user.completedSwaps
        ? completedRequests.length
        : user.completedSwaps;

    return _HomeData(
      user: user,
      summary: _HomeSummary(
        studentName: _firstName(user.fullName),
        potentialSwapCount: matches.length,
        activeSwapCount: activeRequests.length,
        completedSessionCount: completedCount,
      ),
      categories: _buildCategories(mySkills, offeredSkills),
      matches: matches,
      upcomingSession: upcomingSession,
      activities: _buildActivities(
        userId: user.uid,
        requests: requests,
        reviews: reviews,
        conversations: conversations,
      ),
    );
  }

  factory _HomeData.preview() {
    final user = AppUser(
      uid: 'preview_user',
      fullName: 'Dawit',
      email: 'preview@example.com',
      university: 'Addis Ababa University',
      department: 'Software Engineering',
      year: '3rd Year',
      bio: '',
      campus: '',
      photoUrl: '',
      rating: 4.8,
      completedSwaps: 8,
      profileCompleted: true,
      createdAt: DateTime(2026, 5, 29),
    );
    final skill = firestore_skill.Skill(
      id: 'preview_flutter',
      ownerId: 'preview_hana',
      ownerName: 'Hana Tadesse',
      ownerPhotoUrl: '',
      university: 'Addis Ababa University',
      title: 'UI Design',
      category: 'Creative',
      level: 'Intermediate',
      description: 'Practice clean mobile UI design.',
      type: 'offered',
      exchangeFor: 'Python',
      isActive: true,
      createdAt: DateTime(2026, 5, 29),
    );
    final request = SwapRequest(
      id: 'preview_swap',
      fromUserId: 'preview_user',
      fromUserName: 'Dawit',
      toUserId: 'preview_abel',
      toUserName: 'Abel',
      offeredSkillId: 'preview_python',
      offeredSkillTitle: 'Python',
      wantedSkillId: 'preview_guitar',
      wantedSkillTitle: 'Guitar Basics',
      message: 'Preview session',
      status: 'accepted',
      suggestedTime: DateTime(2026, 5, 30, 16),
      mode: 'Online',
      createdAt: DateTime(2026, 5, 29),
      updatedAt: DateTime(2026, 5, 29),
    );

    return _HomeData(
      user: user,
      summary: const _HomeSummary(
        studentName: 'Dawit',
        potentialSwapCount: 1,
        activeSwapCount: 1,
        completedSessionCount: 8,
      ),
      categories: const ['Academic', 'Tech', 'Creative', 'Language'],
      matches: [
        _HomeMatch(
          skill: skill,
          teacherName: skill.ownerName,
          university: skill.university,
          wantsLabel: skill.exchangeFor,
          matchPercent: 95,
        ),
      ],
      upcomingSession: request,
      activities: const [],
    );
  }
}

class _HomeSummary {
  const _HomeSummary({
    required this.studentName,
    required this.potentialSwapCount,
    required this.activeSwapCount,
    required this.completedSessionCount,
  });

  final String studentName;
  final int potentialSwapCount;
  final int activeSwapCount;
  final int completedSessionCount;
}

class _HomeMatch {
  const _HomeMatch({
    required this.skill,
    required this.teacherName,
    required this.university,
    required this.wantsLabel,
    required this.matchPercent,
  });

  final firestore_skill.Skill skill;
  final String teacherName;
  final String university;
  final String wantsLabel;
  final int matchPercent;
}

class _HomeActivity {
  const _HomeActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.createdAt,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final DateTime createdAt;
}

List<_HomeMatch> _buildMatches(
  List<firestore_skill.Skill> mySkills,
  List<firestore_skill.Skill> offeredSkills,
) {
  final wantedSkills = mySkills.where((skill) => skill.type == 'wanted');
  final offeredByMe = mySkills.where((skill) => skill.type == 'offered');
  final wantedText = wantedSkills
      .map((skill) => skill.title.toLowerCase())
      .join(' ');
  final myOfferText = offeredByMe
      .map((skill) => skill.title.toLowerCase())
      .join(' ');

  final matches = offeredSkills.map((skill) {
    final matchesWanted =
        wantedText.isNotEmpty && wantedText.contains(skill.title.toLowerCase());
    final exchangeText = skill.exchangeFor.toLowerCase();
    final matchesExchange =
        myOfferText.isNotEmpty && exchangeText.contains(myOfferText);
    final percent = matchesWanted
        ? 95
        : matchesExchange
        ? 88
        : 75;

    return _HomeMatch(
      skill: skill,
      teacherName: skill.ownerName.isEmpty ? 'Student' : skill.ownerName,
      university: skill.university.isEmpty
          ? 'University not shared'
          : skill.university,
      wantsLabel: skill.exchangeFor.isEmpty ? 'Open swap' : skill.exchangeFor,
      matchPercent: percent,
    );
  }).toList()..sort((a, b) => b.matchPercent.compareTo(a.matchPercent));

  return matches;
}

List<String> _buildCategories(
  List<firestore_skill.Skill> mySkills,
  List<firestore_skill.Skill> offeredSkills,
) {
  final categories = <String>{
    ...mySkills.map((skill) => skill.category),
    ...offeredSkills.map((skill) => skill.category),
  }..removeWhere((category) => category.trim().isEmpty);

  return categories.toList();
}

List<_HomeActivity> _buildActivities({
  required String userId,
  required List<SwapRequest> requests,
  required List<Review> reviews,
  required List<Conversation> conversations,
}) {
  final activities = <_HomeActivity>[];

  for (final conversation in conversations) {
    if (conversation.lastMessage.isEmpty) continue;
    final otherId = conversation.participants.firstWhere(
      (participantId) => participantId != userId,
      orElse: () => '',
    );
    final otherName = conversation.participantNames[otherId] ?? 'Student';
    activities.add(
      _HomeActivity(
        title: '$otherName sent a message',
        subtitle: _relativeTime(conversation.lastMessageAt),
        icon: Icons.chat_bubble_outline,
        tint: const Color(0xFFE6F5F3),
        createdAt: conversation.lastMessageAt,
      ),
    );
  }

  for (final request in requests) {
    final otherName = request.fromUserId == userId
        ? request.toUserName
        : request.fromUserName;
    activities.add(
      _HomeActivity(
        title: _requestActivityTitle(request.status, otherName),
        subtitle: _relativeTime(request.updatedAt),
        icon: request.status == 'accepted'
            ? Icons.handshake_outlined
            : Icons.swap_horiz,
        tint: const Color(0xFFFEF3C7),
        createdAt: request.updatedAt,
      ),
    );
  }

  for (final review in reviews) {
    activities.add(
      _HomeActivity(
        title: 'You received a session review',
        subtitle: _relativeTime(review.createdAt),
        icon: Icons.star_border_rounded,
        tint: const Color(0xFFEAF2FF),
        createdAt: review.createdAt,
      ),
    );
  }

  activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return activities.take(3).toList();
}

String _requestActivityTitle(String status, String otherName) {
  final name = otherName.isEmpty ? 'Student' : otherName;

  return switch (status) {
    'pending' => '$name requested a swap',
    'accepted' => '$name accepted your swap',
    'completed' => 'Session completed with $name',
    'declined' => '$name declined a swap',
    'cancelled' => '$name cancelled a swap',
    _ => 'Swap updated with $name',
  };
}

String _firstName(String fullName) {
  final trimmed = fullName.trim();
  if (trimmed.isEmpty) return 'Student';

  return trimmed.split(' ').first;
}

String _sessionDayLabel(DateTime date) {
  final now = DateTime.now();
  final tomorrow = now.add(const Duration(days: 1));

  if (_sameDay(date, now)) return 'Today';
  if (_sameDay(date, tomorrow)) return 'Tomorrow';

  return '${date.month}/${date.day}';
}

String _timeLabel(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _relativeTime(DateTime date) {
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} hours ago';
  if (difference.inDays == 1) return 'Yesterday';

  return '${difference.inDays} days ago';
}

bool _sameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}
