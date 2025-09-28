// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    _LoginResponse(
      isRegistered: json['isRegistered'] as bool,
      sessionToken: json['sessionToken'] as String?,
      registerToken: json['registerToken'] as String?,
    );

Map<String, dynamic> _$LoginResponseToJson(_LoginResponse instance) =>
    <String, dynamic>{
      'isRegistered': instance.isRegistered,
      'sessionToken': instance.sessionToken,
      'registerToken': instance.registerToken,
    };
