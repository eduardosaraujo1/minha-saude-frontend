import 'package:freezed_annotation/freezed_annotation.dart';

part 'cached_element.freezed.dart';

@freezed
sealed class CachedElement<T> with _$CachedElement<T> {
  static const Duration defaultMaxAge = Duration(hours: 1);

  CachedElement._({DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  factory CachedElement(
    T data, {
    DateTime? timestamp,
    @Default(false) bool forceStale,
  }) = _CachedElement<T>;

  @override
  final DateTime timestamp;

  bool isStale(Duration? maxAge) {
    final age = DateTime.now().difference(timestamp);
    return forceStale || age > (maxAge ?? defaultMaxAge);
  }
}
