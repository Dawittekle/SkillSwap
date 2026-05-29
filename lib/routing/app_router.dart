import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/features/auth/pages/forgot_password_page.dart';
import 'package:skill_swap/features/auth/pages/signup_page.dart';
import 'package:skill_swap/features/discover/pages/discover_page.dart';
import 'package:skill_swap/features/discover/pages/public_student_profile_page.dart';
import 'package:skill_swap/features/discover/pages/skill_details_page.dart';
import 'package:skill_swap/features/messages/pages/chat_page.dart';
import 'package:skill_swap/features/messages/pages/messages_page.dart';
import 'package:skill_swap/features/profile/pages/edit_profile_page.dart';
import 'package:skill_swap/features/profile/pages/manage_skills_page.dart';
import 'package:skill_swap/features/profile/pages/skill_form_page.dart';
import 'package:skill_swap/features/profile_setup/pages/profile_setup_page.dart';
import 'package:skill_swap/features/profile_setup/pages/skills_setup_page.dart';
import 'package:skill_swap/features/reviews/pages/rate_session_page.dart';
import 'package:skill_swap/features/swaps/pages/request_sent_page.dart';
import 'package:skill_swap/features/swaps/pages/request_swap_page.dart';
import 'package:skill_swap/features/swaps/pages/session_detail_page.dart';
import 'package:skill_swap/routing/app_routes.dart';

// This file creates pages for named routes without changing navigation behavior.
class AppRouter {
  const AppRouter._();

  static Map<String, WidgetBuilder> routes = {
    AppRoutes.signUp: (_) => const SignupPage(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
    AppRoutes.skillsSetup: (_) => const SkillsSetupPage(),
    AppRoutes.manageSkills: (_) => const ManageSkillsPage(),
    AppRoutes.requestSent: (_) => const RequestSentPage(),
  };

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    if (settings.name == AppRoutes.profileSetup) {
      final uid = settings.arguments is String
          ? settings.arguments! as String
          : '';

      return MaterialPageRoute(
        builder: (_) => ProfileSetupPage(uid: uid),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.editProfile) {
      final uid = settings.arguments is String
          ? settings.arguments! as String
          : '';

      return MaterialPageRoute(
        builder: (_) => EditProfilePage(uid: uid),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.publicProfile) {
      final uid = settings.arguments is String
          ? settings.arguments! as String
          : '';

      return MaterialPageRoute(
        builder: (_) => PublicStudentProfilePage(uid: uid),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.addSkill ||
        settings.name == AppRoutes.editSkill) {
      final arguments = settings.arguments is SkillFormArguments
          ? settings.arguments! as SkillFormArguments
          : const SkillFormArguments();

      return MaterialPageRoute(
        builder: (_) => SkillFormPage(arguments: arguments),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.skillDetails) {
      final selectedSkill = settings.arguments is firestore_skill.Skill
          ? settings.arguments! as firestore_skill.Skill
          : null;
      final skillId =
          selectedSkill?.id ??
          (settings.arguments is String ? settings.arguments! as String : '');

      return MaterialPageRoute(
        builder: (_) =>
            SkillDetailsPage(skillId: skillId, skill: selectedSkill),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.requestSwap) {
      final arguments = settings.arguments is RequestSwapArguments
          ? settings.arguments! as RequestSwapArguments
          : null;

      return MaterialPageRoute(
        builder: (_) => RequestSwapPage(arguments: arguments),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.requestSent) {
      final requestId = settings.arguments is String
          ? settings.arguments! as String
          : '';

      return MaterialPageRoute(
        builder: (_) => RequestSentPage(requestId: requestId),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.chat) {
      final arguments = settings.arguments is ChatArguments
          ? settings.arguments! as ChatArguments
          : null;

      return MaterialPageRoute(
        builder: (_) => ChatPage(arguments: arguments),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.discover) {
      final initialQuery = settings.arguments is String
          ? settings.arguments! as String
          : '';

      return MaterialPageRoute(
        builder: (_) =>
            Scaffold(body: DiscoverPage(initialQuery: initialQuery)),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.messages) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: MessagesPage()),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.swapDetails) {
      final request = settings.arguments is SwapRequest
          ? settings.arguments! as SwapRequest
          : null;

      return MaterialPageRoute(
        builder: (_) => SessionDetailPage(request: request),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.reviewSession) {
      final arguments = settings.arguments is ReviewSessionArguments
          ? settings.arguments! as ReviewSessionArguments
          : null;

      return MaterialPageRoute(
        builder: (_) => RateSessionPage(arguments: arguments),
        settings: settings,
      );
    }

    return null;
  }
}
