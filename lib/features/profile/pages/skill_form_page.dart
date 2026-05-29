import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/utils/app_validators.dart';

class SkillFormArguments {
  const SkillFormArguments({this.skill, this.initialType = 'offered'});

  final firestore_skill.Skill? skill;
  final String initialType;
}

class SkillFormPage extends StatefulWidget {
  const SkillFormPage({
    super.key,
    this.arguments = const SkillFormArguments(),
    this.authService,
    this.userRepository,
    this.skillRepository,
  });

  final SkillFormArguments arguments;
  final AuthService? authService;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;

  @override
  State<SkillFormPage> createState() => _SkillFormPageState();
}

class _SkillFormPageState extends State<SkillFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _exchangeForController = TextEditingController();

  late String _category;
  late String _level;
  late String _type;
  bool _isSaving = false;

  static const _categories = [
    'Academic',
    'Tech',
    'Creative',
    'Language',
    'Music',
  ];
  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const _types = ['offered', 'wanted'];

  AuthService get _authService => widget.authService ?? AuthService();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();
  SkillRepository get _skillRepository =>
      widget.skillRepository ?? SkillRepository();

  firestore_skill.Skill? get _editingSkill => widget.arguments.skill;

  @override
  void initState() {
    super.initState();
    final skill = _editingSkill;
    _titleController.text = skill?.title ?? '';
    _descriptionController.text = skill?.description ?? '';
    _exchangeForController.text = skill?.exchangeFor ?? '';
    _category = _safeValue(skill?.category, _categories, 'Academic');
    _level = _safeValue(skill?.level, _levels, 'Beginner');
    _type = _safeValue(skill?.type, _types, widget.arguments.initialType);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _exchangeForController.dispose();
    super.dispose();
  }

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;

    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) {
      showAuthMessage(
        context,
        'Please login again to save a skill.',
        isError: true,
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final appUser = await _userRepository.getUser(firebaseUser.uid);
      if (appUser == null) {
        throw Exception('Please complete your profile before adding skills.');
      }

      if (_editingSkill == null) {
        await _createSkill(firebaseUser.uid, appUser);
      } else {
        await _updateSkill();
      }

      if (!mounted) return;
      showAuthMessage(context, 'Skill saved successfully.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _createSkill(String uid, AppUser appUser) async {
    final existingSkills = await _skillRepository.getCurrentUserSkills(uid);
    final normalizedTitle = _normalize(_titleController.text);
    final hasDuplicate = existingSkills.any((skill) {
      return _normalize(skill.title) == normalizedTitle && skill.type == _type;
    });

    if (hasDuplicate) {
      throw Exception('You already added this skill.');
    }

    await _skillRepository.createSkill(
      firestore_skill.Skill(
        id: '',
        ownerId: uid,
        ownerName: appUser.fullName,
        ownerPhotoUrl: appUser.photoUrl,
        university: appUser.university,
        title: _titleController.text.trim(),
        category: _category,
        level: _level,
        description: _descriptionController.text.trim(),
        type: _type,
        exchangeFor: _exchangeForController.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> _updateSkill() async {
    await _skillRepository.updateSkill(_editingSkill!.id, {
      'title': _titleController.text.trim(),
      'category': _category,
      'level': _level,
      'description': _descriptionController.text.trim(),
      'type': _type,
      'exchangeFor': _exchangeForController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = _editingSkill != null;
    final exchangeLabel = _type == 'offered' ? 'Exchange for' : 'I can offer';
    final exchangeHint = _type == 'offered'
        ? 'What skill do you want in return?'
        : 'What can you teach in return?';

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Skill' : 'Add Skill')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isEditing ? 'Update skill' : 'Add a skill',
                        style: textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share what you can teach or what you want to learn.',
                        style: textTheme.bodyLarge?.copyWith(
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => validateRequired(value, 'Title'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: _types.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type == 'offered' ? 'Offered' : 'Wanted',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _type = value ?? _type),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _category = value ?? _category),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: _level,
                        decoration: const InputDecoration(labelText: 'Level'),
                        items: _levels.map((level) {
                          return DropdownMenuItem(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        onChanged: (value) =>
                            setState(() => _level = value ?? _level),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _exchangeForController,
                        decoration: InputDecoration(
                          labelText: exchangeLabel,
                          hintText: exchangeHint,
                        ),
                        validator: (value) =>
                            validateRequired(value, exchangeLabel),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) =>
                            validateRequired(value, 'Description'),
                      ),
                      const SizedBox(height: 22),
                      AppButton(
                        label: _isSaving ? 'Saving...' : 'Save Skill',
                        icon: Icons.check,
                        onPressed: _isSaving ? null : _saveSkill,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _safeValue(String? value, List<String> options, String fallback) {
  if (value != null && options.contains(value)) return value;
  if (options.contains(fallback)) return fallback;
  return options.first;
}

String _normalize(String value) {
  return value.trim().toLowerCase();
}
