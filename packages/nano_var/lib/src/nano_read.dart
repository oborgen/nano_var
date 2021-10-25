import 'nano_read_subscribe_callback.dart';

/// Instances of [NanoRead] can be used to access a value of type `T` and
/// it's possible to subscribe to changes to this value.
abstract class NanoRead<T> {
  /// Gets the current value.
  T get value;

  /// Subscribes to changes to the value, which means `callback` is called each
  /// time a change occurs.
  ///
  /// The function returns a function that when called unsubscribes to the
  /// value, which means `callback` will never be called again.
  void Function() subscribe(NanoReadSubscribeCallback<T> callback);
}
