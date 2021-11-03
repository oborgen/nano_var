import '../nano_channel.dart';
import '../nano_read.dart';

/// An extension of [NanoRead] that makes [NanoRead] act as an applicative,
/// i.e. the method [liftA2] can be called with a callback, which returns a new
/// [NanoRead] instance containing the values returned by the given callback,
/// updated as the original [NanoRead] instances updates.
extension ApplicativeNanoRead<T> on NanoRead<T> {
  /// Lifts this [NanoRead] with the given callback [lifter] and another
  /// [NanoRead] and returns a new [NanoRead] instance as a result.
  NanoRead<U> liftA2<S, U>(U Function(T, S) lifter, NanoRead<S> other) {
    // Create and return an _ApplicativeNanoRead, which handles all logic.
    return _ApplicativeNanoRead(this, other, lifter);
  }
}

/// A [NanoRead] instance that handles the applicative logic.
class _ApplicativeNanoRead<T, S, U> implements NanoRead<U> {
  /// The first original [NanoRead] to retrieve arguments to [lifter] from.
  final NanoRead<T> source1;

  /// The second original [NanoRead] to retrieve arguments to [lifter] from.
  final NanoRead<S> source2;

  /// A function used to call each value from [source1] and [source2] with to
  /// create new values.
  final U Function(T, S) lifter;

  /// A [NanoChannel] to handle all subscriptions to this [_FunctorNanoRead]
  /// instance.
  final NanoChannel<U> _channel;

  /// The unsubscribe callback for [source1].
  ///
  /// The value is null when this [_ApplicativeNanoRead] has no subscribers.
  void Function()? _unsubscribeSource1;

  /// The unsubscribe callback for [source2].
  ///
  /// The value is null when this [_ApplicativeNanoRead] has no subscribers.
  void Function()? _unsubscribeSource2;

  /// The most recently retrieved value from [source1].
  late T _source1Value;

  /// The most recently retrieved value from [source2].
  late S _source2Value;

  /// The most recently value calculated by [lifter].
  late U _resultValue;

  /// Creates a new [_ApplicativeNanoRead] that handles the applicative logic
  /// of [source1] and [source2] using [lifter].
  _ApplicativeNanoRead(
    this.source1,
    this.source2,
    this.lifter,
  ) : _channel = NanoChannel() {
    // Initialize _source1Value with source1's current value.
    _source1Value = source1.value;

    // Initialize _source2Value with source2's current value.
    _source2Value = source2.value;

    // Initialize _resultValue with _sourceValue1 and _sourceValue1.
    _resultValue = lifter(_source1Value, _source2Value);
  }

  @override
  void Function() subscribe(callback) {
    // Call _updateSubscribeToSource to subscribe to the sources if necessary.
    _updateSubscribeToSource();

    // Make the callback subscribe to _channel.
    final unsubscribe = _channel.subscribe(callback);

    return () {
      // Call unsubscribe to unsubscribe from _channel.
      unsubscribe();

      // Call _updateUnsubscribeToSource to unsubscribe to the sources if
      // necessary.
      _updateUnsubscribeToSource();
    };
  }

  @override
  U get value {
    // Call _update to update _source1Value, _source2Value and _resultValue if
    // necessary.
    _update(source1.value, source2.value);

    // Return _resultValue.
    return _resultValue;
  }

  /// Accepts a [source1Value] and [source2Value] and uses them to update
  /// [_source1Value], [_source2Value] and [_resultValue] if [source1Value]
  /// differs from [_source1Value] or [source2Value] differs from
  /// [_source2Value].
  void _update(T source1Value, S source2Value) {
    // Check if any of the values have changed.
    if (_source1Value != source1Value || _source2Value != source2Value) {
      // Assign source1Value to _source1Value.
      _source1Value = source1Value;

      // Assign source2Value to _source2Value.
      _source2Value = source2Value;

      // Call lifter with the new values and assign the result to _resultValue.
      _resultValue = lifter(source1Value, source2Value);
    }
  }

  /// Subscribes to the sources if necessary.
  void _updateSubscribeToSource() {
    // Check if the sources already have been subscribed to.
    if (_unsubscribeSource1 == null && _unsubscribeSource2 == null) {
      // Call _update to update _source1Value, _source2Value and _resultValue if
      // necessary.
      // This is needed since the source values might have been updated since
      // this _ApplicativeNanoRead instance was created and there is no method
      // to get these updates otherwise.
      _update(source1.value, source2.value);

      // Subscribe to source1 and assign the unsubscribe function to
      // _unsubscribeSource1.
      _unsubscribeSource1 = source1.subscribe((_, source1Value) {
        // Store the current _resultValue.
        final oldResultValue = _resultValue;

        // Call _update to update _source1Value, _source2Value and _resultValue.
        _update(source1Value, _source2Value);

        // Emit a new pair on _channel with the previously stored _resultValue
        // and the newly calculated _resultValue.
        _channel.emit(oldResultValue, _resultValue);
      });

      // Subscribe to source2 and assign the unsubscribe function to
      // _unsubscribeSource2.
      _unsubscribeSource2 = source2.subscribe((_, source2Value) {
        // Store the current _resultValue.
        final oldResultValue = _resultValue;

        // Call _update to update _source1Value, _source2Value and _resultValue.
        _update(_source1Value, source2Value);

        // Emit a new pair on _channel with the previously stored _resultValue
        // and the newly calculated _resultValue.
        _channel.emit(oldResultValue, _resultValue);
      });
    }
  }

  /// Unsubscribe to the sources if necessary.
  void _updateUnsubscribeToSource() {
    // Get _unsubscribeSource1.
    final unsubscribeSource1 = _unsubscribeSource1;

    // Get _unsubscribeSource2.
    final unsubscribeSource2 = _unsubscribeSource2;

    // Check if the subscribe count is zero and if _unsubscribeSource1 and
    // _unsubscribeSource1 are not null.
    if (_channel.subscribersCount == 0 &&
        unsubscribeSource1 != null &&
        unsubscribeSource2 != null) {
      // Unsubscribe to source1.
      unsubscribeSource1();

      // Unsubscribe to source2.
      unsubscribeSource2();

      // Assign null to _unsubscribeSource1.
      _unsubscribeSource1 = null;

      // Assign null to _unsubscribeSource2.
      _unsubscribeSource2 = null;
    }
  }
}
