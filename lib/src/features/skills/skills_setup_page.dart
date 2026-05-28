import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';

class SkillsSetupPage extends StatefulWidget {
  const SkillsSetupPage({
    super.key,
    this.authService,
    this.userRepository,
    this.skillRepository,
  });

  final AuthService? authService;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;

  @override
  State<SkillsSetupPage> createState() => _SkillsSetupPageState();
}

class _SkillsSetupPageState extends State<SkillsSetupPage> {
  final _offeredKey = GlobalKey<FormState>();
  final _wantedKey = GlobalKey<FormState>();
  final _offeredTitleController = TextEditingController();
  final _offeredExchangeForController = TextEditingController();
  final _offeredDescriptionController = TextEditingController();
  final _wantedTitleController = TextEditingController();
  final _wantedExchangeForController = TextEditingController();
  final _wantedDescriptionController = TextEditingController();

  String _offeredCategory = 'Tech';
  String _offeredLevel = 'Beginner';
  String _wantedCategory = 'Academic';
  String _wantedLevel = 'Beginner';
  bool _isSavingOffered = false;
  bool _isSavingWanted = false;

  static const _categories = [
    'Academic',
    'Tech',
    'Creative',
    'Language',
    'Music',
  ];
  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];

  AuthService get _authService => widget.authService ?? AuthService();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();
  SkillRepository get _skillRepository =>
      widget.skillRepository ?? SkillRepository();

  @override
  void dispose() {
    _offeredTitleController.dispose();
    _offeredExchangeForController.dispose();
    _offeredDescriptionController.dispose();
    _wantedTitleController.dispose();
    _wantedExchangeForController.dispose();
    _wantedDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSetupSkill(String type) async {
    final isOffered = type == 'offered';
    final formKey = isOffered ? _offeredKey : _wantedKey;
    if (!formKey.currentState!.validate()) return;

    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      showAuthMessage(
        context,
        'Please login again to add skills.',
        isError: true,
      );
      return;
    }

    setState(() {
      if (isOffered) {
        _isSavingOffered = true;
      } else {
        _isSavingWanted = true;
      }
    });

    try {
      final appUser = await _userRepository.getUser(firebaseUser.uid);
      if (appUser == null) {
        throw Exception('Please complete your profile before adding skills.');
      }

      final titleController = isOffered
          ? _offeredTitleController
          : _wantedTitleController;
      final existingSkills = await _skillRepository.getCurrentUserSkills(
        firebaseUser.uid,
      );
      final hasDuplicate = existingSkills.any((skill) {
        return _normalize(skill.title) == _normalize(titleController.text) &&
            skill.type == type;
      });

      if (hasDuplicate) {
        throw Exception('You already added this skill.');
      }

      await _skillRepository.createSkill(
        firestore_skill.Skill(
          id: '',
          ownerId: firebaseUser.uid,
          ownerName: appUser.fullName,
          ownerPhotoUrl: appUser.photoUrl,
          university: appUser.university,
          title: titleController.text.trim(),
          category: isOffered ? _offeredCategory : _wantedCategory,
          level: isOffered ? _offeredLevel : _wantedLevel,
          description:
              (isOffered
                      ? _offeredDescriptionController
                      : _wantedDescriptionController)
                  .text
                  .trim(),
          type: type,
          exchangeFor:
              (isOffered
                      ? _offeredExchangeForController
                      : _wantedExchangeForController)
                  .text
                  .trim(),
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );

      _clearForm(isOffered: isOffered);

      if (!mounted) return;
      showAuthMessage(context, 'Skill saved.');
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSavingOffered = false;
          _isSavingWanted = false;
        });
      }
    }
  }

  void _clearForm({required bool isOffered}) {
    if (isOffered) {
      _offeredTitleController.clear();
      _offeredExchangeForController.clear();
      _offeredDescriptionController.clear();
    } else {
      _wantedTitleController.clear();
      _wantedExchangeForController.clear();
      _wantedDescriptionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Skills Setup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add your first skills',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add at least one skill you can teach and one skill you want to learn.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SetupProgress(
                      uid: currentUser?.uid ?? '',
                      skillRepository: _skillRepository,
                    ),
                    const SizedBox(height: 18),
                    _SetupSkillCard(
                      formKey: _offeredKey,
                      title: 'Skill I can teach',
                      typeLabel: 'Offered',
                      titleController: _offeredTitleController,
                      exchangeForController: _offeredExchangeForController,
                      descriptionController: _offeredDescriptionController,
                      selectedCategory: _offeredCategory,
                      selectedLevel: _offeredLevel,
                      categories: _categories,
                      levels: _levels,
                      isSaving: _isSavingOffered,
                      onCategoryChanged: (value) =>
                          setState(() => _offeredCategory = value),
                      onLevelChanged: (value) =>
                          setState(() => _offeredLevel = value),
                      onSave: () => _saveSetupSkill('offered'),
                    ),
                    const SizedBox(height: 16),
                    _SetupSkillCard(
                      formKey: _wantedKey,
                      title: 'Skill I want to learn',
                      typeLabel: 'Wanted',
                      titleController: _wantedTitleController,
                      exchangeForController: _wantedExchangeForController,
                      descriptionController: _wantedDescriptionController,
                      selectedCategory: _wantedCategory,
                      selectedLevel: _wantedLevel,
                      categories: _categories,
                      levels: _levels,
                      isSaving: _isSavingWanted,
                      onCategoryChanged: (value) =>
                          setState(() => _wantedCategory = value),
                      onLevelChanged: (value) =>
                          setState(() => _wantedLevel = value),
                      onSave: () => _saveSetupSkill('wanted'),
                    ),
                    const SizedBox(height: 18),
                    _ContinueHomeButton(
                      uid: currentUser?.uid ?? '',
                      skillRepository: _skillRepository,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetupProgress extends StatelessWidget {
  const _SetupProgress({required this.uid, required this.skillRepository});

  final String uid;
  final SkillRepository skillRepository;

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<firestore_skill.Skill>>(
      stream: skillRepository.watchCurrentUserSkills(uid),
      builder: (context, snapshot) {
        final skills = snapshot.data ?? [];
        final offeredCount = skills
            .where((skill) => skill.type == 'offered' && skill.isActive)
            .length;
        final wantedCount = skills
            .where((skill) => skill.type == 'wanted' && skill.isActive)
            .length;

        return AppCard(
          backgroundColor: AppColors.tealTint,
          borderColor: AppColors.tealTint,
          padding: const EdgeInsets.all(16),
          child: Text(
            'Saved: $offeredCount offered skill${offeredCount == 1 ? '' : 's'} and $wantedCount wanted skill${wantedCount == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        );
      },
    );
  }
}

class _ContinueHomeButton extends StatelessWidget {
  const _ContinueHomeButton({required this.uid, required this.skillRepository});

  final String uid;
  final SkillRepository skillRepository;

  @override
  Widget build(BuildContext context) {
    if (uid.isEmpty) {
      return const AppButton(
        label: 'Continue to Home',
        icon: Icons.arrow_forward,
        onPressed: null,
      );
    }

    return StreamBuilder<List<firestore_skill.Skill>>(
      stream: skillRepository.watchCurrentUserSkills(uid),
      builder: (context, snapshot) {
        final skills = snapshot.data ?? [];
        final hasOffered = skills.any((skill) {
          return skill.type == 'offered' && skill.isActive;
        });
        final hasWanted = skills.any((skill) {
          return skill.type == 'wanted' && skill.isActive;
        });
        final canContinue = hasOffered && hasWanted;

        return AppButton(
          label: canContinue
              ? 'Continue to Home'
              : 'Add one offered and one wanted skill',
          icon: Icons.arrow_forward,
          onPressed: canContinue
              ? () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false)
              : null,
        );
      },
    );
  }
}

class _SetupSkillCard extends StatelessWidget {
  const _SetupSkillCard({
    required this.formKey,
    required this.title,
    required this.typeLabel,
    required this.titleController,
    required this.exchangeForController,
    required this.descriptionController,
    required this.selectedCategory,
    required this.selectedLevel,
    required this.categories,
    required this.levels,
    required this.isSaving,
    required this.onCategoryChanged,
    required this.onLevelChanged,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final String title;
  final String typeLabel;
  final TextEditingController titleController;
  final TextEditingController exchangeForController;
  final TextEditingController descriptionController;
  final String selectedCategory;
  final String selectedLevel;
  final List<String> categories;
  final List<String> levels;
  final bool isSaving;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              typeLabel,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => validateRequired(value, 'Title'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                if (value != null) onCategoryChanged(value);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: selectedLevel,
              decoration: const InputDecoration(labelText: 'Level'),
              items: levels.map((level) {
                return DropdownMenuItem(value: level, child: Text(level));
              }).toList(),
              onChanged: (value) {
                if (value != null) onLevelChanged(value);
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: exchangeForController,
              decoration: const InputDecoration(labelText: 'Exchange for'),
              validator: (value) => validateRequired(value, 'Exchange for'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => validateRequired(value, 'Description'),
            ),
            const SizedBox(height: 18),
            AppButton(
              label: isSaving ? 'Saving...' : 'Save $typeLabel Skill',
              icon: Icons.check,
              onPressed: isSaving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}
