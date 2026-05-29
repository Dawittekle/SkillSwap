import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/models/swap_request.dart';

// This file keeps all route names and route argument objects in one place.
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
