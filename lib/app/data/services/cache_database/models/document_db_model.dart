import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_db_model.freezed.dart';
part 'document_db_model.g.dart';

// Note: this object is an object that is stored in the local cache database,
// not used to insert or update data in the local database
@freezed
sealed class DocumentDbModel with _$DocumentDbModel {
  DocumentDbModel._({DateTime? cachedAt})
    : cachedAt = cachedAt ?? DateTime.now();

  factory DocumentDbModel({
    required String uuid,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
    DateTime? cachedAt,
  }) = _DocumentDbModel;

  @override
  final DateTime cachedAt;

  factory DocumentDbModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentDbModelFromJson(json);
}
