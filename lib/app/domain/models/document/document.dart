import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
abstract class Document with _$Document {
  const factory Document({
    required String uuid,
    String? paciente,
    String? titulo,
    String? tipo,
    String? medico,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
