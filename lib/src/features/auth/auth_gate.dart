import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/features/auth/login_page.dart';
import 'package:skill_swap/src/features/auth/profile_setup_page.dart';
import 'package:skill_swap/src/features/shell/bottom_navigation_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, this.authService, this.userRepository});

  final AuthService? authService;
  final UserRepository? userRepository;

  @override
  Widget build(BuildContext context) {
    final authService = this.authService ?? AuthService();
    final userRepository = this.userRepository ?? UserRepository();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginPage();
        }

        return StreamBuilder<AppUser?>(
          stream: userRepository.watchUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const _AuthLoadingScreen();
            }

            final appUser = userSnapshot.data;
            if (appUser == null || !appUser.profileCompleted) {
              return ProfileSetupPage(uid: firebaseUser.uid);
            }

            return const BottomNavigationShell();
          },
        );
      },
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}
