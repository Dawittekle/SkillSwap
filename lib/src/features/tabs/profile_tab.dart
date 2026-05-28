import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key, this.authService, this.userRepository});

  final AuthService? authService;
  final UserRepository? userRepository;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _isSigningOut = false;

  AuthService get _authService => widget.authService ?? AuthService();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();

  Future<void> _logout() async {
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
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      return const SafeArea(
        child: Center(child: Text('Please login to view your profile.')),
      );
    }

    return StreamBuilder<AppUser?>(
      stream: _userRepository.watchUser(currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SafeArea(
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        final user = snapshot.data;
        if (user == null) {
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
              children: [
                Text(
                  'My Profile',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 18),
                AppCard(
                  child: Text(
                    'Profile not found. Please complete your profile setup.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          );
        }

        return _ProfileContent(
          user: user,
          isSigningOut: _isSigningOut,
          onEdit: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.editProfile, arguments: user.uid),
          onLogout: _isSigningOut ? null : _logout,
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.user,
    required this.isSigningOut,
    required this.onEdit,
    required this.onLogout,
  });

  final AppUser user;
  final bool isSigningOut;
  final VoidCallback onEdit;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitleParts = [
      if (user.department.isNotEmpty) user.department,
      if (user.year.isNotEmpty) user.year,
      if (user.university.isNotEmpty) user.university,
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
        children: [
          Text('My Profile', style: textTheme.headlineLarge),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                _ProfileAvatar(photoUrl: user.photoUrl),
                const SizedBox(height: 12),
                Text(user.fullName, style: textTheme.titleLarge),
                Text(
                  subtitleParts.join(' - '),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
                if (user.campus.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    user.campus,
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ],
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    user.bio,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: '${user.rating.toStringAsFixed(1)} Rating',
                      color: AppColors.warning,
                      icon: Icons.star,
                    ),
                    StatusChip(
                      label: '${user.completedSwaps} Swaps',
                      color: AppColors.primaryGreen,
                      icon: Icons.swap_horiz,
                    ),
                    const StatusChip(
                      label: 'Available',
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('I can teach', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SkillChip(label: 'Python', icon: Icons.code),
              SkillChip(label: 'Git Basics', icon: Icons.merge_type),
              SkillChip(label: 'Study Planning', icon: Icons.calendar_month),
            ],
          ),
          const SizedBox(height: 22),
          Text('I want to learn', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SkillChip(label: 'UI Design'),
              SkillChip(label: 'Public Speaking'),
              SkillChip(label: 'Guitar'),
            ],
          ),
          const SizedBox(height: 26),
          AppButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: onEdit,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: isSigningOut ? 'Signing out...' : 'Logout',
            icon: Icons.logout,
            variant: AppButtonVariant.secondary,
            onPressed: onLogout,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) {
      return const CircleAvatar(
        radius: 38,
        backgroundColor: AppColors.tealTint,
        child: Icon(Icons.person, color: AppColors.primaryDark, size: 34),
      );
    }

    return CircleAvatar(
      radius: 38,
      backgroundColor: AppColors.tealTint,
      backgroundImage: NetworkImage(photoUrl),
    );
  }
}
