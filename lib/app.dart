import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skill_swap/core/utils/app_error_handler.dart';
import 'package:skill_swap/core/theme/app_theme.dart';
import 'package:skill_swap/core/widgets/app_loading_screen.dart';
import 'package:skill_swap/firebase_options.dart';
import 'package:skill_swap/features/auth/widgets/auth_gate.dart';
import 'package:skill_swap/routing/app_router.dart';

// This is the root widget for the app. It also shows startup loading/error states.
class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _FirebaseStartupGate(),
      onGenerateRoute: AppRouter.generateRoute,
      routes: AppRouter.routes,
    );
  }
}

class _FirebaseStartupGate extends StatefulWidget {
  const _FirebaseStartupGate();

  @override
  State<_FirebaseStartupGate> createState() => _FirebaseStartupGateState();
}

class _FirebaseStartupGateState extends State<_FirebaseStartupGate> {
  late Future<void> _firebaseStartup;

  @override
  void initState() {
    super.initState();
    _firebaseStartup = _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) return;

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  void _retryStartup() {
    setState(() {
      _firebaseStartup = _initializeFirebase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _firebaseStartup,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppLoadingScreen();
        }

        if (snapshot.hasError) {
          final error = snapshot.error;
          if (isNetworkFirebaseError(error)) {
            return NoInternetView(onRetry: _retryStartup);
          }

          return AppErrorView(
            message: friendlyFirebaseErrorMessage(error),
            onRetry: _retryStartup,
          );
        }

        return const AuthGate();
      },
    );
  }
}
