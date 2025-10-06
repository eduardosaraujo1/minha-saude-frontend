import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_api_model.freezed.dart';
part 'document_api_model.g.dart';

/// Data Transfer Object for Document API responses
/// Maps API JSON structure to domain Document model
@freezed
abstract class DocumentApiModel with _$DocumentApiModel {
  const DocumentApiModel._();

  const factory DocumentApiModel({
    required String uuid,
    String? titulo,
    String? nomePaciente,
    String? nomeMedico,
    String? tipoDocumento,
    DateTime? dataDocumento,
    required DateTime createdAt,
    DateTime? deletedAt,
  }) = _DocumentApiModel;

  factory DocumentApiModel.fromJson(Map<String, dynamic> json) =>
      _$DocumentApiModelFromJson(json);
}
