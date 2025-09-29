// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LoginApiResponse _$LoginApiResponseFromJson(Map<String, dynamic> json) =>
    _LoginApiResponse(
      isRegistered: json['isRegistered'] as bool,
      sessionToken: json['sessionToken'] as String?,
      registerToken: json['registerToken'] as String?,
    );

Map<String, dynamic> _$LoginApiResponseToJson(_LoginApiResponse instance) =>
    <String, dynamic>{
      'isRegistered': instance.isRegistered,
      'sessionToken': instance.sessionToken,
      'registerToken': instance.registerToken,
    };
