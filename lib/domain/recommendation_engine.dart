import '../models/destination.dart';
import '../models/recommendation.dart';
import '../models/user_preferences.dart';
import 'score_explanation.dart';
import 'scoring_rules.dart';

List<Recommendation> recommend({
  required UserPreferences preferences,
  required List<Destination> destinations,
}) =>
    recommendDestinations(preferences: preferences, destinations: destinations);

List<Recommendation> recommendDestinations({
  required UserPreferences preferences,
  required List<Destination> destinations,
}) {
  if (destinations.isEmpty) {
    return const <Recommendation>[];
  }

  final lambda = lambdaForUsageIntensity(preferences.socialMediaUsageIntensity);
  final recommendations = destinations
      .map((destination) {
        final fitScore = calculateFitScore(
          preferences: preferences,
          destination: destination,
        );
        final socialMediaAppealScore = calculateSocialMediaAppealScore(
          destination,
        );
        final matchedFactors = matchedFactorsFor(
          preferences: preferences,
          destination: destination,
        );
        return Recommendation(
          destination: destination,
          fitScore: fitScore,
          socialMediaAppealScore: socialMediaAppealScore,
          lambda: lambda,
          finalScore: calculateFinalScore(
            fitScore: fitScore,
            lambda: lambda,
            socialMediaAppealScore: socialMediaAppealScore,
          ),
          matchedFactors: matchedFactors,
          explanation: buildExplanation(
            matchedFactors: matchedFactors,
            socialMediaAppealScore: socialMediaAppealScore,
          ),
        );
      })
      .toList(growable: false);

  return rankRecommendations(recommendations);
}

class RecommendationEngine {
  const RecommendationEngine();

  List<Recommendation> recommend({
    required UserPreferences preferences,
    required List<Destination> destinations,
  }) {
    return recommendDestinations(
      preferences: preferences,
      destinations: destinations,
    );
  }
}

List<Recommendation> rankRecommendations(List<Recommendation> recommendations) {
  final indexed = recommendations.indexed.toList();
  indexed.sort((left, right) {
    final scoreComparison = right.$2.finalScore.compareTo(left.$2.finalScore);
    if (scoreComparison != 0) {
      return scoreComparison;
    }

    final idComparison = left.$2.destination.id.compareTo(
      right.$2.destination.id,
    );
    if (idComparison != 0) {
      return idComparison;
    }

    final nameComparison = left.$2.destination.name.compareTo(
      right.$2.destination.name,
    );
    if (nameComparison != 0) {
      return nameComparison;
    }

    return left.$1.compareTo(right.$1);
  });
  return indexed.map((entry) => entry.$2).toList(growable: false);
}
