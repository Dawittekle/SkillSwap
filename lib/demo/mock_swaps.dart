import 'package:skill_swap/demo/mock_swap_request.dart';

const mockSwaps = [
  SwapRequest(
    id: 'swap-001',
    studentId: 'hana',
    theyTeach: 'UI Design',
    youTeach: 'Python',
    status: SwapStatus.pending,
    sessionTime: 'Tomorrow, 4:00 PM',
  ),
  SwapRequest(
    id: 'swap-002',
    studentId: 'selam',
    theyTeach: 'Python APIs',
    youTeach: 'Presentation Design',
    status: SwapStatus.accepted,
    sessionTime: 'Friday, 2:30 PM',
  ),
];
