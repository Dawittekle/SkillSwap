import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/utils/app_validators.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    required this.uid,
    super.key,
    this.userRepository,
    this.authService,
  });

  final String uid;
  final UserRepository? userRepository;
  final AuthService? authService;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _campusController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;

  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();
  AuthService get _authService => widget.authService ?? AuthService();

  String get _uid {
    return widget.uid.isNotEmpty
        ? widget.uid
        : _authService.currentUser?.uid ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _universityController.dispose();
    _departmentController.dispose();
    _yearController.dispose();
    _campusController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (_uid.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final user = await _userRepository.getUser(_uid);
      if (user != null) _fillControllers(user);
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _fillControllers(AppUser user) {
    _fullNameController.text = user.fullName;
    _universityController.text = user.university;
    _departmentController.text = user.department;
    _yearController.text = user.year;
    _campusController.text = user.campus;
    _bioController.text = user.bio;
  }

  Future<void> _saveProfile() async {
    if (_uid.isEmpty) {
      showAuthMessage(
        context,
        'Please login again to edit your profile.',
        isError: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await _userRepository.updateUserProfile(_uid, {
        'fullName': _fullNameController.text.trim(),
        'university': _universityController.text.trim(),
        'department': _departmentController.text.trim(),
        'year': _yearController.text.trim(),
        'campus': _campusController.text.trim(),
        'bio': _bioController.text.trim(),
        'profileCompleted': true,
      });

      if (!mounted) return;
      showAuthMessage(context, 'Profile updated successfully.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: AppCard(
                child: _isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      )
                    : Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Edit Profile',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Update the details students see before requesting a swap.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textGray,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _EditTextField(
                              controller: _fullNameController,
                              label: 'Full name',
                            ),
                            _EditTextField(
                              controller: _universityController,
                              label: 'University',
                            ),
                            _EditTextField(
                              controller: _departmentController,
                              label: 'Department',
                            ),
                            _EditTextField(
                              controller: _yearController,
                              label: 'Year',
                            ),
                            _EditTextField(
                              controller: _campusController,
                              label: 'Campus',
                            ),
                            _EditTextField(
                              controller: _bioController,
                              label: 'Bio',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 14),
                            AppButton(
                              label: _isSaving ? 'Saving...' : 'Save Changes',
                              icon: Icons.check,
                              onPressed: _isSaving ? null : _saveProfile,
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

class _EditTextField extends StatelessWidget {
  const _EditTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (value) => validateRequired(value, label),
      ),
    );
  }
}
