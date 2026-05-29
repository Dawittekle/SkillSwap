import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/core/widgets/app_search_bar.dart';
import 'package:skill_swap/src/core/widgets/skill_card.dart';
import 'package:skill_swap/src/data/mock/mock_skills.dart';
import 'package:skill_swap/src/features/skills/skill_ui_adapters.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({
    super.key,
    this.authService,
    this.skillRepository,
    this.userRepository,
  });

  final AuthService? authService;
  final SkillRepository? skillRepository;
  final UserRepository? userRepository;

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  String _selectedCategory = 'All';
  String _query = '';
  Set<String> _selectedMode = const {'offered'};

  AuthService get _authService => widget.authService ?? AuthService();
  SkillRepository get _skillRepository =>
      widget.skillRepository ?? SkillRepository();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();

  List<String> _categoriesFor(List<firestore_skill.Skill> skills) => [
    'All',
    ...{
      ...mockSkills.map((skill) => skill.category),
      ...skills.map((skill) => skill.category).where((category) {
        return category.trim().isNotEmpty;
      }),
    },
  ];

  List<firestore_skill.Skill> _filteredSkills(
    List<firestore_skill.Skill> skills,
    Map<String, AppUser> usersById,
  ) {
    final normalizedQuery = _query.trim().toLowerCase();

    return skills.where((skill) {
      final matchesCategory =
          _selectedCategory == 'All' || skill.category == _selectedCategory;
      final matchesMode = _selectedMode.contains(skill.type);
      final matchesQuery =
          normalizedQuery.isEmpty ||
          skill.title.toLowerCase().contains(normalizedQuery) ||
          skill.description.toLowerCase().contains(normalizedQuery) ||
          skill.category.toLowerCase().contains(normalizedQuery) ||
          skill.level.toLowerCase().contains(normalizedQuery) ||
          skill.exchangeFor.toLowerCase().contains(normalizedQuery) ||
          skill.ownerName.toLowerCase().contains(normalizedQuery) ||
          skill.university.toLowerCase().contains(normalizedQuery) ||
          (usersById[skill.ownerId]?.department.toLowerCase().contains(
                normalizedQuery,
              ) ??
              false);

      return matchesCategory && matchesMode && matchesQuery;
    }).toList();
  }

  Future<Map<String, AppUser>> _loadUsersForSkills(
    String currentUserId,
    List<firestore_skill.Skill> skills,
  ) async {
    final userIds = {currentUserId, ...skills.map((skill) => skill.ownerId)};
    final usersById = <String, AppUser>{};

    for (final userId in userIds) {
      final user = await _userRepository.getUser(userId);
      if (user != null) usersById[userId] = user;
    }

    return usersById;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final currentUser = _authService.currentUser;

          if (currentUser == null) {
            return const Center(
              child: Text('Please login to discover skills.'),
            );
          }

          return StreamBuilder<List<firestore_skill.Skill>>(
            stream: _skillRepository.watchOfferedSkillsExcludingUser(
              currentUser.uid,
            ),
            builder: (context, snapshot) {
              final allSkills = snapshot.data ?? [];

              return ListView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 32 : 16,
                  18,
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
                          const _DiscoverHeader(),
                          const SizedBox(height: 16),
                          SkillSearchBar(
                            hintText: 'Search for Python, Guitar, French...',
                            onChanged: (value) =>
                                setState(() => _query = value),
                            onFilterPressed: () {},
                          ),
                          const SizedBox(height: 20),
                          _CategoryScroller(
                            categories: _categoriesFor(allSkills),
                            selectedCategory: _selectedCategory,
                            onSelected: (category) {
                              setState(() => _selectedCategory = category);
                            },
                          ),
                          const SizedBox(height: 22),
                          _ModeSwitcher(
                            selectedMode: _selectedMode,
                            onChanged: (selection) {
                              setState(() => _selectedMode = selection);
                            },
                          ),
                          const SizedBox(height: 20),
                          StreamBuilder<List<firestore_skill.Skill>>(
                            stream: _skillRepository.watchCurrentUserSkills(
                              currentUser.uid,
                            ),
                            builder: (context, mySkillsSnapshot) {
                              return FutureBuilder<Map<String, AppUser>>(
                                future: _loadUsersForSkills(
                                  currentUser.uid,
                                  allSkills,
                                ),
                                builder: (context, usersSnapshot) {
                                  final usersById = usersSnapshot.data ?? {};
                                  final skills = _filteredSkills(
                                    allSkills,
                                    usersById,
                                  );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _DiscoverSummary(
                                        resultCount: skills.length,
                                        selectedCategory: _selectedCategory,
                                      ),
                                      const SizedBox(height: 16),
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          mySkillsSnapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          usersSnapshot.connectionState ==
                                              ConnectionState.waiting)
                                        const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(24),
                                            child: CircularProgressIndicator(
                                              color: AppColors.primaryGreen,
                                            ),
                                          ),
                                        )
                                      else if (snapshot.hasError)
                                        _DiscoverErrorState(
                                          message: snapshot.error,
                                        )
                                      else if (mySkillsSnapshot.hasError)
                                        _DiscoverErrorState(
                                          message: mySkillsSnapshot.error,
                                        )
                                      else if (usersSnapshot.hasError)
                                        _DiscoverErrorState(
                                          message: usersSnapshot.error,
                                        )
                                      else if (allSkills.isEmpty)
                                        const _EmptySkillsState(
                                          title: 'No student skills yet',
                                          message:
                                              'Discover needs active offered skills from other students.',
                                        )
                                      else if (skills.isEmpty)
                                        const _EmptySkillsState(
                                          title: 'No skills found',
                                          message:
                                              'Try another search term, student name, department, or category.',
                                        )
                                      else
                                        _SkillResultsGrid(
                                          skills: skills,
                                          isWide: isWide,
                                          currentUser:
                                              usersById[currentUser.uid],
                                          usersById: usersById,
                                          mySkills: mySkillsSnapshot.data ?? [],
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Discover Skills', style: textTheme.headlineLarge),
              const SizedBox(height: 6),
              Text(
                'Browse students who are ready to teach and swap.',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppColors.softGold,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.explore_outlined,
            color: AppColors.primaryDark,
          ),
        ),
      ],
    );
  }
}

class _CategoryScroller extends StatelessWidget {
  const _CategoryScroller({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in categories) ...[
            CategoryChip(
              label: category,
              selected: category == selectedCategory,
              icon: category == 'All'
                  ? Icons.grid_view_rounded
                  : categoryIcon(category),
              onTap: () => onSelected(category),
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  const _ModeSwitcher({required this.selectedMode, required this.onChanged});

  final Set<String> selectedMode;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'offered',
          label: Text('Skills Offered'),
          icon: Icon(Icons.school_outlined),
        ),
        ButtonSegment(
          value: 'wanted',
          label: Text('Skills Wanted'),
          icon: Icon(Icons.search),
        ),
      ],
      selected: selectedMode,
      onSelectionChanged: onChanged,
    );
  }
}

class _DiscoverSummary extends StatelessWidget {
  const _DiscoverSummary({
    required this.resultCount,
    required this.selectedCategory,
  });

  final int resultCount;
  final String selectedCategory;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      backgroundColor: AppColors.tealTint,
      borderColor: AppColors.tealTint,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$resultCount ${resultCount == 1 ? 'match' : 'matches'} in $selectedCategory',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextButton(onPressed: () {}, child: const Text('Sort')),
        ],
      ),
    );
  }
}

class _SkillResultsGrid extends StatelessWidget {
  const _SkillResultsGrid({
    required this.skills,
    required this.isWide,
    required this.currentUser,
    required this.usersById,
    required this.mySkills,
  });

  final List<firestore_skill.Skill> skills;
  final bool isWide;
  final AppUser? currentUser;
  final Map<String, AppUser> usersById;
  final List<firestore_skill.Skill> mySkills;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (final skill in skills) ...[
            Builder(
              builder: (context) {
                final owner = usersById[skill.ownerId];
                final match = _matchForSkill(
                  skill,
                  owner,
                  currentUser,
                  mySkills,
                );
                return SkillCard(
                  skill: uiSkillFromFirestore(skill),
                  owner: studentFromSkillOwner(skill, user: owner),
                  matchScore: match.score,
                  matchLabel: match.label,
                  onConnect: () => _openRequestSwap(context, skill),
                  onViewDetails: () => _openDetails(context, skill),
                );
              },
            ),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return GridView.builder(
      itemCount: skills.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 332,
      ),
      itemBuilder: (context, index) {
        final skill = skills[index];
        final owner = usersById[skill.ownerId];
        final match = _matchForSkill(skill, owner, currentUser, mySkills);

        return SkillCard(
          skill: uiSkillFromFirestore(skill),
          owner: studentFromSkillOwner(skill, user: owner),
          matchScore: match.score,
          matchLabel: match.label,
          onConnect: () => _openRequestSwap(context, skill),
          onViewDetails: () => _openDetails(context, skill),
        );
      },
    );
  }

  void _openDetails(BuildContext context, firestore_skill.Skill skill) {
    Navigator.of(context).pushNamed(AppRoutes.skillDetails, arguments: skill);
  }

  void _openRequestSwap(BuildContext context, firestore_skill.Skill skill) {
    Navigator.of(context).pushNamed(
      AppRoutes.requestSwap,
      arguments: RequestSwapArguments(
        selectedSkill: skill,
        teacherName: skill.ownerName,
        teacherId: skill.ownerId,
      ),
    );
  }
}

class _MatchScore {
  const _MatchScore({required this.score, required this.label});

  final int score;
  final String label;
}

_MatchScore _matchForSkill(
  firestore_skill.Skill skill,
  AppUser? owner,
  AppUser? currentUser,
  List<firestore_skill.Skill> mySkills,
) {
  var score = 40;
  final myWantedSkills = mySkills.where((skill) => skill.type == 'wanted');
  final myOfferedSkills = mySkills.where((skill) => skill.type == 'offered');
  final offeredSkillMatchesWanted = myWantedSkills.any((wantedSkill) {
    return _textsMatch(skill.title, wantedSkill.title) ||
        _textsMatch(skill.category, wantedSkill.category);
  });
  final exchangeMatchesMyOffer = myOfferedSkills.any((offeredSkill) {
    return _textsMatch(skill.exchangeFor, offeredSkill.title) ||
        _textsMatch(skill.exchangeFor, offeredSkill.category);
  });
  final sameUniversity =
      currentUser != null &&
      currentUser.university.isNotEmpty &&
      currentUser.university.toLowerCase() ==
          (owner?.university.isNotEmpty == true
                  ? owner!.university
                  : skill.university)
              .toLowerCase();
  final sameCampus =
      currentUser != null &&
      owner != null &&
      currentUser.campus.isNotEmpty &&
      currentUser.campus.toLowerCase() == owner.campus.toLowerCase();

  if (offeredSkillMatchesWanted) score += 30;
  if (exchangeMatchesMyOffer) score += 30;
  if (sameUniversity || sameCampus) score += 10;
  if ((owner?.rating ?? 0) >= 4.5) score += 5;

  final cappedScore = score > 100 ? 100 : score;
  return _MatchScore(score: cappedScore, label: _matchLabel(cappedScore));
}

bool _textsMatch(String first, String second) {
  final normalizedFirst = first.trim().toLowerCase();
  final normalizedSecond = second.trim().toLowerCase();
  if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) return false;

  return normalizedFirst.contains(normalizedSecond) ||
      normalizedSecond.contains(normalizedFirst);
}

String _matchLabel(int score) {
  if (score >= 90) return 'Great Match';
  if (score >= 70) return 'Good Match';
  if (score >= 50) return 'Possible Match';

  return 'Low Match';
}

class _EmptySkillsState extends StatelessWidget {
  const _EmptySkillsState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.softGold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_off, color: AppColors.primaryDark),
          ),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
          ),
        ],
      ),
    );
  }
}

class _DiscoverErrorState extends StatelessWidget {
  const _DiscoverErrorState({required this.message});

  final Object? message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Text(
        message?.toString() ?? 'Could not load discover skills.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
