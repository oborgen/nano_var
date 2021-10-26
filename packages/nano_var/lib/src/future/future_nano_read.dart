import '../nano_read.dart';
import '../nano_var.dart';
import 'future_nano_read_status.dart';

/// An extension of [Future] that can create a [NanoRead] instance from the
/// [Future] where the created [NanoRead] instance contains the completion
/// status of the [Future].
extension FutureNanoRead<T> on Future<T> {
  NanoRead<FutureNanoReadStatus<T>> get nanoRead {
    return _FutureNanoRead(this);
  }
}

/// A [NanoRead] instance that handles the future logic.
class _FutureNanoRead<T> extends NanoRead<FutureNanoReadStatus<T>> {
  /// A [NanoVar] instance containing the status of the [Future].
  final NanoVar<FutureNanoReadStatus<T>> _status;

  _FutureNanoRead(Future<T> future)
      : _status = NanoVar(UncompletedNanoReadStatus()) {
    // Call _handleFuture with the given Future.
    _handleFuture(future);
  }

  /// Awaits the given [Future] and updates `_status` accordingly.
  Future<void> _handleFuture(Future<T> future) async {
    try {
      // Await future and store the resulting value.
      final value = await future;

      // Report that future has succeeded.
      _status.value = SucceessNanoReadStatus(value);
    } catch (error, stackTrace) {
      // Catch any error from future and report that an error has occured.
      _status.value = FailNanoReadStatus(error, stackTrace);
    }
  }

  @override
  void Function() subscribe(callback) {
    // Forward the call to _status.subscribe.
    return _status.subscribe(callback);
  }

  @override
  FutureNanoReadStatus<T> get value {
    // Forward the call to _status.value.
    return _status.value;
  }
}
