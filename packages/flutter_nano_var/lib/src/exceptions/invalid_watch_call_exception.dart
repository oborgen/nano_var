/// Thrown if `watch` is called after `build` has returned.
class InvalidWatchCallException implements Exception {
  /// Creates an [InvalidWatchCallException].
  const InvalidWatchCallException();

  String toString() {
    return "watch() cannot be called after build() has returned.";
  }
}
