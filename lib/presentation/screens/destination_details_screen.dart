import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/destination_repository.dart';
import '../../models/destination.dart';

class DestinationDetailsScreen extends StatefulWidget {
  const DestinationDetailsScreen({
    this.destinationId,
    required this.repository,
    super.key,
  });

  final String? destinationId;
  final DestinationRepository repository;

  @override
  State<DestinationDetailsScreen> createState() =>
      _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  late final Future<Destination?> _destinationFuture;

  @override
  void initState() {
    super.initState();
    _destinationFuture = _loadDestination();
  }

  Future<Destination?> _loadDestination() async {
    final destinationId = widget.destinationId;
    if (destinationId == null) {
      return null;
    }

    final destinations = await widget.repository.getDestinations();
    for (final destination in destinations) {
      if (destination.id == destinationId) {
        return destination;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destination details')),
      body: SafeArea(
        child: FutureBuilder<Destination?>(
          future: _destinationFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  label: 'Loading destination details',
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return const _DetailsMessage(
                title: 'Destination details unavailable',
                message: 'The approved destination record could not be loaded. Please return to the results and try again.',
              );
            }

            final destination = snapshot.data;
            if (destination == null) {
              return const _DetailsMessage(
                title: 'Destination not found',
                message: 'This destination is not available in the approved local repository.',
              );
            }
            return _DestinationDetails(destination: destination);
          },
        ),
      ),
    );
  }
}

class _DestinationDetails extends StatelessWidget {
  const _DestinationDetails({required this.destination});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(MashiSpace.page),
      children: [
        Text(
          destination.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          destination.province,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: MashiSpace.section),
        _DetailsSection(
          title: 'About this destination',
          body: destination.description,
        ),
        _DetailsSection(
          title: 'Activities',
          body: _sortedLabels(
            destination.activities,
            (activity) => activity.label,
          ),
        ),
        _DetailsSection(
          title: 'Budget level',
          body: destination.budgetLevel.label,
        ),
        _DetailsSection(
          title: 'Suitable travel groups',
          body: _sortedLabels(
            destination.suitableGroups,
            (group) => group.label,
          ),
        ),
        _DetailsSection(
          title: 'Trip duration guidance',
          body: _sortedLabels(
            destination.durationOptions,
            (duration) => duration.label,
          ),
        ),
        _DetailsSection(title: 'Best season', body: destination.bestSeason),
        _DetailsSection(
          title: 'Social-media appeal proxy',
          body:
              '${destination.socialMediaAppealLevel.label} (${destination.socialMediaAppealScore.toStringAsFixed(3)}). This is a research-informed ordinal prototype proxy and does not provide live social-media analytics or a measured destination-trust score.',
        ),
        _DetailsSection(title: 'Source note', body: destination.sourceNote),
      ],
    );
  }
}

String _sortedLabels<T>(Iterable<T> values, String Function(T) labelOf) {
  final labels = values.map(labelOf).toList()..sort();
  return labels.join(', ');
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.title, required this.body});

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

class _DetailsMessage extends StatelessWidget {
  const _DetailsMessage({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(MashiSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: MashiSpace.compact),
          Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
