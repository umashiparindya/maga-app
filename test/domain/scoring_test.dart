import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/domain/recommendation_engine.dart';
import 'package:mashi_smoke/domain/score_explanation.dart';
import 'package:mashi_smoke/domain/scoring_rules.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';
import 'package:mashi_smoke/models/user_preferences.dart';

void main() {
  group('component matching', () {
    test('returns exact, adjacent, and incompatible budget matches', () {
      expect(
        calculateBudgetMatch(
          preferredBudget: BudgetLevel.medium,
          destinationBudget: BudgetLevel.medium,
        ),
        1.0,
      );
      expect(
        calculateBudgetMatch(
          preferredBudget: BudgetLevel.low,
          destinationBudget: BudgetLevel.medium,
        ),
        0.5,
      );
      expect(
        calculateBudgetMatch(
          preferredBudget: BudgetLevel.low,
          destinationBudget: BudgetLevel.high,
        ),
        0.0,
      );
    });

    test('uses the approved Low-Mid, Mid, and Mid-High budget mappings', () {
      expect(BudgetLevel.fromValue('Low-Mid'), BudgetLevel.medium);
      expect(BudgetLevel.fromValue('Mid'), BudgetLevel.medium);
      expect(BudgetLevel.fromValue('Mid-High'), BudgetLevel.high);
      expect(
        calculateBudgetMatch(
          preferredBudget: BudgetLevel.medium,
          destinationBudget: BudgetLevel.medium,
        ),
        1.0,
      );
      expect(
        calculateBudgetMatch(
          preferredBudget: BudgetLevel.medium,
          destinationBudget: BudgetLevel.high,
        ),
        0.5,
      );
    });

    test('calculates activity overlap as the selected-activity proportion', () {
      expect(
        calculateActivityOverlap(
          preferredActivities: {
            ActivityCategory.beach,
            ActivityCategory.nature,
            ActivityCategory.photography,
          },
          destinationActivities: {
            ActivityCategory.beach,
            ActivityCategory.photography,
          },
        ),
        closeTo(2 / 3, 0.000001),
      );
      expect(
        () => calculateActivityOverlap(
          preferredActivities: {},
          destinationActivities: {ActivityCategory.beach},
        ),
        throwsArgumentError,
      );
    });

    test('matches travel groups against supported destination groups', () {
      expect(
        calculateTravelGroupMatch(
          preferredGroup: TravelGroup.partner,
          destinationGroups: {TravelGroup.friends, TravelGroup.partner},
        ),
        1.0,
      );
      expect(
        calculateTravelGroupMatch(
          preferredGroup: TravelGroup.solo,
          destinationGroups: {TravelGroup.friends},
        ),
        0.0,
      );
      expect(
        () => calculateTravelGroupMatch(
          preferredGroup: TravelGroup.solo,
          destinationGroups: {},
        ),
        throwsArgumentError,
      );
    });

    test('matches exact and adjacent durations', () {
      expect(
        calculateDurationMatch(
          preferredDuration: TripDuration.medium,
          destinationDurations: {TripDuration.medium},
        ),
        1.0,
      );
      expect(
        calculateDurationMatch(
          preferredDuration: TripDuration.medium,
          destinationDurations: {TripDuration.short},
        ),
        0.5,
      );
      expect(
        calculateDurationMatch(
          preferredDuration: TripDuration.short,
          destinationDurations: {TripDuration.long},
        ),
        0.0,
      );
      expect(
        () => calculateDurationMatch(
          preferredDuration: TripDuration.short,
          destinationDurations: {},
        ),
        throwsArgumentError,
      );
    });
  });

  group('scoring rules', () {
    test('calculates FitScore from the locked component weights', () {
      final preferences = buildPreferences(
        budgetLevel: BudgetLevel.medium,
        activities: {ActivityCategory.beach, ActivityCategory.nature},
        travelGroup: TravelGroup.friends,
        tripDuration: TripDuration.medium,
      );
      final destination = buildDestination(
        budgetLevel: BudgetLevel.medium,
        activities: {ActivityCategory.beach},
        suitableGroups: {TravelGroup.friends},
        durationOptions: {TripDuration.medium},
      );

      // 1.0*0.25 + 0.5*0.35 + 1.0*0.20 + 1.0*0.20 = 0.825.
      expect(
        calculateFitScore(preferences: preferences, destination: destination),
        closeTo(0.825, 0.000001),
      );
      expect(
        budgetCompatibilityWeight +
            activityOverlapWeight +
            travelGroupSuitabilityWeight +
            tripDurationCompatibilityWeight,
        closeTo(1.0, 0.000001),
      );
    });

    test('retrieves the validated appeal score for every ordinal level', () {
      for (final level in SocialMediaAppealLevel.values) {
        expect(
          calculateSocialMediaAppealScore(
            buildDestination(id: level.name, socialMediaAppealLevel: level),
          ),
          level.score,
        );
      }
    });

    test('maps all usage intensities to the locked lambda values', () {
      expect(
        lambdaForUsageIntensity(SocialMediaUsageIntensity.lessThanOneHour),
        0.25,
      );
      expect(
        lambdaForUsageIntensity(SocialMediaUsageIntensity.oneToTwoHours),
        0.35,
      );
      expect(
        lambdaForUsageIntensity(SocialMediaUsageIntensity.twoToFourHours),
        0.45,
      );
      expect(
        lambdaForUsageIntensity(SocialMediaUsageIntensity.moreThanFourHours),
        0.55,
      );
    });

    test('calculates the hand-checked final score', () {
      final score = calculateFinalScore(
        fitScore: 0.80,
        socialMediaAppealScore: 0.667,
        lambda: 0.35,
      );

      expect(score, closeTo(0.75345, 0.000001));
    });

    test('rejects invalid score inputs', () {
      expect(
        () => calculateFinalScore(
          fitScore: 1.01,
          socialMediaAppealScore: 0.667,
          lambda: 0.35,
        ),
        throwsArgumentError,
      );
      expect(
        () => calculateFinalScore(
          fitScore: 0.8,
          socialMediaAppealScore: double.nan,
          lambda: 0.35,
        ),
        throwsArgumentError,
      );
    });
  });

  group('recommendation engine', () {
    test('ranks by score and breaks ties by stable destination ID', () {
      final preferences = buildPreferences();
      final recommendations = recommend(
        preferences: preferences,
        destinations: [
          buildDestination(
            id: 'zeta',
            socialMediaAppealLevel: SocialMediaAppealLevel.low,
          ),
          buildDestination(
            id: 'beta',
            socialMediaAppealLevel: SocialMediaAppealLevel.high,
          ),
          buildDestination(
            id: 'alpha',
            socialMediaAppealLevel: SocialMediaAppealLevel.high,
          ),
        ],
      );

      expect(
        recommendations.map((recommendation) => recommendation.destination.id),
        ['alpha', 'beta', 'zeta'],
      );
      expect(
        recommendations.first.finalScore,
        greaterThan(recommendations.last.finalScore),
      );
    });

    test('returns an empty result for an empty destination list', () {
      expect(
        recommend(preferences: buildPreferences(), destinations: const []),
        isEmpty,
      );
    });

    test('does not silently hard-filter incompatible destinations', () {
      final result = recommend(
        preferences: buildPreferences(
          budgetLevel: BudgetLevel.low,
          travelGroup: TravelGroup.solo,
          tripDuration: TripDuration.short,
        ),
        destinations: [
          buildDestination(
            id: 'incompatible',
            budgetLevel: BudgetLevel.high,
            activities: {ActivityCategory.wildlife},
            suitableGroups: {TravelGroup.family},
            durationOptions: {TripDuration.long},
            socialMediaAppealLevel: SocialMediaAppealLevel.low,
          ),
        ],
      );

      expect(result, hasLength(1));
      expect(result.single.fitScore, 0.0);
    });

    test('is deterministic for repeated calls with identical inputs', () {
      final preferences = buildPreferences(
        socialMediaUsageIntensity: SocialMediaUsageIntensity.twoToFourHours,
      );
      final destinations = [
        buildDestination(id: 'ella'),
        buildDestination(
          id: 'kandy',
          socialMediaAppealLevel: SocialMediaAppealLevel.high,
        ),
      ];

      final first = recommend(
        preferences: preferences,
        destinations: destinations,
      );
      final second = recommend(
        preferences: preferences,
        destinations: destinations,
      );

      expect(
        first.map((recommendation) => recommendation.destination.id).toList(),
        second.map((recommendation) => recommendation.destination.id).toList(),
      );
      expect(
        first.map((recommendation) => recommendation.finalScore).toList(),
        second.map((recommendation) => recommendation.finalScore).toList(),
      );
      expect(
        first.map((recommendation) => recommendation.explanation).toList(),
        second.map((recommendation) => recommendation.explanation).toList(),
      );
    });
  });

  group('explanations', () {
    test('describe actual matched factors and appeal contribution', () {
      final preferences = buildPreferences();
      final destination = buildDestination();
      final factors = matchedFactorsFor(
        preferences: preferences,
        destination: destination,
      );
      final explanation = buildExplanation(
        matchedFactors: factors,
        socialMediaAppealScore: destination.socialMediaAppealScore,
      );

      expect(factors, containsAll(['budget', 'activities', 'travel group']));
      expect(factors, contains('trip duration'));
      expect(explanation, contains('budget'));
      expect(explanation, contains('social-media-appeal proxy'));
      expect(explanation, isNot(contains('content credibility')));
    });

    test(
      'handles no matched preference factors without an empty explanation',
      () {
        final explanation = buildExplanation(
          matchedFactors: const [],
          socialMediaAppealScore: 0.0,
        );

        expect(explanation, startsWith('No preference factors matched.'));
        expect(explanation, contains('0.000'));
      },
    );

    test('rejects an invalid appeal score in an explanation', () {
      expect(
        () => buildExplanation(
          matchedFactors: const [],
          socialMediaAppealScore: double.nan,
        ),
        throwsArgumentError,
      );
    });
  });
}

Destination buildDestination({
  String id = 'ella',
  String name = 'Ella',
  BudgetLevel budgetLevel = BudgetLevel.medium,
  Set<ActivityCategory> activities = const {
    ActivityCategory.beach,
    ActivityCategory.nature,
  },
  Set<TravelGroup> suitableGroups = const {TravelGroup.friends},
  Set<TripDuration> durationOptions = const {TripDuration.medium},
  SocialMediaAppealLevel socialMediaAppealLevel = SocialMediaAppealLevel.medium,
}) {
  return Destination(
    id: id,
    name: name,
    province: 'Uva Province',
    description: 'A destination used for deterministic scoring tests.',
    activities: activities,
    budgetLevel: budgetLevel,
    suitableGroups: suitableGroups,
    durationOptions: durationOptions,
    bestSeason: 'December to March',
    socialMediaAppealLevel: socialMediaAppealLevel,
    socialMediaAppealScore: socialMediaAppealLevel.score,
    sourceNote: 'Test fixture only.',
  );
}

UserPreferences buildPreferences({
  BudgetLevel budgetLevel = BudgetLevel.medium,
  Set<ActivityCategory> activities = const {
    ActivityCategory.beach,
    ActivityCategory.nature,
  },
  TravelGroup travelGroup = TravelGroup.friends,
  TripDuration tripDuration = TripDuration.medium,
  SocialMediaUsageIntensity socialMediaUsageIntensity =
      SocialMediaUsageIntensity.oneToTwoHours,
}) {
  return UserPreferences(
    budgetLevel: budgetLevel,
    activities: activities,
    travelGroup: travelGroup,
    tripDuration: tripDuration,
    socialMediaUsageIntensity: socialMediaUsageIntensity,
  );
}
