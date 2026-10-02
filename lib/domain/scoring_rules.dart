import '../models/destination.dart';
import '../models/enums.dart';
import '../models/model_validation.dart';
import '../models/user_preferences.dart';

const double budgetCompatibilityWeight = 0.25;
const double activityOverlapWeight = 0.35;
const double travelGroupSuitabilityWeight = 0.20;
const double tripDurationCompatibilityWeight = 0.20;

/// Returns the compatibility of two normalized budget levels.
///
/// Adjacent levels receive a partial match. There is no hard filtering in the
/// Step 5 engine: every validated destination receives a deterministic score.
double calculateBudgetMatch({
  required BudgetLevel preferredBudget,
  required BudgetLevel destinationBudget,
}) {
  final distance = (preferredBudget.index - destinationBudget.index).abs();
  return switch (distance) {
    0 => 1.0,
    1 => 0.5,
    _ => 0.0,
  };
}

double calculateActivityOverlap({
  required Set<ActivityCategory> preferredActivities,
  required Set<ActivityCategory> destinationActivities,
}) {
  if (preferredActivities.isEmpty) {
    throw ArgumentError.value(
      preferredActivities,
      'preferredActivities',
      'must not be empty',
    );
  }
  if (destinationActivities.isEmpty) {
    throw ArgumentError.value(
      destinationActivities,
      'destinationActivities',
      'must not be empty',
    );
  }

  final matchingActivities = preferredActivities.intersection(
    destinationActivities,
  );
  return matchingActivities.length / preferredActivities.length;
}

double calculateTravelGroupMatch({
  required TravelGroup preferredGroup,
  required Set<TravelGroup> destinationGroups,
}) {
  if (destinationGroups.isEmpty) {
    throw ArgumentError.value(
      destinationGroups,
      'destinationGroups',
      'must not be empty',
    );
  }
  return destinationGroups.contains(preferredGroup) ? 1.0 : 0.0;
}

double calculateDurationMatch({
  required TripDuration preferredDuration,
  required Set<TripDuration> destinationDurations,
}) {
  if (destinationDurations.isEmpty) {
    throw ArgumentError.value(
      destinationDurations,
      'destinationDurations',
      'must not be empty',
    );
  }
  if (destinationDurations.contains(preferredDuration)) {
    return 1.0;
  }

  final hasAdjacentDuration = destinationDurations.any(
    (duration) => (duration.index - preferredDuration.index).abs() == 1,
  );
  return hasAdjacentDuration ? 0.5 : 0.0;
}

double calculateFitScore({
  required UserPreferences preferences,
  required Destination destination,
}) {
  final budgetMatch = calculateBudgetMatch(
    preferredBudget: preferences.budgetLevel,
    destinationBudget: destination.budgetLevel,
  );
  final activityMatch = calculateActivityOverlap(
    preferredActivities: preferences.activities,
    destinationActivities: destination.activities,
  );
  final groupMatch = calculateTravelGroupMatch(
    preferredGroup: preferences.travelGroup,
    destinationGroups: destination.suitableGroups,
  );
  final durationMatch = calculateDurationMatch(
    preferredDuration: preferences.tripDuration,
    destinationDurations: destination.durationOptions,
  );

  return requireScoreInRange(
    budgetMatch * budgetCompatibilityWeight +
        activityMatch * activityOverlapWeight +
        groupMatch * travelGroupSuitabilityWeight +
        durationMatch * tripDurationCompatibilityWeight,
    'fitScore',
  );
}

double calculateSocialMediaAppealScore(Destination destination) {
  // Destination validates that this value matches its typed ordinal level.
  return requireScoreInRange(
    destination.socialMediaAppealScore,
    'socialMediaAppealScore',
  );
}

double lambdaForUsageIntensity(SocialMediaUsageIntensity intensity) {
  return switch (intensity) {
    SocialMediaUsageIntensity.lessThanOneHour => 0.25,
    SocialMediaUsageIntensity.oneToTwoHours => 0.35,
    SocialMediaUsageIntensity.twoToFourHours => 0.45,
    SocialMediaUsageIntensity.moreThanFourHours => 0.55,
  };
}

double calculateFinalScore({
  required double fitScore,
  required double lambda,
  required double socialMediaAppealScore,
}) {
  requireScoreInRange(fitScore, 'fitScore');
  requireScoreInRange(lambda, 'lambda');
  requireScoreInRange(socialMediaAppealScore, 'socialMediaAppealScore');

  return requireScoreInRange(
    (1 - lambda) * fitScore + lambda * socialMediaAppealScore,
    'finalScore',
  );
}
