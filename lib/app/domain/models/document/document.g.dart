// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Document _$DocumentFromJson(Map<String, dynamic> json) => _Document(
  uuid: json['uuid'] as String,
  paciente: json['paciente'] as String?,
  titulo: json['titulo'] as String?,
  tipo: json['tipo'] as String?,
  medico: json['medico'] as String?,
  dataDocumento: json['dataDocumento'] == null
      ? null
      : DateTime.parse(json['dataDocumento'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
  deletedAt: json['deletedAt'] == null
      ? null
      : DateTime.parse(json['deletedAt'] as String),
);

Map<String, dynamic> _$DocumentToJson(_Document instance) => <String, dynamic>{
  'uuid': instance.uuid,
  'paciente': instance.paciente,
  'titulo': instance.titulo,
  'tipo': instance.tipo,
  'medico': instance.medico,
  'dataDocumento': instance.dataDocumento?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
  'deletedAt': instance.deletedAt?.toIso8601String(),
};
