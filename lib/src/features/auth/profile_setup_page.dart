import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({
    required this.uid,
    super.key,
    this.userRepository,
    this.authService,
  });

  final String uid;
  final UserRepository? userRepository;
  final AuthService? authService;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _universityController = TextEditingController();
  final _departmentController = TextEditingController();
  final _yearController = TextEditingController();
  final _campusController = TextEditingController();
  final _bioController = TextEditingController();

  AppUser? _existingUser;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isSigningOut = false;

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
      _existingUser = user;
      _fullNameController.text = user?.fullName ?? '';
      _universityController.text = user?.university ?? '';
      _departmentController.text = user?.department ?? '';
      _yearController.text = user?.year ?? '';
      _campusController.text = user?.campus ?? '';
      _bioController.text = user?.bio ?? '';
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (_uid.isEmpty) {
      showAuthMessage(
        context,
        'Please login again to finish your profile.',
        isError: true,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final firebaseUser = _authService.currentUser;
      final userToSave = AppUser(
        uid: _uid,
        fullName: _fullNameController.text.trim(),
        email: _existingUser?.email ?? firebaseUser?.email ?? '',
        university: _universityController.text.trim(),
        department: _departmentController.text.trim(),
        year: _yearController.text.trim(),
        bio: _bioController.text.trim(),
        campus: _campusController.text.trim(),
        photoUrl: _existingUser?.photoUrl ?? '',
        rating: _existingUser?.rating ?? 0,
        completedSwaps: _existingUser?.completedSwaps ?? 0,
        profileCompleted: true,
        createdAt: _existingUser?.createdAt ?? DateTime.now(),
      );

      await _userRepository.createUserProfile(userToSave);

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await _authService.signOut();

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
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
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: AppColors.softGold,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.person_add_alt,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Profile setup',
                              style: textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete the required fields so other students know who they are swapping with.',
                              style: textTheme.bodyLarge?.copyWith(
                                color: AppColors.textGray,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _ProfileTextField(
                              controller: _fullNameController,
                              label: 'Full name',
                            ),
                            _ProfileTextField(
                              controller: _universityController,
                              label: 'University',
                            ),
                            _ProfileTextField(
                              controller: _departmentController,
                              label: 'Department',
                            ),
                            _ProfileTextField(
                              controller: _yearController,
                              label: 'Year',
                            ),
                            _ProfileTextField(
                              controller: _campusController,
                              label: 'Campus',
                            ),
                            _ProfileTextField(
                              controller: _bioController,
                              label: 'Bio',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 14),
                            AppButton(
                              label: _isSaving ? 'Saving...' : 'Save Profile',
                              icon: Icons.check,
                              onPressed: _isSaving || _isSigningOut
                                  ? null
                                  : _saveProfile,
                            ),
                            const SizedBox(height: 12),
                            AppButton(
                              label: _isSigningOut
                                  ? 'Signing out...'
                                  : 'Logout',
                              icon: Icons.logout,
                              variant: AppButtonVariant.secondary,
                              onPressed: _isSaving || _isSigningOut
                                  ? null
                                  : _signOut,
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

class _ProfileTextField extends StatelessWidget {
  const _ProfileTextField({
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
