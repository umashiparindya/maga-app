import 'destination.dart';
import 'model_validation.dart';

class Recommendation {
  Recommendation({
    required this.destination,
    required double fitScore,
    required double socialMediaAppealScore,
    required double lambda,
    required double finalScore,
    required List<String> matchedFactors,
    required String explanation,
  }) : fitScore = requireScoreInRange(fitScore, 'fitScore'),
       socialMediaAppealScore = requireScoreInRange(
         socialMediaAppealScore,
         'socialMediaAppealScore',
       ),
       lambda = requireScoreInRange(lambda, 'lambda'),
       finalScore = requireScoreInRange(finalScore, 'finalScore'),
       matchedFactors = List<String>.unmodifiable(matchedFactors),
       explanation = requireNonBlank(explanation, 'explanation');

  final Destination destination;
  final double fitScore;
  final double socialMediaAppealScore;
  final double lambda;
  final double finalScore;
  final List<String> matchedFactors;
  final String explanation;
}
