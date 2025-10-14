// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileApiModel _$ProfileApiModelFromJson(Map<String, dynamic> json) =>
    _ProfileApiModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      email: json['email'] as String,
      telefone: json['telefone'] as String,
      dataNascimento: DateTime.parse(json['data_nascimento'] as String),
      metodoAutenticacao: json['metodo_autenticacao'] as String,
    );

Map<String, dynamic> _$ProfileApiModelToJson(_ProfileApiModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'cpf': instance.cpf,
      'email': instance.email,
      'telefone': instance.telefone,
      'data_nascimento': instance.dataNascimento.toIso8601String(),
      'metodo_autenticacao': instance.metodoAutenticacao,
    };
