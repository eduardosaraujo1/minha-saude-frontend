// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuccessfulLoginResult _$SuccessfulLoginResultFromJson(
  Map<String, dynamic> json,
) => SuccessfulLoginResult(
  sessionToken: json['sessionToken'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$SuccessfulLoginResultToJson(
  SuccessfulLoginResult instance,
) => <String, dynamic>{
  'sessionToken': instance.sessionToken,
  'runtimeType': instance.$type,
};

NeedsRegistrationLoginResult _$NeedsRegistrationLoginResultFromJson(
  Map<String, dynamic> json,
) => NeedsRegistrationLoginResult(
  registerToken: json['registerToken'] as String,
  $type: json['runtimeType'] as String?,
);

Map<String, dynamic> _$NeedsRegistrationLoginResultToJson(
  NeedsRegistrationLoginResult instance,
) => <String, dynamic>{
  'registerToken': instance.registerToken,
  'runtimeType': instance.$type,
};
