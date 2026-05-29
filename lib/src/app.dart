import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/src/core/theme/app_theme.dart';
import 'package:skill_swap/src/features/auth/auth_gate.dart';
import 'package:skill_swap/src/features/auth/forgot_password_page.dart';
import 'package:skill_swap/src/features/auth/profile_setup_page.dart';
import 'package:skill_swap/src/features/auth/sign_up_page.dart';
import 'package:skill_swap/src/features/chat/chat_page.dart';
import 'package:skill_swap/src/features/profile/edit_profile_page.dart';
import 'package:skill_swap/src/features/profile/public_student_profile_page.dart';
import 'package:skill_swap/src/features/reviews/rate_session_page.dart';
import 'package:skill_swap/src/features/skills/manage_skills_page.dart';
import 'package:skill_swap/src/features/skills/skill_details_page.dart';
import 'package:skill_swap/src/features/skills/skill_form_page.dart';
import 'package:skill_swap/src/features/skills/skills_setup_page.dart';
import 'package:skill_swap/src/features/swaps/request_sent_page.dart';
import 'package:skill_swap/src/features/swaps/request_swap_page.dart';
import 'package:skill_swap/src/features/swaps/swap_request_detail_page.dart';
import 'package:skill_swap/src/features/tabs/discover_tab.dart';
import 'package:skill_swap/src/features/tabs/messages_tab.dart';

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
        AppRoutes.home: (_) => const AuthGate(),
        AppRoutes.signUp: (_) => const SignUpPage(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
        AppRoutes.skillsSetup: (_) => const SkillsSetupPage(),
        AppRoutes.manageSkills: (_) => const ManageSkillsPage(),
        AppRoutes.requestSent: (_) => const RequestSentPage(),
      },
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
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
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: DiscoverTab()),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.messages) {
      return MaterialPageRoute(
        builder: (_) => const Scaffold(body: MessagesTab()),
        settings: settings,
      );
    }

    if (settings.name == AppRoutes.swapDetails) {
      final request = settings.arguments is SwapRequest
          ? settings.arguments! as SwapRequest
          : null;

      return MaterialPageRoute(
        builder: (_) => SwapRequestDetailPage(request: request),
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

class RequestSwapArguments {
  const RequestSwapArguments({
    required this.selectedSkill,
    required this.teacherId,
    required this.teacherName,
  });

  final firestore_skill.Skill selectedSkill;
  final String teacherId;
  final String teacherName;
}

class ChatArguments {
  const ChatArguments({
    this.conversationId = '',
    this.otherUserId = '',
    this.otherUserName = '',
    this.relatedRequestId = '',
  });

  final String conversationId;
  final String otherUserId;
  final String otherUserName;
  final String relatedRequestId;
}

class ReviewSessionArguments {
  const ReviewSessionArguments({required this.request});

  final SwapRequest request;
}

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const signUp = '/auth/sign-up';
  static const forgotPassword = '/auth/forgot-password';
  static const profileSetup = '/profile/setup';
  static const editProfile = '/profile/edit';
  static const publicProfile = '/profile/public';
  static const skillsSetup = '/skills/setup';
  static const manageSkills = '/skills/manage';
  static const addSkill = '/skills/add';
  static const editSkill = '/skills/edit';
  static const requestSwap = '/swaps/request';
  static const requestSent = '/swaps/request-sent';
  static const swapDetails = '/swaps/details';
  static const skillDetails = '/skills/details';
  static const discover = '/discover';
  static const messages = '/messages';
  static const chat = '/chat';
  static const reviewSession = '/sessions/review';
}
