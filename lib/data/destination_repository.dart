import '../models/destination.dart';

abstract interface class DestinationRepository {
  Future<List<Destination>> getDestinations();
}

void validateDestinationCollection(Iterable<Destination> destinations) {
  final records = destinations.toList(growable: false);
  if (records.isEmpty) {
    throw ArgumentError.value(
      records,
      'destinations',
      'must contain at least one destination',
    );
  }

  final ids = <String>{};
  for (final destination in records) {
    if (!ids.add(destination.id)) {
      throw ArgumentError.value(
        destination.id,
        'destinations',
        'contains a duplicate destination ID',
      );
    }
  }
}
