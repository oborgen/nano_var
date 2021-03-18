import 'dart:math';

/// Generates a series of unique random integers between `0` and `max`,
/// which defaults to `100`.
/// The maximum value is increased by one each time `next` is called.
class UniqueRandom {
  /// The current maximum value.
  int _max;

  /// The values that already has been generated.
  final List<int> _previousValues;

  /// A [Random] instance used to generate values.
  final Random _random;

  /// Creates a [UniqueRandom] with an initial maximum value `max`, which
  /// defaults to `100`.
  UniqueRandom([int max = 100])
      : _max = max,
        _previousValues = [],
        _random = Random();

  /// Gets the next value in the series.
  int next() {
    while (true) {
      // Generate a random integer.
      final value = _random.nextInt(_max);

      // Check if the value has previously been generated.
      // The operation is retried if that's the case.
      if (!_previousValues.contains(value)) {
        // Add value to the list of previously generated values.
        _previousValues.add(value);

        // Increment the maximum value.
        _max++;

        // Return the generated value.
        return value;
      }
    }
  }
}
