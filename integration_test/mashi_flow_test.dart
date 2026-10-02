import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mashi_smoke/app.dart';
import 'package:mashi_smoke/data/local_destination_repository.dart';
import 'package:mashi_smoke/models/enums.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('completes the deterministic Maga journey', (tester) async {
    await tester.pumpWidget(MashiApp(repository: LocalDestinationRepository()));
    await tester.pumpAndSettle();

    expect(find.text('Start preferences'), findsOneWidget);
    await tester.tap(find.text('Start preferences'));
    await tester.pumpAndSettle();

    await _selectDropdown<BudgetLevel>(
      tester,
      find.byType(DropdownButtonFormField<BudgetLevel>),
      'Medium',
    );
    await tester.tap(find.widgetWithText(CheckboxListTile, 'Beach'));
    await tester.pumpAndSettle();
    await _selectDropdown<TravelGroup>(
      tester,
      find.byType(DropdownButtonFormField<TravelGroup>),
      'Friends',
    );
    await _selectDropdown<TripDuration>(
      tester,
      find.byType(DropdownButtonFormField<TripDuration>),
      'Medium',
    );
    await _selectDropdown<SocialMediaUsageIntensity>(
      tester,
      find.byType(DropdownButtonFormField<SocialMediaUsageIntensity>),
      '1 to 2 hours',
    );

    await _scrollTo(tester, find.text('Get recommendations'));
    await tester.tap(find.text('Get recommendations'));
    await tester.pumpAndSettle();

    expect(find.text('Results'), findsOneWidget);
    expect(find.text('12 recommendations'), findsOneWidget);
    expect(find.text('Arugam Bay'), findsOneWidget);
    expect(find.text('Hikkaduwa'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Arugam Bay')).dy,
      lessThan(tester.getTopLeft(find.text('Hikkaduwa')).dy),
    );
    expect(find.text('Prototype score: 0.935 / 1.000'), findsOneWidget);
    expect(
      find.textContaining('Social-media appeal proxy: 1.000'),
      findsOneWidget,
    );

    await tester.tap(find.text('Arugam Bay'));
    await tester.pumpAndSettle();
    expect(find.text('Destination details'), findsOneWidget);
    expect(find.text('Arugam Bay'), findsOneWidget);
    expect(find.text('Eastern Province'), findsOneWidget);
    expect(
      find.text(
        'A beach and adventure destination with surfing at Main Point, Pottuvil Point, and Whiskey Point, plus yoga retreats, beach, seafood restaurants, and Lahugala wildlife.',
      ),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Arugam Bay'), findsOneWidget);

    await _scrollTo(tester, find.text('Edit preferences'));
    await tester.tap(find.text('Edit preferences'));
    await tester.pumpAndSettle();
    expect(find.text('Preferences'), findsOneWidget);
    expect(find.text('Arugam Bay'), findsNothing);
    await _scrollToTop(tester);
    expect(find.byType(DropdownButtonFormField<BudgetLevel>), findsOneWidget);
    expect(find.text('Medium'), findsAtLeastNWidgets(1));
    await _dragUp(tester);
    expect(find.text('Friends'), findsOneWidget);
    await _dragUp(tester);
    expect(find.text('1 to 2 hours'), findsOneWidget);

    await _scrollTo(tester, find.text('Get recommendations'));
    await tester.tap(find.text('Get recommendations'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsOneWidget);
    expect(find.text('Arugam Bay'), findsOneWidget);

    await _scrollTo(tester, find.text('Start over'));
    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();
    expect(find.text('Start preferences'), findsOneWidget);
    expect(find.text('Results'), findsNothing);
    expect(find.text('Arugam Bay'), findsNothing);

    await tester.tap(find.text('Start preferences'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, find.text('Get recommendations'));
    await tester.tap(find.text('Get recommendations'));
    await tester.pumpAndSettle();
    expect(find.text('Results'), findsNothing);
    expect(
      find.text(
        'Choose a budget, at least one activity, a travel group, a trip duration, and your daily social media use.',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _selectDropdown<T>(
  WidgetTester tester,
  Finder field,
  String option,
) async {
  await _scrollTo(tester, field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    500,
    scrollable: find.byType(Scrollable),
  );
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> _scrollToTop(WidgetTester tester) async {
  final scrollable = find.byType(Scrollable);
  for (var index = 0; index < 6; index++) {
    await tester.drag(scrollable, const Offset(0, 700));
    await tester.pumpAndSettle();
  }
}

Future<void> _dragUp(WidgetTester tester) async {
  await tester.drag(find.byType(Scrollable), const Offset(0, -550));
  await tester.pumpAndSettle();
}
