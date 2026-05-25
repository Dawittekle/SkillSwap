import 'package:flutter_test/flutter_test.dart';
import 'package:skill_swap/src/app.dart';

void main() {
  testWidgets('SkillSwap shell renders the first task foundation', (
    tester,
  ) async {
    await tester.pumpWidget(const SkillSwapApp());

    expect(find.text('SkillSwap'), findsOneWidget);
    expect(find.text('Best matches for you'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Swaps'), findsOneWidget);
  });
}
