import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_swap/src/core/theme/app_theme.dart';
import 'package:skill_swap/src/features/shell/bottom_navigation_shell.dart';

void main() {
  testWidgets('SkillSwap shell renders the first task foundation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const BottomNavigationShell()),
    );

    expect(find.text('SkillSwap'), findsOneWidget);
    expect(find.text('Best matches for you'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Swaps'), findsOneWidget);
  });
}
