import 'package:flutter/material.dart';
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
  bool _isSaving = false;
  bool _isSigningOut = false;

  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();
  AuthService get _authService => widget.authService ?? AuthService();

  Future<void> _continueToDemo() async {
    setState(() => _isSaving = true);
    try {
      await _userRepository.updateUserProfile(widget.uid, {
        'profileCompleted': true,
      });

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
                    Text('Profile setup', style: textTheme.headlineMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Your account is ready. Profile details will be connected in the next step.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: _isSaving ? 'Saving...' : 'Continue to Demo',
                      icon: Icons.arrow_forward,
                      onPressed: _isSaving || _isSigningOut
                          ? null
                          : _continueToDemo,
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: _isSigningOut ? 'Signing out...' : 'Logout',
                      icon: Icons.logout,
                      variant: AppButtonVariant.secondary,
                      onPressed: _isSaving || _isSigningOut ? null : _signOut,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
