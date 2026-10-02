String requireNonBlank(String value, String fieldName) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    throw ArgumentError.value(value, fieldName, 'must not be empty');
  }
  return trimmed;
}

Set<T> requireNonEmptySet<T>(Set<T> values, String fieldName) {
  if (values.isEmpty) {
    throw ArgumentError.value(values, fieldName, 'must not be empty');
  }
  return Set<T>.unmodifiable(values);
}

double requireScoreInRange(double value, String fieldName) {
  if (!value.isFinite || value < 0.0 || value > 1.0) {
    throw ArgumentError.value(
      value,
      fieldName,
      'must be finite and between 0 and 1',
    );
  }
  return value;
}

double requireScoreMatching(double value, double expected, String fieldName) {
  requireScoreInRange(value, fieldName);
  if (value != expected) {
    throw ArgumentError('$fieldName must equal the normalized level score');
  }
  return value;
}
