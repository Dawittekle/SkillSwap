import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/core/widgets/app_search_bar.dart';
import 'package:skill_swap/src/core/widgets/skill_card.dart';
import 'package:skill_swap/src/data/mock/mock_skills.dart';
import 'package:skill_swap/src/data/mock/mock_students.dart';
import 'package:skill_swap/src/data/models/skill.dart';
import 'package:skill_swap/src/data/models/student.dart';

class DiscoverTab extends StatefulWidget {
  const DiscoverTab({super.key});

  @override
  State<DiscoverTab> createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  String _selectedCategory = 'All';
  String _query = '';
  Set<String> _selectedMode = const {'offered'};

  List<String> get _categories => [
    'All',
    ...mockSkills.map((skill) => skill.category).toSet(),
  ];

  List<Skill> get _filteredSkills {
    final normalizedQuery = _query.trim().toLowerCase();

    return mockSkills.where((skill) {
      final matchesCategory =
          _selectedCategory == 'All' || skill.category == _selectedCategory;
      final matchesQuery =
          normalizedQuery.isEmpty ||
          skill.title.toLowerCase().contains(normalizedQuery) ||
          skill.description.toLowerCase().contains(normalizedQuery) ||
          skill.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery));

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 760;
          final skills = _filteredSkills;

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
                        onChanged: (value) => setState(() => _query = value),
                        onFilterPressed: () {},
                      ),
                      const SizedBox(height: 20),
                      _CategoryScroller(
                        categories: _categories,
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
                      _DiscoverSummary(
                        resultCount: skills.length,
                        selectedCategory: _selectedCategory,
                      ),
                      const SizedBox(height: 16),
                      if (skills.isEmpty)
                        const _EmptySkillsState()
                      else
                        _SkillResultsGrid(skills: skills, isWide: isWide),
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
  const _SkillResultsGrid({required this.skills, required this.isWide});

  final List<Skill> skills;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (final skill in skills) ...[
            SkillCard(
              skill: skill,
              owner: _ownerFor(skill),
              onConnect: () =>
                  Navigator.of(context).pushNamed(AppRoutes.requestSwap),
              onViewDetails: () => _openDetails(context, skill),
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

        return SkillCard(
          skill: skill,
          owner: _ownerFor(skill),
          onConnect: () =>
              Navigator.of(context).pushNamed(AppRoutes.requestSwap),
          onViewDetails: () => _openDetails(context, skill),
        );
      },
    );
  }

  void _openDetails(BuildContext context, Skill skill) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.skillDetails, arguments: skill.id);
  }
}

class _EmptySkillsState extends StatelessWidget {
  const _EmptySkillsState();

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
          Text(
            'No skills found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Try another search term or category.',
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

Student _ownerFor(Skill skill) {
  return mockStudents.firstWhere(
    (student) => student.id == skill.ownerId,
    orElse: () => mockStudents.first,
  );
}
