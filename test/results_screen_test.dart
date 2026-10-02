import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/application/recommendation_controller.dart';
import 'package:mashi_smoke/core/app_routes.dart';
import 'package:mashi_smoke/core/app_theme.dart';
import 'package:mashi_smoke/data/local_destination_repository.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';
import 'package:mashi_smoke/models/recommendation.dart';
import 'package:mashi_smoke/presentation/screens/destination_details_screen.dart';
import 'package:mashi_smoke/presentation/screens/results_screen.dart';

void main() {
  testWidgets('results preserve engine order and show honest score details', (
    tester,
  ) async {
    final controller = _submittedController([
      _recommendation(
        id: 'first',
        name: 'First destination',
        finalScore: 0.240,
        explanation: 'Matches your activities and travel group.',
      ),
      _recommendation(
        id: 'second',
        name: 'Second destination',
        finalScore: 0.940,
        explanation: 'Matches your budget and trip duration.',
      ),
    ]);
    addTearDown(controller.dispose);
    await _pumpResults(tester, controller);

    expect(find.text('2 recommendations'), findsOneWidget);
    expect(find.text('Prototype score: 0.240 / 1.000'), findsOneWidget);
    expect(find.text('Prototype score: 0.940 / 1.000'), findsOneWidget);
    expect(find.text('Social-media appeal proxy: 0.667'), findsNWidgets(2));
    expect(
      find.text('Matches your activities and travel group.'),
      findsOneWidget,
    );
    expect(find.text('Matches your budget and trip duration.'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Second destination'),
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(
      tester.getCenter(find.text('First destination')).dy,
      lessThan(tester.getCenter(find.text('Second destination')).dy),
    );
  });

  testWidgets('tapping a result passes its destination identity to details', (
    tester,
  ) async {
    final controller = _submittedController([
      _recommendation(
        id: 'selected-destination',
        name: 'Selected destination',
        finalScore: 0.800,
        explanation: 'Matches your selected preferences.',
      ),
    ]);
    addTearDown(controller.dispose);
    await _pumpResults(tester, controller);

    await tester.tap(find.text('Selected destination'));
    await tester.pumpAndSettle();

    final details = tester.widget<DestinationDetailsScreen>(
      find.byType(DestinationDetailsScreen),
    );
    expect(details.destinationId, 'selected-destination');
  });

  testWidgets('empty results show edit and start-over actions', (tester) async {
    final controller = RecommendationController();
    controller.hasSubmitted = true;
    addTearDown(controller.dispose);
    await _pumpResults(tester, controller);

    expect(find.text('No recommendations'), findsOneWidget);
    expect(
      find.text(
        'No approved destinations are available to show for this search.',
      ),
      findsOneWidget,
    );
    expect(find.text('Edit preferences'), findsOneWidget);
    expect(find.text('Start over'), findsOneWidget);
  });

  testWidgets('edit preferences clears results without clearing selections', (
    tester,
  ) async {
    final controller = _submittedController([
      _recommendation(
        id: 'edit-destination',
        name: 'Edit destination',
        finalScore: 0.700,
        explanation: 'Matches your selected preferences.',
      ),
    ]);
    controller.budgetLevel = BudgetLevel.medium;
    controller.activities.add(ActivityCategory.beach);
    addTearDown(controller.dispose);
    await _pumpResults(tester, controller);

    await tester.tap(find.text('Edit preferences'));
    await tester.pumpAndSettle();

    expect(find.text('Open preferences'), findsOneWidget);
    expect(find.text('Edit destination'), findsNothing);
    expect(controller.recommendations, isEmpty);
    expect(controller.hasSubmitted, isFalse);
    expect(controller.budgetLevel, BudgetLevel.medium);
    expect(controller.activities, contains(ActivityCategory.beach));
  });

  testWidgets('start over clears preferences and results', (tester) async {
    final controller = _submittedController([
      _recommendation(
        id: 'reset-destination',
        name: 'Reset destination',
        finalScore: 0.700,
        explanation: 'Matches your selected preferences.',
      ),
    ]);
    controller.budgetLevel = BudgetLevel.high;
    controller.activities.add(ActivityCategory.adventure);
    addTearDown(controller.dispose);
    await _pumpResults(tester, controller);

    await tester.tap(find.text('Start over'));
    await tester.pumpAndSettle();

    expect(find.text('Open welcome'), findsOneWidget);
    expect(find.text('Reset destination'), findsNothing);
    expect(controller.recommendations, isEmpty);
    expect(controller.hasSubmitted, isFalse);
    expect(controller.budgetLevel, isNull);
    expect(controller.activities, isEmpty);
  });

  testWidgets('long result names and explanations do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    const longName =
        'A destination name that is intentionally long to verify wrapping on a Pixel 7 viewport';
    final controller = _submittedController([
      _recommendation(
        id: 'long-destination',
        name: longName,
        description: 'A long factual destination description that should wrap across multiple lines without overflowing the results viewport.',
        finalScore: 0.650,
        explanation: 'This is a deliberately long explanation describing matching activities, travel group suitability, trip duration, and the research-informed social-media-appeal proxy without relying on hidden metrics.',
      ),
    ]);
    addTearDown(controller.dispose);
    await _pumpResults(tester, controller);

    expect(tester.takeException(), isNull);
    expect(find.text(longName), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Start over'),
      400,
      scrollable: find.byType(Scrollable),
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpResults(
  WidgetTester tester,
  RecommendationController controller,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: MashiTheme.light,
      routes: {
        AppRoutes.destinationDetails: (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          return DestinationDetailsScreen(
            destinationId: arguments is String ? arguments : null,
            repository: LocalDestinationRepository(),
          );
        },
      },
      home: _ResultsLauncher(controller: controller),
    ),
  );
  await tester.tap(find.text('Open results'));
  await tester.pumpAndSettle();
}

Recommendation _recommendation({
  required String id,
  required String name,
  String description = 'A factual test destination description.',
  required double finalScore,
  required String explanation,
}) {
  final destination = Destination(
    id: id,
    name: name,
    province: 'Test Province',
    description: description,
    activities: {ActivityCategory.beach},
    budgetLevel: BudgetLevel.medium,
    suitableGroups: {TravelGroup.friends},
    durationOptions: {TripDuration.medium},
    bestSeason: 'Supported test season',
    socialMediaAppealLevel: SocialMediaAppealLevel.high,
    socialMediaAppealScore: 0.667,
    sourceNote: 'Controlled widget-test record.',
  );
  return Recommendation(
    destination: destination,
    fitScore: 0.800,
    socialMediaAppealScore: 0.667,
    lambda: 0.350,
    finalScore: finalScore,
    matchedFactors: const ['activities'],
    explanation: explanation,
  );
}

RecommendationController _submittedController(
  List<Recommendation> recommendations,
) {
  final controller = RecommendationController();
  controller.recommendations = recommendations;
  controller.hasSubmitted = true;
  return controller;
}

class _ResultsLauncher extends StatelessWidget {
  const _ResultsLauncher({required this.controller});

  final RecommendationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Open welcome'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ResultsScreen(controller: controller),
                ),
              ),
              child: const Text('Open results'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Text('Open preferences'),
                ),
              ),
              child: const Text('Open preferences'),
            ),
          ],
        ),
      ),
    );
  }
}
