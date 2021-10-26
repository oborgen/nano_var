/// A class describing the current status of a [NanoRead] instance produced by
/// [FutureNanoRead].
abstract class FutureNanoReadStatus<T> {
  const FutureNanoReadStatus();

  /// Calls the callback corresponding to the status and returns a value from
  /// the callback.
  S status<S>({
    required S Function() uncompleted,
    required S Function(T) success,
    required S Function(Object, StackTrace) fail,
  });
}

/// A class describing that a [Future] has not been completed.
class UncompletedNanoReadStatus<T> extends FutureNanoReadStatus<T> {
  const UncompletedNanoReadStatus();

  S status<S>({
    required uncompleted,
    required success,
    required fail,
  }) {
    return uncompleted();
  }

  @override
  operator ==(other) =>
      other.runtimeType == _typeof<UncompletedNanoReadStatus<T>>();

  int get hashCode => runtimeType.hashCode;
}

/// A class describing that a [Future] has completed successfully.
class SucceessNanoReadStatus<T> extends FutureNanoReadStatus<T> {
  final T value;

  const SucceessNanoReadStatus(
    this.value,
  );

  S status<S>({
    required uncompleted,
    required success,
    required fail,
  }) {
    return success(value);
  }

  @override
  operator ==(other) =>
      other.runtimeType == _typeof<SucceessNanoReadStatus<T>>() &&
      value == (other as SucceessNanoReadStatus<T>).value;

  int get hashCode => runtimeType.hashCode ^ value.hashCode;
}

/// A class describing that a [Future] has completed by throwing an error.
class FailNanoReadStatus<T> extends FutureNanoReadStatus<T> {
  final Object error;
  final StackTrace stackTrace;

  const FailNanoReadStatus(
    this.error,
    this.stackTrace,
  );

  S status<S>({
    required uncompleted,
    required success,
    required fail,
  }) {
    return fail(error, stackTrace);
  }

  @override
  operator ==(other) =>
      other.runtimeType == _typeof<FailNanoReadStatus<T>>() &&
      error == (other as FailNanoReadStatus<T>).error &&
      stackTrace == other.stackTrace;

  int get hashCode =>
      runtimeType.hashCode ^ error.hashCode ^ stackTrace.hashCode;
}

/// Returns the [Type] value of the given generic type.
Type _typeof<T>() {
  return T;
}
