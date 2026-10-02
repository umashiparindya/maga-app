import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/application/recommendation_controller.dart';
import 'package:mashi_smoke/data/destination_repository.dart';
import 'package:mashi_smoke/data/destination_seed.dart';
import 'package:mashi_smoke/domain/recommendation_engine.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';
import 'package:mashi_smoke/models/recommendation.dart';
import 'package:mashi_smoke/models/user_preferences.dart';

void main() {
  test(
    'valid preferences load the repository and invoke the engine once',
    () async {
      final repository = FakeRepository([destinationSeed.first]);
      final engine = FakeEngine([buildRecommendation(destinationSeed.first)]);
      final controller = RecommendationController(
        repository: repository,
        engine: engine,
      );
      fillValidPreferences(controller);

      expect(await controller.submit(), isTrue);
      expect(repository.calls, 1);
      expect(engine.calls, 1);
      expect(engine.lastPreferences?.budgetLevel, BudgetLevel.medium);
      expect(controller.recommendations, hasLength(1));
      expect(controller.errorMessage, isNull);
    },
  );

  test('loading state is exposed while repository work is pending', () async {
    final pending = Completer<List<Destination>>();
    final repository = FakeRepository(const [], null, pending);
    final controller = RecommendationController(repository: repository);
    fillValidPreferences(controller);

    final submission = controller.submit();
    await Future<void>.delayed(Duration.zero);
    expect(controller.isLoading, isTrue);

    pending.complete([destinationSeed.first]);
    expect(await submission, isTrue);
    expect(controller.isLoading, isFalse);
  });

  test(
    'empty repositories produce an intentional empty result state',
    () async {
      final controller = RecommendationController(
        repository: FakeRepository(const []),
        engine: FakeEngine(const []),
      );
      fillValidPreferences(controller);

      expect(await controller.submit(), isTrue);
      expect(controller.hasSubmitted, isTrue);
      expect(controller.recommendations, isEmpty);
      expect(controller.errorMessage, isNull);
    },
  );

  test(
    'repository errors expose safe copy without exception details',
    () async {
      final controller = RecommendationController(
        repository: FakeRepository(
          const [],
          StateError('secret stack details'),
        ),
      );
      fillValidPreferences(controller);

      expect(await controller.submit(), isFalse);
      expect(controller.errorMessage, isNotNull);
      expect(controller.errorMessage, isNot(contains('secret stack details')));
      expect(controller.errorMessage, isNot(contains('StackTrace')));
      expect(controller.recommendations, isEmpty);
    },
  );

  test('reset clears preferences, validation, errors, and results', () async {
    final controller = RecommendationController(
      repository: FakeRepository([destinationSeed.first]),
      engine: FakeEngine([buildRecommendation(destinationSeed.first)]),
    );
    fillValidPreferences(controller);
    await controller.submit();

    controller.reset();

    expect(controller.budgetLevel, isNull);
    expect(controller.activities, isEmpty);
    expect(controller.travelGroup, isNull);
    expect(controller.tripDuration, isNull);
    expect(controller.socialMediaUsageIntensity, isNull);
    expect(controller.recommendations, isEmpty);
    expect(controller.hasSubmitted, isFalse);
    expect(controller.validationMessage, isNull);
    expect(controller.errorMessage, isNull);
  });
}

void fillValidPreferences(RecommendationController controller) {
  controller.setBudgetLevel(BudgetLevel.medium);
  controller.toggleActivity(ActivityCategory.beach);
  controller.setTravelGroup(TravelGroup.friends);
  controller.setTripDuration(TripDuration.medium);
  controller.setSocialMediaUsageIntensity(
    SocialMediaUsageIntensity.oneToTwoHours,
  );
}

Recommendation buildRecommendation(Destination destination) {
  return Recommendation(
    destination: destination,
    fitScore: 0.8,
    socialMediaAppealScore: destination.socialMediaAppealScore,
    lambda: 0.35,
    finalScore: 0.75,
    matchedFactors: const ['budget'],
    explanation: 'Matches the selected budget.',
  );
}

class FakeRepository implements DestinationRepository {
  FakeRepository([this.destinations = const [], this.failure, this.pending]);

  final List<Destination> destinations;
  final Object? failure;
  final Completer<List<Destination>>? pending;
  int calls = 0;

  @override
  Future<List<Destination>> getDestinations() async {
    calls++;
    if (failure != null) {
      throw failure!;
    }
    if (pending != null) {
      return pending!.future;
    }
    return destinations;
  }
}

class FakeEngine extends RecommendationEngine {
  FakeEngine(this.result);

  final List<Recommendation> result;
  int calls = 0;
  UserPreferences? lastPreferences;

  @override
  List<Recommendation> recommend({
    required UserPreferences preferences,
    required List<Destination> destinations,
  }) {
    calls++;
    lastPreferences = preferences;
    return result;
  }
}
