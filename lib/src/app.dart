import 'package:flutter/material.dart';
import 'package:skill_swap/src/core/theme/app_theme.dart';
import 'package:skill_swap/src/features/placeholders/simple_placeholder_screen.dart';
import 'package:skill_swap/src/features/shell/bottom_navigation_shell.dart';
import 'package:skill_swap/src/features/skills/skill_details_page.dart';

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: _generateRoute,
      routes: {
        AppRoutes.home: (_) => const BottomNavigationShell(),
        AppRoutes.profileSetup: (_) => const SimplePlaceholderScreen(
          title: 'Create Profile',
          subtitle: 'Profile setup will be built in the next page task.',
        ),
        AppRoutes.addSkill: (_) => const SimplePlaceholderScreen(
          title: 'Add Skill',
          subtitle: 'Teaching and learning skill forms will come next.',
        ),
        AppRoutes.requestSwap: (_) => const SimplePlaceholderScreen(
          title: 'Request Swap',
          subtitle: 'Swap request flow is intentionally not connected yet.',
        ),
        AppRoutes.chat: (_) => const SimplePlaceholderScreen(
          title: 'Chat',
          subtitle: 'Messaging screens will use mock conversations first.',
        ),
        AppRoutes.reviewSession: (_) => const SimplePlaceholderScreen(
          title: 'Review Session',
          subtitle: 'Session rating will be added after swaps are in place.',
        ),
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.skillDetails) {
      final skillId = settings.arguments is String
          ? settings.arguments! as String
          : '';

      return MaterialPageRoute(
        builder: (_) => SkillDetailsPage(skillId: skillId),
        settings: settings,
      );
    }

    return null;
  }
}

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const profileSetup = '/profile/setup';
  static const addSkill = '/skills/add';
  static const requestSwap = '/swaps/request';
  static const skillDetails = '/skills/details';
  static const chat = '/chat';
  static const reviewSession = '/sessions/review';
}
