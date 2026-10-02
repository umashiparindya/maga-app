import 'package:flutter/material.dart';

import '../../application/recommendation_controller.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../models/enums.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({required this.controller, super.key});

  final RecommendationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Preferences')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(MashiSpace.page),
              children: [
                Text(
                  'Choose your trip preferences.',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: MashiSpace.section),
                const _SectionHeading(label: 'Trip essentials'),
                const SizedBox(height: MashiSpace.compact),
                DropdownButtonFormField<BudgetLevel>(
                  initialValue: controller.budgetLevel,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Budget',
                    helperText: 'Choose the spending range for your trip.',
                  ),
                  items: BudgetLevel.values
                      .map(
                        (level) => DropdownMenuItem(
                          value: level,
                          child: Text(level.label),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setBudgetLevel,
                ),
                const SizedBox(height: MashiSpace.compact),
                const _SectionHeading(label: 'Activities and travel style'),
                const SizedBox(height: MashiSpace.compact),
                Text(
                  'Select at least one activity or travel style.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                ...ActivityCategory.values.map(
                  (activity) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(activity.label),
                    value: controller.activities.contains(activity),
                    onChanged: (_) => controller.toggleActivity(activity),
                  ),
                ),
                const SizedBox(height: MashiSpace.compact),
                const _SectionHeading(label: 'Trip context'),
                const SizedBox(height: MashiSpace.compact),
                DropdownButtonFormField<TravelGroup>(
                  initialValue: controller.travelGroup,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Travel group',
                    helperText: 'Who will travel with you?',
                  ),
                  items: TravelGroup.values
                      .map(
                        (group) => DropdownMenuItem(
                          value: group,
                          child: Text(group.label),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setTravelGroup,
                ),
                const SizedBox(height: MashiSpace.compact),
                DropdownButtonFormField<TripDuration>(
                  initialValue: controller.tripDuration,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Trip duration',
                    helperText: 'How long do you plan to travel?',
                  ),
                  items: TripDuration.values
                      .map(
                        (duration) => DropdownMenuItem(
                          value: duration,
                          child: Text(duration.label),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setTripDuration,
                ),
                const SizedBox(height: MashiSpace.compact),
                const _SectionHeading(label: 'Social media use'),
                const SizedBox(height: MashiSpace.compact),
                DropdownButtonFormField<SocialMediaUsageIntensity>(
                  initialValue: controller.socialMediaUsageIntensity,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Daily social media use',
                    helperText: 'Choose your typical daily usage time.',
                  ),
                  items: SocialMediaUsageIntensity.values
                      .map(
                        (intensity) => DropdownMenuItem(
                          value: intensity,
                          child: Text(intensity.label),
                        ),
                      )
                      .toList(),
                  onChanged: controller.setSocialMediaUsageIntensity,
                ),
                if (controller.validationMessage != null) ...[
                  const SizedBox(height: MashiSpace.compact),
                  Semantics(
                    liveRegion: true,
                    container: true,
                    child: Text(
                      controller.validationMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: MashiSpace.compact),
                FilledButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final submitted = await controller.submit();
                          if (!context.mounted ||
                              (!submitted && controller.errorMessage == null)) {
                            return;
                          }
                          Navigator.of(context).pushNamed(AppRoutes.results);
                        },
                  child: controller.isLoading
                      ? Semantics(
                          container: true,
                          liveRegion: true,
                          label: 'Loading recommendations',
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : const Text('Get recommendations'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 3,
          decoration: const BoxDecoration(
            color: MashiColors.warm,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleMedium),
        ),
      ],
    );
  }
}
