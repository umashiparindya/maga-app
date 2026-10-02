import 'package:flutter/foundation.dart';

import '../data/destination_repository.dart';
import '../data/local_destination_repository.dart';
import '../domain/recommendation_engine.dart';
import '../models/enums.dart';
import '../models/recommendation.dart';
import '../models/user_preferences.dart';

class RecommendationController extends ChangeNotifier {
  RecommendationController({
    DestinationRepository? repository,
    RecommendationEngine? engine,
  }) : _repository = repository ?? LocalDestinationRepository(),
       _engine = engine ?? const RecommendationEngine();

  final DestinationRepository _repository;
  final RecommendationEngine _engine;

  BudgetLevel? budgetLevel;
  final Set<ActivityCategory> activities = <ActivityCategory>{};
  TravelGroup? travelGroup;
  TripDuration? tripDuration;
  SocialMediaUsageIntensity? socialMediaUsageIntensity;

  List<Recommendation> recommendations = const <Recommendation>[];
  bool isLoading = false;
  bool hasSubmitted = false;
  String? validationMessage;
  String? errorMessage;

  bool get canSubmit =>
      budgetLevel != null &&
      activities.isNotEmpty &&
      travelGroup != null &&
      tripDuration != null &&
      socialMediaUsageIntensity != null;

  UserPreferences? get currentPreferences {
    if (!canSubmit) {
      return null;
    }
    return UserPreferences(
      budgetLevel: budgetLevel!,
      activities: activities,
      travelGroup: travelGroup!,
      tripDuration: tripDuration!,
      socialMediaUsageIntensity: socialMediaUsageIntensity!,
    );
  }

  void setBudgetLevel(BudgetLevel? value) {
    budgetLevel = value;
    _clearMessages();
    notifyListeners();
  }

  void setTravelGroup(TravelGroup? value) {
    travelGroup = value;
    _clearMessages();
    notifyListeners();
  }

  void setTripDuration(TripDuration? value) {
    tripDuration = value;
    _clearMessages();
    notifyListeners();
  }

  void setSocialMediaUsageIntensity(SocialMediaUsageIntensity? value) {
    socialMediaUsageIntensity = value;
    _clearMessages();
    notifyListeners();
  }

  void toggleActivity(ActivityCategory activity) {
    if (!activities.add(activity)) {
      activities.remove(activity);
    }
    _clearMessages();
    notifyListeners();
  }

  Future<bool> submit() async {
    if (!canSubmit) {
      validationMessage = 'Choose a budget, at least one activity, a travel group, a trip duration, and your daily social media use.';
      hasSubmitted = true;
      notifyListeners();
      return false;
    }

    final preferences = currentPreferences!;
    isLoading = true;
    hasSubmitted = true;
    validationMessage = null;
    errorMessage = null;
    recommendations = const <Recommendation>[];
    notifyListeners();

    try {
      final destinations = await _repository.getDestinations();
      recommendations = _engine.recommend(
        preferences: preferences,
        destinations: destinations,
      );
      return true;
    } catch (_) {
      recommendations = const <Recommendation>[];
      errorMessage =
          'Recommendations are temporarily unavailable. Please try again.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearRecommendationResults() {
    recommendations = const <Recommendation>[];
    isLoading = false;
    hasSubmitted = false;
    validationMessage = null;
    errorMessage = null;
    notifyListeners();
  }

  void reset() {
    budgetLevel = null;
    activities.clear();
    travelGroup = null;
    tripDuration = null;
    socialMediaUsageIntensity = null;
    recommendations = const <Recommendation>[];
    isLoading = false;
    hasSubmitted = false;
    validationMessage = null;
    errorMessage = null;
    notifyListeners();
  }

  void _clearMessages() {
    validationMessage = null;
    errorMessage = null;
  }
}
