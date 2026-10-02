import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/application/recommendation_controller.dart';
import 'package:mashi_smoke/core/app_routes.dart';
import 'package:mashi_smoke/core/app_theme.dart';
import 'package:mashi_smoke/data/destination_repository.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';
import 'package:mashi_smoke/models/recommendation.dart';
import 'package:mashi_smoke/presentation/screens/destination_details_screen.dart';
import 'package:mashi_smoke/presentation/screens/results_screen.dart';

void main() {
  testWidgets(
    'result tap opens the matching record and back preserves results',
    (tester) async {
      final destination = _destination();
      final repository = _TestDestinationRepository([destination]);
      final controller = _submittedController(destination);
      addTearDown(controller.dispose);
      await _pumpResults(
        tester,
        controller: controller,
        repository: repository,
      );

      await tester.tap(find.text(destination.name));
      await tester.pumpAndSettle();

      expect(find.text(destination.name), findsOneWidget);
      expect(find.text(destination.description), findsOneWidget);
      expect(find.text(destination.province), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Results'), findsOneWidget);
      expect(find.text(destination.name), findsOneWidget);
      expect(find.text('Prototype score: 0.812 / 1.000'), findsOneWidget);
    },
  );

  testWidgets('details display fields from the selected repository record', (
    tester,
  ) async {
    final destination = _destination();
    final repository = _TestDestinationRepository([destination]);
    await tester.pumpWidget(
      MaterialApp(
        theme: MashiTheme.light,
        home: DestinationDetailsScreen(
          destinationId: destination.id,
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(destination.name), findsOneWidget);
    expect(find.text(destination.province), findsOneWidget);
    expect(find.text(destination.description), findsOneWidget);
    expect(find.text('Beach, Water sports'), findsOneWidget);
    expect(find.text('Friends, Solo'), findsOneWidget);
    expect(find.text('Medium'), findsNWidgets(2));
    expect(find.text('December to March'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Source note'),
      500,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.textContaining('Collective Appendix A provenance'),
      findsOneWidget,
    );
    expect(
      find.textContaining('research-informed ordinal prototype proxy'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'long details scroll without overflow and missing images are safe',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      const longDescription =
          'This long factual description is intentionally repeated to verify that approved destination details remain readable and scrollable on a phone-sized viewport without overflowing or requiring an image asset.';
      final destination = _destination(description: longDescription);
      await tester.pumpWidget(
        MaterialApp(
          theme: MashiTheme.light,
          home: DestinationDetailsScreen(
            destinationId: destination.id,
            repository: _TestDestinationRepository([destination]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('Source note'),
        500,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('Source note'), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(find.byType(Image), findsNothing);
    },
  );
}

Destination _destination({String? description}) {
  return Destination(
    id: 'approved-destination',
    name: 'Approved Destination',
    province: 'Central Province',
    description:
        description ?? 'A factual description from the approved record.',
    activities: {ActivityCategory.beach, ActivityCategory.waterSports},
    budgetLevel: BudgetLevel.medium,
    suitableGroups: {TravelGroup.solo, TravelGroup.friends},
    durationOptions: {TripDuration.medium},
    bestSeason: 'December to March',
    socialMediaAppealLevel: SocialMediaAppealLevel.high,
    socialMediaAppealScore: 0.667,
    sourceNote: 'Collective Appendix A provenance; controlled test record using the approved source basis.',
  );
}

RecommendationController _submittedController(Destination destination) {
  final controller = RecommendationController();
  controller.recommendations = [
    Recommendation(
      destination: destination,
      fitScore: 0.800,
      socialMediaAppealScore: 0.667,
      lambda: 0.350,
      finalScore: 0.812,
      matchedFactors: const ['budget', 'activities'],
      explanation: 'Matches your budget and activities.',
    ),
  ];
  controller.hasSubmitted = true;
  return controller;
}

Future<void> _pumpResults(
  WidgetTester tester, {
  required RecommendationController controller,
  required DestinationRepository repository,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: MashiTheme.light,
      routes: {
        AppRoutes.destinationDetails: (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          return DestinationDetailsScreen(
            destinationId: arguments is String ? arguments : null,
            repository: repository,
          );
        },
      },
      home: _ResultsLauncher(controller: controller),
    ),
  );
  await tester.tap(find.text('Open results'));
  await tester.pumpAndSettle();
}

class _TestDestinationRepository implements DestinationRepository {
  _TestDestinationRepository(this.destinations);

  final List<Destination> destinations;

  @override
  Future<List<Destination>> getDestinations() async => destinations;
}

class _ResultsLauncher extends StatelessWidget {
  const _ResultsLauncher({required this.controller});

  final RecommendationController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ResultsScreen(controller: controller),
            ),
          ),
          child: const Text('Open results'),
        ),
      ),
    );
  }
}
