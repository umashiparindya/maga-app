enum BudgetLevel {
  low,
  medium,
  high;

  factory BudgetLevel.fromValue(String value) {
    final normalized = value.trim().toLowerCase().replaceFirst(
      RegExp(r'\s*\(est\.\)$'),
      '',
    );
    return switch (normalized) {
      'low' => BudgetLevel.low,
      'low-mid' => BudgetLevel.medium,
      'mid' => BudgetLevel.medium,
      'mid-high' => BudgetLevel.high,
      'medium' => BudgetLevel.medium,
      'high' => BudgetLevel.high,
      _ => throw FormatException('Invalid budget level: $value'),
    };
  }

  String get label => switch (this) {
    BudgetLevel.low => 'Low',
    BudgetLevel.medium => 'Medium',
    BudgetLevel.high => 'High',
  };
}

enum SocialMediaAppealLevel {
  low,
  medium,
  high,
  veryHigh;

  factory SocialMediaAppealLevel.fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'low' => SocialMediaAppealLevel.low,
      'medium' => SocialMediaAppealLevel.medium,
      'high' => SocialMediaAppealLevel.high,
      'very high' => SocialMediaAppealLevel.veryHigh,
      _ => throw FormatException('Invalid social media appeal level: $value'),
    };
  }

  String get label => switch (this) {
    SocialMediaAppealLevel.low => 'Low',
    SocialMediaAppealLevel.medium => 'Medium',
    SocialMediaAppealLevel.high => 'High',
    SocialMediaAppealLevel.veryHigh => 'Very High',
  };

  double get score => switch (this) {
    SocialMediaAppealLevel.low => 0.000,
    SocialMediaAppealLevel.medium => 0.333,
    SocialMediaAppealLevel.high => 0.667,
    SocialMediaAppealLevel.veryHigh => 1.000,
  };
}

enum TravelGroup {
  solo,
  friends,
  family,
  partner;

  factory TravelGroup.fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'solo' => TravelGroup.solo,
      'friends' => TravelGroup.friends,
      'family' => TravelGroup.family,
      'partner' => TravelGroup.partner,
      _ => throw FormatException('Invalid travel group: $value'),
    };
  }

  String get label => switch (this) {
    TravelGroup.solo => 'Solo',
    TravelGroup.friends => 'Friends',
    TravelGroup.family => 'Family',
    TravelGroup.partner => 'Partner',
  };
}

Set<TravelGroup> travelGroupsFromValue(String value) {
  final normalized = value.trim().toLowerCase();
  return switch (normalized) {
    'all groups' => const {
      TravelGroup.solo,
      TravelGroup.friends,
      TravelGroup.family,
      TravelGroup.partner,
    },
    'couples' => const {TravelGroup.partner},
    'friends' => const {TravelGroup.friends},
    'solo' => const {TravelGroup.solo},
    'friends / couples' => const {TravelGroup.friends, TravelGroup.partner},
    'friends / solo' => const {TravelGroup.friends, TravelGroup.solo},
    _ => throw FormatException('Invalid or unsupported travel group: $value'),
  };
}

enum TripDuration {
  short,
  medium,
  long;

  factory TripDuration.fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'short' => TripDuration.short,
      'medium' => TripDuration.medium,
      'long' => TripDuration.long,
      _ => throw FormatException('Invalid trip duration: $value'),
    };
  }

  factory TripDuration.fromSourceDuration(String value) {
    final normalized = value.trim().toLowerCase().replaceAll('–', '-');
    if (normalized.startsWith('half day') ||
        normalized.startsWith('1 day') ||
        normalized.startsWith('1-2 days')) {
      return TripDuration.short;
    }
    if (normalized.startsWith('2-3 days') ||
        normalized.startsWith('2-4 days') ||
        normalized.startsWith('3-5 days')) {
      return TripDuration.medium;
    }
    if (normalized.startsWith('3-7 days')) {
      return TripDuration.long;
    }
    throw FormatException('Invalid or unsupported source duration: $value');
  }

  String get label => switch (this) {
    TripDuration.short => 'Short',
    TripDuration.medium => 'Medium',
    TripDuration.long => 'Long',
  };
}

enum SocialMediaUsageIntensity {
  lessThanOneHour,
  oneToTwoHours,
  twoToFourHours,
  moreThanFourHours;

  factory SocialMediaUsageIntensity.fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'less than 1 hour per day' => SocialMediaUsageIntensity.lessThanOneHour,
      '1 to 2 hours' => SocialMediaUsageIntensity.oneToTwoHours,
      '2 to 4 hours' => SocialMediaUsageIntensity.twoToFourHours,
      'more than 4 hours' => SocialMediaUsageIntensity.moreThanFourHours,
      _ => throw FormatException(
        'Invalid social media usage intensity: $value',
      ),
    };
  }

  String get label => switch (this) {
    SocialMediaUsageIntensity.lessThanOneHour => 'Less than 1 hour per day',
    SocialMediaUsageIntensity.oneToTwoHours => '1 to 2 hours',
    SocialMediaUsageIntensity.twoToFourHours => '2 to 4 hours',
    SocialMediaUsageIntensity.moreThanFourHours => 'More than 4 hours',
  };
}

enum ActivityCategory {
  beach,
  culture,
  hillCountry,
  adventure,
  wildlife,
  nature,
  urban,
  waterSports,
  photography,
  wellness;

  factory ActivityCategory.fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'beach' => ActivityCategory.beach,
      'culture' => ActivityCategory.culture,
      'hill country' => ActivityCategory.hillCountry,
      'adventure' => ActivityCategory.adventure,
      'wildlife' => ActivityCategory.wildlife,
      'nature' => ActivityCategory.nature,
      'urban' => ActivityCategory.urban,
      'water sports' => ActivityCategory.waterSports,
      'photography' => ActivityCategory.photography,
      'wellness' => ActivityCategory.wellness,
      _ => throw FormatException('Invalid activity category: $value'),
    };
  }

  String get label => switch (this) {
    ActivityCategory.beach => 'Beach',
    ActivityCategory.culture => 'Culture',
    ActivityCategory.hillCountry => 'Hill country',
    ActivityCategory.adventure => 'Adventure',
    ActivityCategory.wildlife => 'Wildlife',
    ActivityCategory.nature => 'Nature',
    ActivityCategory.urban => 'Urban',
    ActivityCategory.waterSports => 'Water sports',
    ActivityCategory.photography => 'Photography',
    ActivityCategory.wellness => 'Wellness',
  };
}
