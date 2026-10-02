import 'package:flutter/material.dart';

import '../../application/recommendation_controller.dart';
import '../../core/app_routes.dart';
import '../../core/app_theme.dart';
import '../../models/recommendation.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({required this.controller, super.key});

  final RecommendationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Results')),
          body: SafeArea(child: _buildBody(context)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading) {
      return Center(
        child: Semantics(
          container: true,
          liveRegion: true,
          label: 'Loading recommendations',
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (controller.errorMessage != null) {
      return _MessageState(
        message: controller.errorMessage!,
        actionLabel: 'Back to preferences',
        onAction: () => _editPreferences(context),
      );
    }
    if (controller.hasSubmitted && controller.recommendations.isEmpty) {
      return _EmptyResultsState(
        onEditPreferences: () => _editPreferences(context),
        onStartOver: () => _startOver(context),
      );
    }

    final recommendations = controller.recommendations;
    final countLabel =
        '${recommendations.length} ${recommendations.length == 1 ? 'recommendation' : 'recommendations'}';
    final children = <Widget>[
      Text('Recommendations', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: MashiSpace.compact),
      Text(countLabel, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: MashiSpace.compact),
      Text(
        'These results are ranked by the deterministic prototype rules. The social-media-appeal value is a research-informed proxy, not live analytics.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: MashiSpace.section),
    ];

    for (var index = 0; index < recommendations.length; index++) {
      final recommendation = recommendations[index];
      children.add(
        _RecommendationRow(
          rank: index + 1,
          recommendation: recommendation,
          onTap: () => Navigator.of(context).pushNamed(
            AppRoutes.destinationDetails,
            arguments: recommendation.destination.id,
          ),
        ),
      );
      if (index < recommendations.length - 1) {
        children.add(const Divider(height: MashiSpace.section));
      }
    }

    children.add(const SizedBox(height: MashiSpace.section));
    children.add(
      OutlinedButton(
        onPressed: () => _editPreferences(context),
        child: const Text('Edit preferences'),
      ),
    );
    children.add(const SizedBox(height: MashiSpace.compact));
    children.add(
      OutlinedButton(
        onPressed: () => _startOver(context),
        child: const Text('Start over'),
      ),
    );

    return ListView(
      padding: const EdgeInsets.all(MashiSpace.page),
      children: children,
    );
  }

  void _editPreferences(BuildContext context) {
    controller.clearRecommendationResults();
    Navigator.of(context).pop();
  }

  void _startOver(BuildContext context) {
    controller.reset();
    Navigator.of(context).popUntil(
      (route) => route.settings.name == AppRoutes.welcome || route.isFirst,
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.rank,
    required this.recommendation,
    required this.onTap,
  });

  final int rank;
  final Recommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final destination = recommendation.destination;
    final score = recommendation.finalScore.toStringAsFixed(3);
    final proxyScore = recommendation.socialMediaAppealScore.toStringAsFixed(3);

    return Semantics(
      button: true,
      label:
          '${destination.name}. Prototype score $score out of 1.000. ${recommendation.explanation}',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MashiSpace.compact),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '#${rank.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: MashiColors.warm,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: MashiSpace.compact),
                  Expanded(
                    child: Text(
                      destination.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                destination.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Prototype score: $score / 1.000',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Social-media appeal proxy: $proxyScore',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 6),
              Text(
                recommendation.explanation,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyResultsState extends StatelessWidget {
  const _EmptyResultsState({
    required this.onEditPreferences,
    required this.onStartOver,
  });

  final VoidCallback onEditPreferences;
  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MashiSpace.page),
      children: [
        Text(
          'No recommendations',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: MashiSpace.compact),
        Text(
          'No approved destinations are available to show for this search.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: MashiSpace.section),
        OutlinedButton(
          onPressed: onEditPreferences,
          child: const Text('Edit preferences'),
        ),
        const SizedBox(height: MashiSpace.compact),
        OutlinedButton(onPressed: onStartOver, child: const Text('Start over')),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MashiSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: MashiSpace.section),
          OutlinedButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    );
  }
}
