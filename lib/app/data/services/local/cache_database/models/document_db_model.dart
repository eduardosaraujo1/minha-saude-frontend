import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_db_model.freezed.dart';
part 'document_db_model.g.dart';

// Note: this object is an object that is stored in the local cache database,
// not used to insert or update data in the local database
@freezed
abstract class DocumentDbModel with _$DocumentDbModel {
  const DocumentDbModel._();

  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  factory DocumentDbModel({
    required String uuid,
    required String titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
    required DateTime cachedAt,
  }) = _DocumentDbModel;

  factory DocumentDbModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentDbModelFromJson(json);

  /// Determines if the cached document is stale based on the provided TTL (time-to-live).
  /// You may override [currentTime] for testing purposes.
  bool isExpired({required Duration ttl, DateTime? currentTime}) {
    final now = currentTime ?? DateTime.now();
    final age = now.difference(cachedAt);
    return age > ttl;
  }
}
