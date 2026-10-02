import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/core/app_identity.dart';
import 'package:mashi_smoke/core/app_theme.dart';
import 'package:mashi_smoke/presentation/screens/about_screen.dart';

void main() {
  testWidgets('About explains purpose, method, and limitations honestly', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: MashiTheme.light, home: const AboutScreen()),
    );

    expect(find.text('About ${AppIdentity.productName}'), findsOneWidget);
    expect(find.textContaining('Mashi'), findsNothing);

    final initialText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? '')
        .join('\n');

    expect(initialText, contains('research prototype'));
    expect(initialText, contains('deterministic, rule-based matching'));
    expect(initialText, contains('Methodology summary'));

    await tester.scrollUntilVisible(
      find.text('Limitations'),
      500,
      scrollable: find.byType(Scrollable),
    );
    final limitationsText = tester
        .widgetList<Text>(find.byType(Text))
        .map((widget) => widget.data ?? '')
        .join('\n');

    expect(
      limitationsText,
      contains('research-informed ordinal prototype proxy'),
    );
    expect(limitationsText, contains('not a survey measurement'));
    expect(
      limitationsText,
      contains('does not provide live social-media analytics'),
    );
    expect(
      limitationsText,
      contains('Recommendation accuracy has not been validated'),
    );
    expect(
      limitationsText,
      contains('does not use artificial intelligence or machine learning'),
    );

    final renderedText = '$initialText\n$limitationsText';
    expect(renderedText, isNot(contains('AI-powered')));
    expect(renderedText, isNot(contains('popular destination')));
    expect(renderedText, isNot(contains('live analytics show')));
    expect(renderedText, isNot(contains('proven accuracy')));
  });
}
