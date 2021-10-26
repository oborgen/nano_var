import '../nano_channel.dart';
import '../nano_read.dart';

/// An extension of [NanoRead] that makes [NanoRead] act as a monad,
/// i.e. the method `binder` can be called with a callback, which returns a new
/// [NanoRead] instance containing the values returned by the [NanoRead]
/// instance most recently returned by `binder`.
extension MonadNanoRead<T> on NanoRead<T> {
  /// Binds this [NanoRead] with the given callback `binder` and returns a new
  /// [NanoRead] instance as a result.
  NanoRead<S> bind<S>(NanoRead<S> Function(T) binder) {
    // Create and return a _MonadNanoRead, which handles all logic.
    return _MonadNanoRead(this, binder);
  }
}

/// A [NanoRead] instance that handles the monad logic.
class _MonadNanoRead<T, S> implements NanoRead<S> {
  /// The original [NanoRead] to retrieve arguments to `binder` from.
  final NanoRead<T> outerSource;

  /// A function used to call each value from `outerSource` with to get a
  /// second [NanoRead] instance to finally get values from.
  final NanoRead<S> Function(T) binder;

  /// A [NanoChannel] to handle all subscriptions to this [_MonadNanoRead]
  /// instance.
  final NanoChannel<S> _channel;

  /// The unsubscribe callback for `outerSource`.
  ///
  /// The value is null when this [_MonadNanoRead] has no subscribers.
  void Function()? _unsubscribeOuterSource;

  /// The unsubscribe callback for `innerSource`.
  ///
  /// The value is null when this [_MonadNanoRead] has no subscribers.
  void Function()? _unsubscribeInnerSource;

  /// The most recently retrieved value from `outerSource`.
  late T _outerSourceValue;

  /// The most recently returned [NanoRead] instance from `mapper`.
  late NanoRead<S> _innerSource;

  /// The most recently retrieved value from `_innerSource`.
  late S _innerSourceValue;

  _MonadNanoRead(
    this.outerSource,
    this.binder,
  ) : _channel = NanoChannel() {
    // Initialize _outerSourceValue with outerSource's current value.
    _outerSourceValue = outerSource.value;

    // Initialize _innerSource with _outerSourceValue.
    _innerSource = binder(_outerSourceValue);

    // Initialize _innerSourceValue with _innerSource's current value.
    _innerSourceValue = _innerSource.value;
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
  S get value {
    // Call _update to update any changed value.
    _update();

    // Return _innerSourceValue.
    return _innerSourceValue;
  }

  /// Updates any changed value.
  void _update() {
    // Call _updateOuter to update _outerSourceValue _innerSource and
    // _innerSourceValue if necessary.
    if (!_updateOuter(outerSource.value)) {
      // Call _updateOuter to update _innerSourceValue if necessary but only do
      // this if _updateOuter has not updated anything, as _innerSourceValue is
      // then updated as well.
      _updateInner(_innerSource.value);
    }
  }

  /// Accepts a `outerSourceValue` and uses it to update _outerSourceValue,
  /// _innerSource and _innerSourceValue if outerSourceValue differs from
  /// _outerSourceValue.
  bool _updateOuter(T outerSourceValue) {
    // Check if outerSourceValue has changed.
    if (_outerSourceValue != outerSourceValue) {
      // Assign outerSourceValue to _outerSourceValue.
      _outerSourceValue = outerSourceValue;

      // Get _unsubscribeInnerSource.
      final unsubscribeInnerSource = _unsubscribeInnerSource;

      // Declare a variable for if a subscription to _innerSource exists.
      bool subscribedToInnerSource;

      // Check if _unsubscribeInnerSource is not null.
      if (unsubscribeInnerSource != null) {
        // Unsubscribe to _innerSource.
        unsubscribeInnerSource();

        // Assign null to _unsubscribeInnerSource.
        _unsubscribeInnerSource = null;

        // Report that a subscription used to exist.
        subscribedToInnerSource = true;
      } else {
        // Report that no subscription used to exist.
        subscribedToInnerSource = false;
      }

      // Call binder with the new _outerSourceValue and assign the result to
      // _innerSource.
      _innerSource = binder(_outerSourceValue);

      // Update _innerSourceValue with the new _innerSource's value.
      _innerSourceValue = _innerSource.value;

      // Check if a subscription to the previous _innerSource used to exist.
      if (subscribedToInnerSource) {
        // Call _rawSubscribeToInnerSource to subscribe to the new
        // _innerSource.
        _rawSubscribeToInnerSource();
      }

      // Return true to indicate that _outerSourceValue, _innerSource and
      // _innerSourceValue has changed.
      return true;
    } else {
      // Return false to indicate that no value has changed.
      return false;
    }
  }

  /// Accepts a `innerSourceValue` and uses it to update _innerSourceValue if
  /// `innerSourceValue` differs from _innerSourceValue.
  void _updateInner(S innerSourceValue) {
    // Check if innerSourceValue has changed.
    if (_innerSourceValue != innerSourceValue) {
      // Assign innerSourceValue to _innerSourceValue.
      _innerSourceValue = innerSourceValue;
    }
  }

  /// Subscribes to the sources if necessary.
  void _updateSubscribeToSource() {
    // Check if the sources already have been subscribed to.
    if (_unsubscribeOuterSource == null && _unsubscribeInnerSource == null) {
      // Call _update to update any changed value.
      // This is needed since the source values might have been updated since
      // this _ApplicativeNanoRead instance was created and there is no method
      // to get these updates otherwise.
      _update();

      // Subscribe to outerSource and assign the unsubscribe function to
      // _unsubscribeOuterSource.
      _unsubscribeOuterSource = outerSource.subscribe((_, outerSourceValue) {
        // Store the current _innerSourceValue.
        final oldInnerSourceValue = _innerSourceValue;

        // Call _updateOuter to update _outerSourceValue _innerSource and
        // _innerSourceValue if necessary.
        _updateOuter(outerSourceValue);

        // Emit a new pair on _channel with the previously stored
        // _innerSourceValue and the newly calculated _innerSourceValue.
        _channel.emit(oldInnerSourceValue, _innerSourceValue);
      });

      // Subscribe to _innerSource.
      _rawSubscribeToInnerSource();
    }
  }

  /// Subscribes to _innerSource.
  void _rawSubscribeToInnerSource() {
    // Subscribe to _innerSource and assign the unsubscribe function to
    // _unsubscribeInnerSource.
    _unsubscribeInnerSource = _innerSource.subscribe((_, innerSourceValue) {
      // Store the current _innerSourceValue.
      final oldInnerSourceValue = _innerSourceValue;

      // Call _updateOuter to update _innerSourceValue if necessary.
      _updateInner(innerSourceValue);

      // Emit a new pair on _channel with the previously stored
      // _innerSourceValue and the newly calculated _innerSourceValue.
      _channel.emit(oldInnerSourceValue, _innerSourceValue);
    });
  }

  /// Unsubscribe to the sources if necessary.
  void _updateUnsubscribeToSource() {
    // Get _unsubscribeOuterSource.
    final unsubscribeOuterSource = _unsubscribeOuterSource;

    // Get _unsubscribeInnerSource.
    final unsubscribeInnerSource = _unsubscribeInnerSource;

    // Check if the subscribe count is zero and if _unsubscribeOuterSource and
    // unsubscribeInnerSource are not null.
    if (_channel.subscribersCount == 0 &&
        unsubscribeOuterSource != null &&
        unsubscribeInnerSource != null) {
      // Unsubscribe to outerSource.
      unsubscribeOuterSource();

      // Unsubscribe to innerSource.
      unsubscribeInnerSource();

      // Assign null to _unsubscribeOuterSource.
      _unsubscribeOuterSource = null;

      // Assign null to _unsubscribeInnerSource.
      _unsubscribeInnerSource = null;
    }
  }
}
