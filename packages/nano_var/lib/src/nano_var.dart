import 'nano_read.dart';

/// Instances of this class holds a value of type `T` and it's possible to
/// subscribe to changes to this value.
///
/// The value can be both get and set.
class NanoVar<T> extends NanoRead<T> {
  NanoVar(T initialValue) : super(initialValue);

  /// Sets the current value and notifies all subscribers.
  set value(T newValue) {
    // Call change to set the given value.
    change(newValue);
  }
}
