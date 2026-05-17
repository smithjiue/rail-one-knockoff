/// Thrown when local persistence read/write fails.
class StorageException implements Exception {
  const StorageException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() {
    if (cause == null) return 'StorageException: $message';
    return 'StorageException: $message ($cause)';
  }
}
