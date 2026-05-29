import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skill_swap/src/core/theme/app_theme.dart';
import 'package:skill_swap/src/features/tabs/home_tab.dart';

void main() {
  testWidgets('SkillSwap home renders the first task foundation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: HomeTab(previewData: true)),
      ),
    );

    expect(find.text('SkillSwap'), findsOneWidget);
    expect(find.text('Best matches for you'), findsOneWidget);
    expect(find.text('Request Swap'), findsOneWidget);
  });
}
