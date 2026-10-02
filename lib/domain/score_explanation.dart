import '../models/destination.dart';
import '../models/model_validation.dart';
import '../models/user_preferences.dart';
import 'scoring_rules.dart';

List<String> matchedFactorsFor({
  required UserPreferences preferences,
  required Destination destination,
}) {
  final factors = <String>[];
  if (calculateBudgetMatch(
        preferredBudget: preferences.budgetLevel,
        destinationBudget: destination.budgetLevel,
      ) >
      0) {
    factors.add('budget');
  }
  if (calculateActivityOverlap(
        preferredActivities: preferences.activities,
        destinationActivities: destination.activities,
      ) >
      0) {
    factors.add('activities');
  }
  if (calculateTravelGroupMatch(
        preferredGroup: preferences.travelGroup,
        destinationGroups: destination.suitableGroups,
      ) >
      0) {
    factors.add('travel group');
  }
  if (calculateDurationMatch(
        preferredDuration: preferences.tripDuration,
        destinationDurations: destination.durationOptions,
      ) >
      0) {
    factors.add('trip duration');
  }
  if (calculateSocialMediaAppealScore(destination) > 0) {
    factors.add('social-media appeal proxy');
  }
  return List<String>.unmodifiable(factors);
}

String buildExplanation({
  required List<String> matchedFactors,
  required double socialMediaAppealScore,
}) {
  requireScoreInRange(socialMediaAppealScore, 'socialMediaAppealScore');
  final factorText = matchedFactors.isEmpty
      ? 'No preference factors matched'
      : 'Matches your ${_joinFactors(matchedFactors)}';
  final appealText =
      'The social-media-appeal proxy contributes '
      '${socialMediaAppealScore.toStringAsFixed(3)}.';
  return '$factorText. $appealText';
}

String _joinFactors(List<String> factors) {
  if (factors.length == 1) {
    return factors.single;
  }
  if (factors.length == 2) {
    return '${factors[0]} and ${factors[1]}';
  }
  return '${factors.sublist(0, factors.length - 1).join(', ')}, and ${factors.last}';
}
