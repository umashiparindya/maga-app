import 'enums.dart';
import 'model_validation.dart';

class UserPreferences {
  UserPreferences({
    required this.budgetLevel,
    required Set<ActivityCategory> activities,
    required this.travelGroup,
    required this.tripDuration,
    required this.socialMediaUsageIntensity,
  }) : activities = requireNonEmptySet(activities, 'activities');

  final BudgetLevel budgetLevel;
  final Set<ActivityCategory> activities;
  final TravelGroup travelGroup;
  final TripDuration tripDuration;
  final SocialMediaUsageIntensity socialMediaUsageIntensity;
}
