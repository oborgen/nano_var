/// Thrown if `watch` is called after [NanoObsWidget.build] or
/// [NanoObs.builder] has returned.
class InvalidWatchCallException implements Exception {
  /// Creates an [InvalidWatchCallException].
  const InvalidWatchCallException();

  /// Creates a string representation of the [InvalidWatchCallException].
  String toString() {
    return "watch() cannot be called after build() has returned.";
  }
}
