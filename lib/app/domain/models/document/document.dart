import 'package:freezed_annotation/freezed_annotation.dart';

part 'document.freezed.dart';
part 'document.g.dart';

@freezed
abstract class Document with _$Document {
  const factory Document({
    required String id,
    required String paciente,
    required String titulo,
    required String tipo,
    required String medico,
    required DateTime dataDocumento,
    required DateTime dataAdicao,
    DateTime? deletedAt,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
