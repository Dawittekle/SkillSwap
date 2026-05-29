import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/routing/app_routes.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/widgets/app_chip.dart';
import 'package:skill_swap/core/widgets/app_text_field.dart';
import 'package:skill_swap/features/discover/widgets/skill_card.dart';
import 'package:skill_swap/demo/mock_skills.dart';
import 'package:skill_swap/features/discover/widgets/skill_ui_adapters.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({
    super.key,
    this.authService,
    this.skillRepository,
    this.userRepository,
    this.initialQuery = '',
  });

  final AuthService? authService;
  final SkillRepository? skillRepository;
  final UserRepository? userRepository;
  final String initialQuery;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  late final TextEditingController _searchController;
  String _selectedCategory = 'All';
  String _query = '';
  Set<String> _selectedMode = const {'offered'};

  AuthService get _authService => widget.authService ?? AuthService();
  SkillRepository get _skillRepository =>
      widget.skillRepository ?? SkillRepository();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery;
    _searchController = TextEditingController(text: widget.initialQuery);
  }

  @override
  void didUpdateWidget(covariant DiscoverPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialQuery != oldWidget.initialQuery &&
        widget.initialQuery != _query) {
      setState(() => _query = widget.initialQuery);
      _searchController.text = widget.initialQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
    final normalizedQuery = _normalizeText(_query);

    return skills.where((skill) {
      final matchesCategory =
          _selectedCategory == 'All' || skill.category == _selectedCategory;
      final matchesMode = _selectedMode.contains(skill.type);
      final owner = usersById[skill.ownerId];
      final matchesQuery =
          normalizedQuery.isEmpty ||
          _containsQuery(skill.title, normalizedQuery) ||
          _containsQuery(skill.description, normalizedQuery) ||
          _containsQuery(skill.category, normalizedQuery) ||
          _containsQuery(skill.level, normalizedQuery) ||
          _containsQuery(skill.exchangeFor, normalizedQuery) ||
          _containsQuery(skill.ownerName, normalizedQuery) ||
          _containsQuery(skill.university, normalizedQuery) ||
          _containsQuery(owner?.department ?? '', normalizedQuery);

      return matchesCategory && matchesMode && matchesQuery;
    }).toList();
  }

  List<firestore_skill.Skill> _sortByBestMatch(
    List<firestore_skill.Skill> skills,
    AppUser? currentUser,
    Map<String, AppUser> usersById,
    List<firestore_skill.Skill> mySkills,
  ) {
    final sortedSkills = [...skills];
    sortedSkills.sort((first, second) {
      final firstMatch = _matchForSkill(
        first,
        usersById[first.ownerId],
        currentUser,
        mySkills,
      );
      final secondMatch = _matchForSkill(
        second,
        usersById[second.ownerId],
        currentUser,
        mySkills,
      );

      final scoreCompare = secondMatch.score.compareTo(firstMatch.score);
      if (scoreCompare != 0) return scoreCompare;

      return second.createdAt.compareTo(first.createdAt);
    });

    return sortedSkills;
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
                            controller: _searchController,
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
                                  final currentAppUser =
                                      usersById[currentUser.uid];
                                  final mySkills = mySkillsSnapshot.data ?? [];
                                  final filteredSkills = _filteredSkills(
                                    allSkills,
                                    usersById,
                                  );
                                  final skills = _sortByBestMatch(
                                    filteredSkills,
                                    currentAppUser,
                                    usersById,
                                    mySkills,
                                  );

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _DiscoverSummary(
                                        resultCount: skills.length,
                                        selectedCategory: _selectedCategory,
                                        onSortPressed: () {
                                          setState(() {});
                                        },
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
                                          currentUser: currentAppUser,
                                          usersById: usersById,
                                          mySkills: mySkills,
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
    required this.onSortPressed,
  });

  final int resultCount;
  final String selectedCategory;
  final VoidCallback onSortPressed;

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
          TextButton(onPressed: onSortPressed, child: const Text('Sort')),
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
  var score = 0;
  final myWantedSkills = mySkills.where((skill) => skill.type == 'wanted');
  final myOfferedSkills = mySkills.where((skill) => skill.type == 'offered');
  final offeredSkillMatchesWanted = myWantedSkills.any((wantedSkill) {
    return _skillMatchesWantedSkill(skill, wantedSkill);
  });
  final exchangeMatchesMyOffer = myOfferedSkills.any((offeredSkill) {
    return _exchangeMatchesOfferedSkill(skill, offeredSkill);
  });
  final categoryMatchesWanted = myWantedSkills.any((wantedSkill) {
    return _exactTextMatch(skill.category, wantedSkill.category);
  });

  if (offeredSkillMatchesWanted) score += 50;
  if (exchangeMatchesMyOffer) score += 30;
  if (categoryMatchesWanted) score += 10;
  if (_sameUniversityOrCampus(skill, owner, currentUser)) score += 5;
  if ((owner?.rating ?? 0) >= 4.5) score += 5;

  final cappedScore = score > 100 ? 100 : score;
  return _MatchScore(score: cappedScore, label: _matchLabel(cappedScore));
}

bool _skillMatchesWantedSkill(
  firestore_skill.Skill otherSkill,
  firestore_skill.Skill wantedSkill,
) {
  if (_exactTextMatch(otherSkill.title, wantedSkill.title)) return true;
  if (_exactTextMatch(otherSkill.category, wantedSkill.category)) return true;

  return _meaningfulTextMatch(otherSkill.title, wantedSkill.title) ||
      _meaningfulTextMatch(otherSkill.description, wantedSkill.title) ||
      _meaningfulTextMatch(otherSkill.title, wantedSkill.category) ||
      _meaningfulTextMatch(otherSkill.description, wantedSkill.category) ||
      _meaningfulTextMatch(otherSkill.description, wantedSkill.description);
}

bool _exchangeMatchesOfferedSkill(
  firestore_skill.Skill otherSkill,
  firestore_skill.Skill offeredSkill,
) {
  return _exactTextMatch(otherSkill.exchangeFor, offeredSkill.title) ||
      _exactTextMatch(otherSkill.exchangeFor, offeredSkill.category) ||
      _meaningfulTextMatch(otherSkill.exchangeFor, offeredSkill.title) ||
      _meaningfulTextMatch(otherSkill.exchangeFor, offeredSkill.category) ||
      _meaningfulTextMatch(otherSkill.exchangeFor, offeredSkill.description);
}

bool _sameUniversityOrCampus(
  firestore_skill.Skill skill,
  AppUser? owner,
  AppUser? currentUser,
) {
  if (currentUser == null) return false;

  final ownerUniversity = owner?.university.trim().isNotEmpty == true
      ? owner!.university
      : skill.university;
  final sameUniversity =
      _normalizeText(currentUser.university).isNotEmpty &&
      _normalizeText(currentUser.university) == _normalizeText(ownerUniversity);
  final sameCampus =
      owner != null &&
      _normalizeText(currentUser.campus).isNotEmpty &&
      _normalizeText(currentUser.campus) == _normalizeText(owner.campus);

  return sameUniversity || sameCampus;
}

bool _exactTextMatch(String first, String second) {
  final normalizedFirst = _normalizeText(first);
  final normalizedSecond = _normalizeText(second);
  if (normalizedFirst.isEmpty || normalizedSecond.isEmpty) return false;

  return normalizedFirst == normalizedSecond;
}

bool _meaningfulTextMatch(String source, String target) {
  final sourceText = _normalizeText(source);
  final targetText = _normalizeText(target);
  if (sourceText.isEmpty || targetText.isEmpty) return false;

  if (_isMeaningfulPhrase(targetText) && sourceText.contains(targetText)) {
    return true;
  }
  if (_isMeaningfulPhrase(sourceText) && targetText.contains(sourceText)) {
    return true;
  }

  final sourceWords = _keywords(sourceText);
  final targetWords = _keywords(targetText);

  return targetWords.any(sourceWords.contains);
}

bool _containsQuery(String value, String normalizedQuery) {
  return _normalizeText(value).contains(normalizedQuery);
}

String _normalizeText(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}

bool _isMeaningfulPhrase(String value) {
  final words = _keywords(value);
  return words.isNotEmpty && value.length >= 3;
}

List<String> _keywords(String value) {
  return _normalizeText(value).split(RegExp(r'[^a-z0-9]+')).where((word) {
    return word.length >= 3 && !_ignoredMatchWords.contains(word);
  }).toList();
}

String _matchLabel(int score) {
  if (score >= 85) return 'Great Match';
  if (score >= 65) return 'Good Match';
  if (score >= 40) return 'Possible Match';
  if (score >= 1) return 'Low Match';

  return 'Not a Match';
}

const _ignoredMatchWords = {
  'basic',
  'basics',
  'beginner',
  'beginners',
  'intermediate',
  'advanced',
  'skill',
  'skills',
  'lesson',
  'lessons',
  'class',
  'classes',
  'course',
  'courses',
  'teach',
  'learn',
  'learning',
  'tutor',
  'tutoring',
};

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
