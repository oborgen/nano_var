import 'package:meta/meta.dart';

/// Instances of [NanoRead] holds a value of type `T` and it's possible to
/// subscribe to changes to this value.
///
/// Changes are triggered by subclasses.
class NanoRead<T> {
  /// The value held by the instance.
  T _value;

  /// A list of callbacks that are called each time a change to the value
  /// occurs, i.e. the value's subscribers.
  final List<void Function(T, T)> subscribers;

  /// Returns the current number of subscribers.
  ///
  /// This getter is only supposed to be used in test cases.
  @visibleForTesting
  int get subscribersCount => subscribers.length;

  NanoRead(T initialValue)
      : _value = initialValue,
        subscribers = [];

  /// Gets the current value.
  T get value {
    return _value;
  }

  /// Subscribes to changes to the value, which means `callback` is called each
  /// time a change occurs.
  ///
  /// The function returns a function that when called unsubscribes to the
  /// value, which means `callback` will never be called again by the class.
  void Function() subscribe(void Function(T oldValue, T newValue) callback) {
    // Add the given callback to the list of subscribers.
    subscribers.add(callback);

    // Return a callback that can be used to unsubscribe to the variable.
    return () {
      // Remove the given callback.
      // This works since Dart compares the memory addresses of the callbacks
      // and thereby can remove the given callback.
      subscribers.remove(callback);
    };
  }

  /// Change the value of the instance and notify all subscribers.
  ///
  /// Nothing is done of `newValue` is equal to `value`.
  @protected
  void change(T newValue) {
    // Store the current value as the old value.
    final oldValue = _value;

    // Check if the new value are the same as the current value.
    // If so, nothing is done.
    if (newValue != oldValue) {
      // Set newValue as the new value.
      _value = newValue;

      // Call each subscriber.
      subscribers.forEach((callback) {
        // Call callback on the current subscriber with the old and new values.
        callback(oldValue, newValue);
      });
    }
  }
}
