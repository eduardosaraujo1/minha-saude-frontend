// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_register_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserRegisterModel _$UserRegisterModelFromJson(Map<String, dynamic> json) =>
    _UserRegisterModel(
      nome: json['nome'] as String,
      cpf: json['cpf'] as String,
      dataNascimento: DateTime.parse(json['dataNascimento'] as String),
      telefone: json['telefone'] as String,
      registerToken: json['registerToken'] as String,
    );

Map<String, dynamic> _$UserRegisterModelToJson(_UserRegisterModel instance) =>
    <String, dynamic>{
      'nome': instance.nome,
      'cpf': instance.cpf,
      'dataNascimento': instance.dataNascimento.toIso8601String(),
      'telefone': instance.telefone,
      'registerToken': instance.registerToken,
    };
