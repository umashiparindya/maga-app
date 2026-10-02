import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/app.dart';
import 'package:mashi_smoke/data/destination_repository.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';

class _InjectedDestinationRepository implements DestinationRepository {
  _InjectedDestinationRepository(this.destinations);

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
    'details resolve the destination from the repository injected into MashiApp',
    (tester) async {
      final repository = _InjectedDestinationRepository(<Destination>[
        Destination(
          id: 'injected-only-destination',
          name: 'Injected Only Destination',
          province: 'Injected Province',
          description:
              'This description comes only from the injected repository.',
          activities: const {ActivityCategory.beach},
          budgetLevel: BudgetLevel.medium,
          suitableGroups: const {TravelGroup.friends},
          durationOptions: const {TripDuration.medium},
          bestSeason: 'Best season information from the injected record.',
          socialMediaAppealLevel: SocialMediaAppealLevel.high,
          socialMediaAppealScore: 0.667,
          sourceNote: 'Injected test repository source note.',
        ),
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

      expect(find.text('Results'), findsOneWidget);
      expect(find.text('Injected Only Destination'), findsOneWidget);
      expect(find.text('Hikkaduwa'), findsNothing);
      expect(repository.loadCount, 1);

      await tester.tap(find.text('Injected Only Destination'));
      await tester.pumpAndSettle();

      expect(find.text('Destination details'), findsOneWidget);
      expect(find.text('Injected Only Destination'), findsOneWidget);
      expect(
        find.text('This description comes only from the injected repository.'),
        findsOneWidget,
      );
      expect(find.text('Injected Province'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Injected test repository source note.'),
        500,
        scrollable: find.byType(Scrollable),
      );
      expect(
        find.text('Injected test repository source note.'),
        findsOneWidget,
      );
      expect(find.text('Destination not found'), findsNothing);
      expect(repository.loadCount, 2);
    },
  );
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
