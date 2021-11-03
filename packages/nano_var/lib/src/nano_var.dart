import 'package:meta/meta.dart';

import 'nano_channel.dart';
import 'nano_read.dart';
import 'nano_read_subscribe_callback.dart';

/// Instances of this class holds a value of type [T] and it's possible to
/// subscribe to changes to this value.
///
/// The value can be both get and set.
class NanoVar<T> implements NanoRead<T> {
  /// The value held by the instance.
  T _value;

  /// A NanoChannel that handles subscriptions.
  final NanoChannel<T> _channel;

  /// Returns the current number of subscribers.
  ///
  /// This getter is only supposed to be used in test cases.
  @visibleForTesting
  int get subscribersCount => _channel.subscribersCount;

  /// Creates a new [NanoVar] with a given [initialValue].
  NanoVar(T initialValue)
      : _value = initialValue,
        _channel = NanoChannel();

  @override
  T get value {
    return _value;
  }

  @override
  void Function() subscribe(NanoReadSubscribeCallback<T> callback) {
    // Add the subscriber to _channel.
    return _channel.subscribe(callback);
  }

  /// Sets the current value and notifies all subscribers.
  set value(T newValue) {
    // Store the current value as the old value.
    final oldValue = _value;

    // Check if the new value are the same as the current value.
    // If so, nothing is done.
    if (newValue != oldValue) {
      // Set newValue as the new value.
      _value = newValue;

      // Emit the value pair to the channel.
      _channel.emit(oldValue, newValue);
    }
  }
}
