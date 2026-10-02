import 'package:flutter/material.dart';

import '../application/recommendation_controller.dart';
import '../data/destination_repository.dart';
import '../presentation/screens/about_screen.dart';
import '../presentation/screens/destination_details_screen.dart';
import '../presentation/screens/preferences_screen.dart';
import '../presentation/screens/results_screen.dart';
import '../presentation/screens/welcome_screen.dart';

abstract final class AppRoutes {
  static const welcome = '/';
  static const preferences = '/preferences';
  static const results = '/results';
  static const destinationDetails = '/destination-details';
  static const about = '/about';

  static Map<String, WidgetBuilder> routesFor(
    RecommendationController controller, {
    required DestinationRepository repository,
  }) {
    return <String, WidgetBuilder>{
      welcome: (_) => const WelcomeScreen(),
      preferences: (_) => PreferencesScreen(controller: controller),
      results: (_) => ResultsScreen(controller: controller),
      destinationDetails: (context) {
        final arguments = ModalRoute.of(context)?.settings.arguments;
        return DestinationDetailsScreen(
          destinationId: arguments is String ? arguments : null,
          repository: repository,
        );
      },
      about: (_) => const AboutScreen(),
    };
  }
}
