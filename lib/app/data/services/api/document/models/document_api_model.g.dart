// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentApiModel _$DocumentApiModelFromJson(Map<String, dynamic> json) =>
    _DocumentApiModel(
      uuid: json['uuid'] as String,
      titulo: json['titulo'] as String,
      nomePaciente: json['nomePaciente'] as String?,
      nomeMedico: json['nomeMedico'] as String?,
      tipoDocumento: json['tipoDocumento'] as String?,
      dataDocumento: json['dataDocumento'] == null
          ? null
          : DateTime.parse(json['dataDocumento'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$DocumentApiModelToJson(_DocumentApiModel instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'titulo': instance.titulo,
      'nomePaciente': instance.nomePaciente,
      'nomeMedico': instance.nomeMedico,
      'tipoDocumento': instance.tipoDocumento,
      'dataDocumento': instance.dataDocumento?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };
