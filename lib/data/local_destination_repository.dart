import '../models/destination.dart';
import 'destination_repository.dart';
import 'destination_seed.dart';

class LocalDestinationRepository implements DestinationRepository {
  LocalDestinationRepository({List<Destination>? destinations})
    : _destinations = List<Destination>.unmodifiable(
        destinations ?? destinationSeed,
      ) {
    validateDestinationCollection(_destinations);
  }

  final List<Destination> _destinations;

  @override
  Future<List<Destination>> getDestinations() async => _destinations;
}
