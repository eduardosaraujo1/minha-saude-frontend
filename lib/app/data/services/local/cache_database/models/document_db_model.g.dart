// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_db_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DocumentDbModel _$DocumentDbModelFromJson(Map<String, dynamic> json) =>
    _DocumentDbModel(
      uuid: json['uuid'] as String,
      titulo: json['titulo'] as String?,
      paciente: json['paciente'] as String?,
      medico: json['medico'] as String?,
      tipo: json['tipo'] as String?,
      dataDocumento: json['data_documento'] == null
          ? null
          : DateTime.parse(json['data_documento'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      cachedAt: json['cached_at'] == null
          ? null
          : DateTime.parse(json['cached_at'] as String),
    );

Map<String, dynamic> _$DocumentDbModelToJson(_DocumentDbModel instance) =>
    <String, dynamic>{
      'cached_at': instance.cachedAt.toIso8601String(),
      'uuid': instance.uuid,
      'titulo': instance.titulo,
      'paciente': instance.paciente,
      'medico': instance.medico,
      'tipo': instance.tipo,
      'data_documento': instance.dataDocumento?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'deleted_at': instance.deletedAt?.toIso8601String(),
    };
