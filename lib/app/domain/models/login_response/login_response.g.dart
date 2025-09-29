// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessfulLoginResponse _$SuccessfulLoginResponseFromJson(
  Map<String, dynamic> json,
) => SuccessfulLoginResponse(
  sessionToken: json['sessionToken'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$SuccessfulLoginResponseToJson(
  SuccessfulLoginResponse instance,
) => <String, dynamic>{
  'sessionToken': instance.sessionToken,
  'runtimeType': instance.$type,
};

NeedsRegistrationLoginResponse _$NeedsRegistrationLoginResponseFromJson(
  Map<String, dynamic> json,
) => NeedsRegistrationLoginResponse(
  registerToken: json['registerToken'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$NeedsRegistrationLoginResponseToJson(
  NeedsRegistrationLoginResponse instance,
) => <String, dynamic>{
  'registerToken': instance.registerToken,
  'runtimeType': instance.$type,
};
