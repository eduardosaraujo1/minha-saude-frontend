import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_db_model.freezed.dart';
part 'document_db_model.g.dart';

// Note: this object is an object that is stored in the local cache database,
// not used to insert or update data in the local database
@freezed
sealed class DocumentDbModel with _$DocumentDbModel {
  DocumentDbModel._({DateTime? cachedAt})
    : cachedAt = cachedAt ?? DateTime.now();

  // ignore: invalid_annotation_target
  @JsonSerializable(fieldRename: FieldRename.snake)
  factory DocumentDbModel({
    required String uuid,
    String? titulo,
    String? paciente,
    String? medico,
    String? tipo,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
    DateTime? cachedAt,
  }) = _DocumentDbModel;

  @override
  final DateTime cachedAt;

  factory DocumentDbModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentDbModelFromJson(json);

  bool isStale({required Duration ttl, DateTime? timeStamp}) {
    final now = timeStamp ?? DateTime.now();
    final age = now.difference(cachedAt);
    return age > ttl;
  }
}
