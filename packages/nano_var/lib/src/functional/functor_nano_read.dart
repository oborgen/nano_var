import '../nano_channel.dart';
import '../nano_read.dart';

/// An extension of [NanoRead] that makes [NanoRead] act as a functor,
/// i.e. the method `map` can be called with a callback, which returns a new
/// [NanoRead] instance containing the values returned by the given callback,
/// updated as the original [NanoRead] updates.
extension FunctorNanoRead<T> on NanoRead<T> {
  /// Maps this [NanoRead] with the given callback `mapper` and returns a new
  /// [NanoRead] instance as a result.
  NanoRead<S> map<S>(S Function(T) mapper) {
    // Create and return a _FunctorNanoRead, which handles all logic.
    return _FunctorNanoRead(this, mapper);
  }
}

/// A [NanoRead] instance that handles the functor logic.
class _FunctorNanoRead<T, S> implements NanoRead<S> {
  /// The original [NanoRead] to retrieve arguments to `mapper` from.
  final NanoRead<T> source;

  /// A function used to call each value from `source` with to create new
  /// values.
  final S Function(T) mapper;

  /// A [NanoChannel] to handle all subscriptions to this [_FunctorNanoRead]
  /// instance.
  final NanoChannel<S> _channel;

  /// The unsubscribe callback for `source`.
  ///
  /// The value is null when this [_FunctorNanoRead] has no subscribers.
  void Function()? _unsubscribeSource;

  /// The most recently retrieved value from `source`.
  late T _sourceValue;

  /// The most recently value calculated by `mapper.
  late S _resultValue;

  _FunctorNanoRead(
    this.source,
    this.mapper,
  ) : _channel = NanoChannel() {
    // Initialize _sourceValue with source's current value.
    _sourceValue = source.value;

    // Initialize _resultValue with _sourceValue.
    _resultValue = mapper(_sourceValue);
  }

  @override
  void Function() subscribe(callback) {
    // Call _updateSubscribeToSource to subscribe to source if necessary.
    _updateSubscribeToSource();

    // Make the callback subscribe to _channel.
    final unsubscribe = _channel.subscribe(callback);

    return () {
      // Call unsubscribe to unsubscribe from _channel.
      unsubscribe();

      // Call _updateUnsubscribeToSource to unsubscribe to source if necessary.
      _updateUnsubscribeToSource();
    };
  }

  @override
  S get value {
    // Call _update to update _sourceValue and _resultValue if necessary.
    _update(source.value);

    // Return _resultValue.
    return _resultValue;
  }

  /// Accepts a `sourceValue` and uses it to update _sourceValue and
  /// _resultValue if it differs from _sourceValue.
  void _update(T sourceValue) {
    // Check if source's value has changed.
    if (_sourceValue != sourceValue) {
      // Assign the new value to _sourceValue.
      _sourceValue = sourceValue;

      // Call mapper with the new value and assign the result to _resultValue.
      _resultValue = mapper(sourceValue);
    }
  }

  /// Subscribes to source if necessary.
  void _updateSubscribeToSource() {
    // Check if source already has been subscribed to.
    if (_unsubscribeSource == null) {
      // Call _update to update _sourceValue and _resultValue if necessary.
      // This is needed since source's value might have been updated since this
      // _FlutterNanoRead instance was created and there is no method to get
      // this update otherwise.
      _update(source.value);

      // Subscribe to source as no subscription already exists and assign the
      // unsubscribe function to _unsubscribeSource.
      _unsubscribeSource = source.subscribe((_, sourceValue) {
        // Store the current _resultValue.
        final oldResultValue = _resultValue;

        // Call _update to update _sourceValue and _resultValue.
        _update(sourceValue);

        // Emit a new pair on _channel with the previously stored _resultValue
        // and the newly calculated _resultValue.
        _channel.emit(oldResultValue, _resultValue);
      });
    }
  }

  /// Unsubscribe to source if necessary.
  void _updateUnsubscribeToSource() {
    // Get _unsubscribeSource.
    final unsubscribeSource = _unsubscribeSource;

    // Check if the subscribe count is zero and if _unsubscribeSource is not
    // null.
    if (_channel.subscribersCount == 0 && unsubscribeSource != null) {
      // Unsubscribe to source.
      unsubscribeSource();

      // Assign null to _unsubscribeSource.
      _unsubscribeSource = null;
    }
  }
}
