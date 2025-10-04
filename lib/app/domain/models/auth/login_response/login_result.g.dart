// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessfulLoginResult _$SuccessfulLoginResponseFromJson(
  Map<String, dynamic> json,
) => SuccessfulLoginResult(
  sessionToken: json['sessionToken'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$SuccessfulLoginResponseToJson(
  SuccessfulLoginResult instance,
) => <String, dynamic>{
  'sessionToken': instance.sessionToken,
  'runtimeType': instance.$type,
};

NeedsRegistrationLoginResult _$NeedsRegistrationLoginResponseFromJson(
  Map<String, dynamic> json,
) => NeedsRegistrationLoginResult(
  registerToken: json['registerToken'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$NeedsRegistrationLoginResponseToJson(
  NeedsRegistrationLoginResult instance,
) => <String, dynamic>{
  'registerToken': instance.registerToken,
  'runtimeType': instance.$type,
};
