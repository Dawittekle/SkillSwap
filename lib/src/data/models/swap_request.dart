enum SwapStatus { pending, accepted, completed, declined }

class SwapRequest {
  const SwapRequest({
    required this.id,
    required this.studentId,
    required this.theyTeach,
    required this.youTeach,
    required this.status,
    required this.sessionTime,
  });

  final String id;
  final String studentId;
  final String theyTeach;
  final String youTeach;
  final SwapStatus status;
  final String sessionTime;
}
