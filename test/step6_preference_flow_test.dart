import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/app.dart';
import 'package:mashi_smoke/data/destination_repository.dart';
import 'package:mashi_smoke/data/destination_seed.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';

class _DeterministicDestinationRepository implements DestinationRepository {
  _DeterministicDestinationRepository(this.destinations);

  final List<Destination> destinations;
  int loadCount = 0;

  @override
  Future<List<Destination>> getDestinations() async {
    loadCount += 1;
    return destinations;
  }
}

void main() {
  testWidgets(
    'preference flow uses the real engine and shows an explainable result',
    (tester) async {
      final repository = _DeterministicDestinationRepository(<Destination>[
        destinationSeed.first,
      ]);
      await tester.pumpWidget(MashiApp(repository: repository));

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

      await tester.scrollUntilVisible(
        find.text('Get recommendations'),
        500,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Get recommendations'));
      await tester.pumpAndSettle();

      expect(repository.loadCount, 1);
      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Hikkaduwa'), findsOneWidget);
      expect(find.text('Prototype score: 0.883 / 1.000'), findsOneWidget);
      expect(find.textContaining('Matches your'), findsOneWidget);
      expect(find.textContaining('social-media-appeal proxy'), findsOneWidget);
    },
  );

  testWidgets('Start over clears the previous result and preferences', (
    tester,
  ) async {
    final repository = _DeterministicDestinationRepository(<Destination>[
      destinationSeed.first,
    ]);
    await tester.pumpWidget(MashiApp(repository: repository));

    await _completePreferences(tester);
    expect(find.text('Hikkaduwa'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Start over'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();

    expect(find.text('Start preferences'), findsOneWidget);
    expect(find.text('Hikkaduwa'), findsNothing);

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
    expect(repository.loadCount, 1);
  });
}

Future<void> _completePreferences(WidgetTester tester) async {
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
  await tester.scrollUntilVisible(
    find.text('Get recommendations'),
    500,
    scrollable: find.byType(Scrollable),
  );
  await tester.tap(find.text('Get recommendations'));
  await tester.pumpAndSettle();
}

Future<void> _selectDropdown<T>(
  WidgetTester tester,
  Finder field,
  String option,
) async {
  await tester.scrollUntilVisible(
    field,
    300,
    scrollable: find.byType(Scrollable),
  );
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}
