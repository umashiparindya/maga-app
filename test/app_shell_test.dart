import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mashi_smoke/app.dart';

void main() {
  testWidgets('starts on Welcome and opens About', (tester) async {
    await tester.pumpWidget(const MashiApp());

    expect(find.text('Maga'), findsOneWidget);
    expect(find.textContaining('Mashi'), findsNothing);
    expect(find.bySemanticsLabel('Maga brand mark'), findsOneWidget);
    expect(find.text('Start preferences'), findsOneWidget);

    await tester.tap(find.text('About'));
    await tester.pumpAndSettle();

    expect(find.text('About Maga'), findsOneWidget);
    expect(find.textContaining('Mashi'), findsNothing);
    expect(
      find.textContaining('research prototype for exploring domestic'),
      findsOneWidget,
    );
  });

  testWidgets('incomplete preferences cannot submit', (tester) async {
    await tester.pumpWidget(const MashiApp());

    await tester.tap(find.text('Start preferences'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Get recommendations'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Get recommendations'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Choose a budget, at least one activity, a travel group, a trip duration, and your daily social media use.',
      ),
      findsOneWidget,
    );
    expect(find.text('Results'), findsNothing);
  });
}
