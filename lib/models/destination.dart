import 'enums.dart';
import 'model_validation.dart';

class Destination {
  Destination({
    required String id,
    required String name,
    required String province,
    required String description,
    required Set<ActivityCategory> activities,
    required this.budgetLevel,
    required Set<TravelGroup> suitableGroups,
    required Set<TripDuration> durationOptions,
    required String bestSeason,
    required this.socialMediaAppealLevel,
    required double socialMediaAppealScore,
    required String sourceNote,
    String? imageReference,
  }) : id = requireNonBlank(id, 'id'),
       name = requireNonBlank(name, 'name'),
       province = requireNonBlank(province, 'province'),
       description = requireNonBlank(description, 'description'),
       activities = requireNonEmptySet(activities, 'activities'),
       suitableGroups = requireNonEmptySet(suitableGroups, 'suitableGroups'),
       durationOptions = requireNonEmptySet(durationOptions, 'durationOptions'),
       bestSeason = requireNonBlank(bestSeason, 'bestSeason'),
       socialMediaAppealScore = requireScoreMatching(
         socialMediaAppealScore,
         socialMediaAppealLevel.score,
         'socialMediaAppealScore',
       ),
       sourceNote = requireNonBlank(sourceNote, 'sourceNote'),
       imageReference = imageReference == null
           ? null
           : requireNonBlank(imageReference, 'imageReference');

  final String id;
  final String name;
  final String province;
  final String description;
  final Set<ActivityCategory> activities;
  final BudgetLevel budgetLevel;
  final Set<TravelGroup> suitableGroups;
  final Set<TripDuration> durationOptions;
  final String bestSeason;
  final SocialMediaAppealLevel socialMediaAppealLevel;
  final double socialMediaAppealScore;
  final String? imageReference;
  final String sourceNote;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Destination && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
