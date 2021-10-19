import 'nano_read_subscribe_callback.dart';

/// Instances of [NanoChannel] can be subscribed to and subscribers are
/// notified when .emit() is called.
class NanoChannel<T> {
  /// A list of callbacks that are called each time .emit() is called,
  /// i.e. the value's subscribers.
  final List<void Function(T, T)> _subscribers;

  /// Creates a new [NanoChannel].
  NanoChannel() : _subscribers = [];

  /// Returns the current number of subscribers.
  int get subscribersCount => _subscribers.length;

  /// Subscribes to this [NanoChannel], which means `callback` is called each
  /// time .emit() is called.
  ///
  /// The function returns a function that when called unsubscribes to the
  /// value, which means `callback` will never be called again by the class.
  void Function() subscribe(NanoReadSubscribeCallback<T> callback) {
    // Add the given callback to the list of subscribers.
    _subscribers.add(callback);

    // Return a callback that can be used to unsubscribe to the variable.
    return () {
      // Remove the given callback.
      // This works since Dart compares the memory addresses of the callbacks
      // and thereby can remove the given callback.
      _subscribers.remove(callback);
    };
  }

  /// Emits a pair of values, which all subscribers will receive.
  void emit(T oldValue, T newValue) {
    // Call each subscriber.
    _subscribers.forEach((callback) {
      // Call callback on the current subscriber with the old and new values.
      callback(oldValue, newValue);
    });
  }
}
