import 'dart:math';

/// Generates a series of unique random integers between `0` and `max`,
/// which defaults to `100`.
/// The maximum value is increased by one each time `next` is called.
class UniqueRandom {
  int _max;
  final List<int> _previousValues;
  final Random _random;

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
