import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/data/firebase_error_messages.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/core/widgets/app_state_views.dart';
import 'package:skill_swap/src/features/auth/login_page.dart';
import 'package:skill_swap/src/features/auth/profile_setup_page.dart';
import 'package:skill_swap/src/features/shell/bottom_navigation_shell.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, this.authService, this.userRepository});

  final AuthService? authService;
  final UserRepository? userRepository;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  int _retryCount = 0;

  AuthService get _authService => widget.authService ?? AuthService();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();

  void _retry() {
    setState(() {
      _retryCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      key: ValueKey('auth-$_retryCount'),
      stream: _authService.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const AppLoadingScreen();
        }

        if (authSnapshot.hasError) {
          return _startupErrorView(authSnapshot.error);
        }

        final firebaseUser = authSnapshot.data;
        if (firebaseUser == null) {
          return const LoginPage();
        }

        return StreamBuilder<AppUser?>(
          key: ValueKey('profile-${firebaseUser.uid}-$_retryCount'),
          stream: _userRepository.watchUser(firebaseUser.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const AppLoadingScreen();
            }

            if (userSnapshot.hasError) {
              return _startupErrorView(userSnapshot.error);
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

  Widget _startupErrorView(Object? error) {
    if (isNetworkFirebaseError(error)) {
      return NoInternetView(onRetry: _retry);
    }

    return AppErrorView(
      message: friendlyFirebaseErrorMessage(error),
      onRetry: _retry,
    );
  }
}
