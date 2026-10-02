import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/models/destination.dart';
import 'package:mashi_smoke/models/enums.dart';
import 'package:mashi_smoke/models/recommendation.dart';
import 'package:mashi_smoke/models/user_preferences.dart';

void main() {
  group('controlled enum values', () {
    test('parse to typed values and expose stable labels', () {
      expect(BudgetLevel.fromValue('HIGH'), BudgetLevel.high);
      expect(TravelGroup.fromValue('friends').label, 'Friends');
      expect(TripDuration.fromValue('short'), TripDuration.short);
      expect(
        SocialMediaUsageIntensity.fromValue('2 to 4 hours'),
        SocialMediaUsageIntensity.twoToFourHours,
      );
      expect(
        SocialMediaAppealLevel.fromValue('Very High'),
        SocialMediaAppealLevel.veryHigh,
      );
      expect(SocialMediaAppealLevel.low.score, 0.000);
      expect(SocialMediaAppealLevel.medium.score, 0.333);
      expect(SocialMediaAppealLevel.high.score, 0.667);
      expect(SocialMediaAppealLevel.veryHigh.score, 1.000);
      expect(ActivityCategory.fromValue('water sports').label, 'Water sports');
    });

    test('reject invalid enum values', () {
      expect(() => BudgetLevel.fromValue('premium'), throwsFormatException);
      expect(() => TravelGroup.fromValue('colleagues'), throwsFormatException);
      expect(() => TripDuration.fromValue('overnight'), throwsFormatException);
      expect(
        () => SocialMediaUsageIntensity.fromValue('occasionally'),
        throwsFormatException,
      );
      expect(
        () => ActivityCategory.fromValue('shopping'),
        throwsFormatException,
      );
      expect(
        () => SocialMediaAppealLevel.fromValue('Extreme'),
        throwsFormatException,
      );
    });

    test('normalizes approved budget, group, and duration labels', () {
      expect(BudgetLevel.fromValue('Low'), BudgetLevel.low);
      expect(BudgetLevel.fromValue('Low-Mid'), BudgetLevel.medium);
      expect(BudgetLevel.fromValue('Mid'), BudgetLevel.medium);
      expect(BudgetLevel.fromValue('Mid-High'), BudgetLevel.high);
      expect(BudgetLevel.fromValue('Low-Mid (Est.)'), BudgetLevel.medium);
      expect(BudgetLevel.fromValue('High'), BudgetLevel.high);

      expect(travelGroupsFromValue('All groups'), {
        TravelGroup.solo,
        TravelGroup.friends,
        TravelGroup.family,
        TravelGroup.partner,
      });
      expect(travelGroupsFromValue('Friends / Couples'), {
        TravelGroup.friends,
        TravelGroup.partner,
      });
      expect(travelGroupsFromValue('Friends / Solo'), {
        TravelGroup.friends,
        TravelGroup.solo,
      });
      expect(
        () => travelGroupsFromValue('Cultural travellers'),
        throwsFormatException,
      );

      expect(TripDuration.fromSourceDuration('half day'), TripDuration.short);
      expect(
        TripDuration.fromSourceDuration('1 day (trip)'),
        TripDuration.short,
      );
      expect(TripDuration.fromSourceDuration('1–2 days'), TripDuration.short);
      expect(TripDuration.fromSourceDuration('2–3 days'), TripDuration.medium);
      expect(TripDuration.fromSourceDuration('2–4 days'), TripDuration.medium);
      expect(TripDuration.fromSourceDuration('3–5 days'), TripDuration.medium);
      expect(TripDuration.fromSourceDuration('3–7 days'), TripDuration.long);
      expect(
        () => TripDuration.fromSourceDuration('overnight'),
        throwsFormatException,
      );
    });
  });

  group('Destination validation', () {
    test('accepts a complete valid record and preserves typed fields', () {
      final destination = buildDestination();

      expect(destination.id, 'ella');
      expect(destination.activities, contains(ActivityCategory.hillCountry));
      expect(destination.suitableGroups, contains(TravelGroup.friends));
      expect(destination.durationOptions, contains(TripDuration.medium));
      expect(destination.socialMediaAppealLevel, SocialMediaAppealLevel.medium);
      expect(destination.socialMediaAppealScore, 0.333);
    });

    test('rejects empty required text and collections', () {
      expect(() => buildDestination(id: '  '), throwsArgumentError);
      expect(() => buildDestination(name: ''), throwsArgumentError);
      expect(() => buildDestination(province: ''), throwsArgumentError);
      expect(() => buildDestination(description: ''), throwsArgumentError);
      expect(() => buildDestination(bestSeason: ''), throwsArgumentError);
      expect(() => buildDestination(sourceNote: ''), throwsArgumentError);
      expect(() => buildDestination(activities: {}), throwsArgumentError);
      expect(() => buildDestination(suitableGroups: {}), throwsArgumentError);
      expect(() => buildDestination(durationOptions: {}), throwsArgumentError);
    });

    test('rejects invalid or mismatched appeal scores', () {
      expect(
        () => buildDestination(socialMediaAppealScore: -0.01),
        throwsArgumentError,
      );
      expect(
        () => buildDestination(socialMediaAppealScore: 1.01),
        throwsArgumentError,
      );
      expect(
        () => buildDestination(socialMediaAppealScore: double.nan),
        throwsArgumentError,
      );
      expect(
        () => buildDestination(socialMediaAppealScore: double.infinity),
        throwsArgumentError,
      );
      expect(
        () => buildDestination(
          socialMediaAppealLevel: SocialMediaAppealLevel.high,
          socialMediaAppealScore: 0.333,
        ),
        throwsArgumentError,
      );
    });

    test('uses stable destination identity based on id', () {
      expect(buildDestination(), equals(buildDestination()));
      expect(buildDestination(), isNot(equals(buildDestination(id: 'kandy'))));
    });
  });

  group('UserPreferences validation', () {
    test('accepts typed selections', () {
      final preferences = UserPreferences(
        budgetLevel: BudgetLevel.medium,
        activities: {ActivityCategory.culture},
        travelGroup: TravelGroup.family,
        tripDuration: TripDuration.short,
        socialMediaUsageIntensity: SocialMediaUsageIntensity.oneToTwoHours,
      );

      expect(preferences.activities, {ActivityCategory.culture});
      expect(preferences.travelGroup, TravelGroup.family);
    });

    test('rejects an empty activity selection', () {
      expect(
        () => UserPreferences(
          budgetLevel: BudgetLevel.medium,
          activities: {},
          travelGroup: TravelGroup.solo,
          tripDuration: TripDuration.short,
          socialMediaUsageIntensity: SocialMediaUsageIntensity.lessThanOneHour,
        ),
        throwsArgumentError,
      );
    });
  });

  group('Recommendation validation', () {
    test('accepts bounded scores and explanatory fields', () {
      final recommendation = Recommendation(
        destination: buildDestination(),
        fitScore: 0.8,
        socialMediaAppealScore: 0.333,
        lambda: 0.35,
        finalScore: 0.765,
        matchedFactors: ['activities'],
        explanation: 'Matches the selected activity.',
      );

      expect(recommendation.finalScore, 0.765);
      expect(recommendation.matchedFactors, ['activities']);
    });

    test('rejects invalid scores and empty explanations', () {
      expect(
        () => Recommendation(
          destination: buildDestination(),
          fitScore: 1.2,
          socialMediaAppealScore: 0.333,
          lambda: 0.35,
          finalScore: 0.765,
          matchedFactors: const [],
          explanation: 'Explanation',
        ),
        throwsArgumentError,
      );
      expect(
        () => Recommendation(
          destination: buildDestination(),
          fitScore: 0.8,
          socialMediaAppealScore: 0.333,
          lambda: 0.35,
          finalScore: 0.765,
          matchedFactors: const [],
          explanation: '  ',
        ),
        throwsArgumentError,
      );
    });
  });
}

Destination buildDestination({
  String id = 'ella',
  String name = 'Ella',
  String province = 'Uva Province',
  String description = 'A highland destination.',
  Set<ActivityCategory> activities = const {
    ActivityCategory.hillCountry,
    ActivityCategory.adventure,
  },
  BudgetLevel budgetLevel = BudgetLevel.medium,
  Set<TravelGroup> suitableGroups = const {
    TravelGroup.solo,
    TravelGroup.friends,
  },
  Set<TripDuration> durationOptions = const {TripDuration.medium},
  String bestSeason = 'December to March',
  SocialMediaAppealLevel socialMediaAppealLevel = SocialMediaAppealLevel.medium,
  double socialMediaAppealScore = 0.333,
  String sourceNote = 'Approved Appendix A record.',
  String? imageReference,
}) {
  return Destination(
    id: id,
    name: name,
    province: province,
    description: description,
    activities: activities,
    budgetLevel: budgetLevel,
    suitableGroups: suitableGroups,
    durationOptions: durationOptions,
    bestSeason: bestSeason,
    socialMediaAppealLevel: socialMediaAppealLevel,
    socialMediaAppealScore: socialMediaAppealScore,
    sourceNote: sourceNote,
    imageReference: imageReference,
  );
}
