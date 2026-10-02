import 'package:flutter/material.dart';

import '../../core/app_identity.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../widgets/maga_brand_mark.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppIdentity.productName),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.about),
            child: const Text('About'),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(MashiSpace.page),
          children: [
            const SizedBox(height: MashiSpace.compact),
            const MagaBrandMark(),
            const SizedBox(height: MashiSpace.section),
            Text(
              'Plan your next Sri Lankan trip with clarity.',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: MashiSpace.compact),
            Text(
              AppIdentity.welcomeSummary,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: MashiSpace.section),
            const Divider(),
            const SizedBox(height: MashiSpace.section),
            Text(
              'Start with five simple choices',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: MashiSpace.compact),
            Text(
              'Budget, activities, travel group, duration, and daily social media use.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: MashiSpace.section),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(AppRoutes.preferences),
              child: const Text('Start preferences'),
            ),
            const SizedBox(height: MashiSpace.compact),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.about),
              child: const Text('How this prototype works'),
            ),
          ],
        ),
      ),
    );
  }
}
