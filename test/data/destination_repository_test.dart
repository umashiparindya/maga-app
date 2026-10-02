import 'package:flutter_test/flutter_test.dart';
import 'package:mashi_smoke/data/destination_repository.dart';
import 'package:mashi_smoke/data/destination_seed.dart';
import 'package:mashi_smoke/data/local_destination_repository.dart';
import 'package:mashi_smoke/models/enums.dart';

void main() {
  group('LocalDestinationRepository', () {
    test('loads the controlled seed data successfully', () async {
      final repository = LocalDestinationRepository();
      final destinations = await repository.getDestinations();

      expect(destinations, hasLength(12));
      expect(destinations, equals(destinationSeed));
      expect(destinations.first.id, 'hikkaduwa');
      expect(destinations.last.id, 'yala-national-park');
    });

    test('preserves stable seed ordering across reads', () async {
      final destinations = await LocalDestinationRepository().getDestinations();
      final secondRead = await LocalDestinationRepository().getDestinations();

      expect(
        destinations.map((destination) => destination.id).toList(),
        secondRead.map((destination) => destination.id).toList(),
      );
    });

    test('rejects duplicate destination IDs', () {
      final duplicate = [destinationSeed.first, destinationSeed.first];

      expect(
        () => LocalDestinationRepository(destinations: duplicate),
        throwsArgumentError,
      );
    });

    test('rejects an empty destination collection', () {
      expect(
        () => LocalDestinationRepository(destinations: const []),
        throwsArgumentError,
      );
    });

    test('rejects duplicate IDs through the shared validator', () {
      expect(
        () => validateDestinationCollection([
          destinationSeed[0],
          destinationSeed[0],
        ]),
        throwsArgumentError,
      );
    });
  });

  group('seed validation', () {
    test('every record has complete typed fields and bounded proxy values', () {
      for (final destination in destinationSeed) {
        expect(destination.id, isNotEmpty);
        expect(destination.name, isNotEmpty);
        expect(destination.province, isNotEmpty);
        expect(destination.description, isNotEmpty);
        expect(destination.activities, isNotEmpty);
        expect(destination.suitableGroups, isNotEmpty);
        expect(destination.durationOptions, isNotEmpty);
        expect(destination.bestSeason, isNotEmpty);
        expect(destination.sourceNote, contains('Appendix A record'));
        expect(destination.sourceNote, contains('[A1]-[A12]'));
        expect(destination.socialMediaAppealScore, inInclusiveRange(0.0, 1.0));
        expect(
          destination.socialMediaAppealScore,
          destination.socialMediaAppealLevel.score,
        );
      }
    });

    test('uses only approved group values and mapped source labels', () {
      final ids = destinationSeed.map((destination) => destination.id).toSet();
      expect(ids, hasLength(destinationSeed.length));
      expect(
        destinationSeed.every(
          (destination) =>
              destination.suitableGroups.every(TravelGroup.values.contains),
        ),
        isTrue,
      );
      expect(
        destinationSeed.every(
          (destination) =>
              destination.socialMediaAppealLevel ==
                  SocialMediaAppealLevel.low ||
              destination.socialMediaAppealLevel ==
                  SocialMediaAppealLevel.medium ||
              destination.socialMediaAppealLevel ==
                  SocialMediaAppealLevel.high ||
              destination.socialMediaAppealLevel ==
                  SocialMediaAppealLevel.veryHigh,
        ),
        isTrue,
      );
    });

    test('covers the required MVP activity categories', () {
      final activities = destinationSeed
          .expand((destination) => destination.activities)
          .toSet();

      expect(
        activities,
        containsAll([
          ActivityCategory.beach,
          ActivityCategory.culture,
          ActivityCategory.hillCountry,
          ActivityCategory.wildlife,
          ActivityCategory.adventure,
          ActivityCategory.urban,
        ]),
      );
    });
  });
}
