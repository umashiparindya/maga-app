import 'package:flutter/material.dart';

import '../../core/app_identity.dart';
import '../../core/app_theme.dart';
import '../widgets/maga_brand_mark.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About ${AppIdentity.productName}')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(MashiSpace.page),
          children: [
            const MagaBrandMark(compact: true),
            const SizedBox(height: MashiSpace.compact),
            _AboutSection(
              title: 'Project purpose',
              body:
                  '${AppIdentity.productName} is an Android-first research prototype for exploring domestic travel destinations in Sri Lanka. It helps users compare destinations using their stated trip preferences.',
            ),
            _AboutSection(
              title: 'How recommendations work',
              body:
                  '${AppIdentity.productName} uses deterministic, rule-based matching. It compares budget, activities, travel group, and trip duration, then balances that fit with a social-media-appeal proxy selected using the user’s social-media usage category.',
            ),
            _AboutSection(
              title: 'Methodology summary',
              body: 'The prototype FitScore uses transparent design weights for budget (0.25), activities (0.35), travel group (0.20), and trip duration (0.20). A documented usage-intensity rule selects the balance value, and the final scores are ranked deterministically with stable tie-breaking.',
            ),
            _AboutSection(
              title: 'Research context',
              body: 'The application is research-informed by the approved study on social-media content and destination choice among Sri Lankan youth. The artifact is a prototype for explaining the research context, not a prediction of actual travel behavior.',
            ),
            _AboutSection(
              title: 'Limitations',
              body: 'The social-media-appeal value is a research-informed ordinal prototype proxy based on the approved Appendix A labels. It is not a survey measurement and does not provide live social-media analytics, an influencer-trust score, or a destination-choice accuracy measure. Recommendation accuracy has not been validated against real destination choices. This prototype does not use artificial intelligence or machine learning.',
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatelessWidget {
  const _AboutSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: MashiSpace.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
