import 'package:rail_one/core/storage/local_storage_exception.dart';

sealed class StorageResult<T> {
  const StorageResult();

  bool get isSuccess => this is StorageSuccess<T>;
  bool get isFailure => this is StorageFailure<T>;

  T? get valueOrNull => switch (this) {
        StorageSuccess<T>(:final value) => value,
        StorageFailure<T>() => null,
      };

  LocalStorageException? get errorOrNull => switch (this) {
        StorageSuccess<T>() => null,
        StorageFailure<T>(:final error) => error,
      };
}

final class StorageSuccess<T> extends StorageResult<T> {
  const StorageSuccess(this.value);
  final T value;
}

final class StorageFailure<T> extends StorageResult<T> {
  const StorageFailure(this.error);
  final LocalStorageException error;
}
