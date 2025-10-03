// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
LoginResponse _$LoginResponseFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'successful':
          return SuccessfulLoginResponse.fromJson(
            json
          );
                case 'needsRegistration':
          return NeedsRegistrationLoginResponse.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'LoginResponse',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$LoginResponse {



  /// Serializes this LoginResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginResponse);
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'LoginResponse()';
}


}

/// @nodoc
class $LoginResponseCopyWith<$Res>  {
$LoginResponseCopyWith(LoginResponse _, $Res Function(LoginResponse) __);
}


/// Adds pattern-matching-related methods to [LoginResponse].
extension LoginResponsePatterns on LoginResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SuccessfulLoginResponse value)?  successful,TResult Function( NeedsRegistrationLoginResponse value)?  needsRegistration,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SuccessfulLoginResponse() when successful != null:
return successful(_that);case NeedsRegistrationLoginResponse() when needsRegistration != null:
return needsRegistration(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SuccessfulLoginResponse value)  successful,required TResult Function( NeedsRegistrationLoginResponse value)  needsRegistration,}){
final _that = this;
switch (_that) {
case SuccessfulLoginResponse():
return successful(_that);case NeedsRegistrationLoginResponse():
return needsRegistration(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SuccessfulLoginResponse value)?  successful,TResult? Function( NeedsRegistrationLoginResponse value)?  needsRegistration,}){
final _that = this;
switch (_that) {
case SuccessfulLoginResponse() when successful != null:
return successful(_that);case NeedsRegistrationLoginResponse() when needsRegistration != null:
return needsRegistration(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String sessionToken)?  successful,TResult Function( String registerToken)?  needsRegistration,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SuccessfulLoginResponse() when successful != null:
return successful(_that.sessionToken);case NeedsRegistrationLoginResponse() when needsRegistration != null:
return needsRegistration(_that.registerToken);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String sessionToken)  successful,required TResult Function( String registerToken)  needsRegistration,}) {final _that = this;
switch (_that) {
case SuccessfulLoginResponse():
return successful(_that.sessionToken);case NeedsRegistrationLoginResponse():
return needsRegistration(_that.registerToken);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String sessionToken)?  successful,TResult? Function( String registerToken)?  needsRegistration,}) {final _that = this;
switch (_that) {
case SuccessfulLoginResponse() when successful != null:
return successful(_that.sessionToken);case NeedsRegistrationLoginResponse() when needsRegistration != null:
return needsRegistration(_that.registerToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SuccessfulLoginResponse implements LoginResponse {
  const SuccessfulLoginResponse({required this.sessionToken, final  String? $type}): $type = $type ?? 'successful';
  factory SuccessfulLoginResponse.fromJson(Map<String, dynamic> json) => _$SuccessfulLoginResponseFromJson(json);

 final  String sessionToken;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessfulLoginResponseCopyWith<SuccessfulLoginResponse> get copyWith => _$SuccessfulLoginResponseCopyWithImpl<SuccessfulLoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SuccessfulLoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SuccessfulLoginResponse&&(identical(other.sessionToken, sessionToken) || other.sessionToken == sessionToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sessionToken);

@override
String toString() {
  return 'LoginResponse.successful(sessionToken: $sessionToken)';
}


}

/// @nodoc
abstract mixin class $SuccessfulLoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory $SuccessfulLoginResponseCopyWith(SuccessfulLoginResponse value, $Res Function(SuccessfulLoginResponse) _then) = _$SuccessfulLoginResponseCopyWithImpl;
@useResult
$Res call({
 String sessionToken
});




}
/// @nodoc
class _$SuccessfulLoginResponseCopyWithImpl<$Res>
    implements $SuccessfulLoginResponseCopyWith<$Res> {
  _$SuccessfulLoginResponseCopyWithImpl(this._self, this._then);

  final SuccessfulLoginResponse _self;
  final $Res Function(SuccessfulLoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? sessionToken = null,}) {
  return _then(SuccessfulLoginResponse(
sessionToken: null == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
@JsonSerializable()

class NeedsRegistrationLoginResponse implements LoginResponse {
  const NeedsRegistrationLoginResponse({required this.registerToken, final  String? $type}): $type = $type ?? 'needsRegistration';
  factory NeedsRegistrationLoginResponse.fromJson(Map<String, dynamic> json) => _$NeedsRegistrationLoginResponseFromJson(json);

 final  String registerToken;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NeedsRegistrationLoginResponseCopyWith<NeedsRegistrationLoginResponse> get copyWith => _$NeedsRegistrationLoginResponseCopyWithImpl<NeedsRegistrationLoginResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NeedsRegistrationLoginResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NeedsRegistrationLoginResponse&&(identical(other.registerToken, registerToken) || other.registerToken == registerToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,registerToken);

@override
String toString() {
  return 'LoginResponse.needsRegistration(registerToken: $registerToken)';
}


}

/// @nodoc
abstract mixin class $NeedsRegistrationLoginResponseCopyWith<$Res> implements $LoginResponseCopyWith<$Res> {
  factory $NeedsRegistrationLoginResponseCopyWith(NeedsRegistrationLoginResponse value, $Res Function(NeedsRegistrationLoginResponse) _then) = _$NeedsRegistrationLoginResponseCopyWithImpl;
@useResult
$Res call({
 String registerToken
});




}
/// @nodoc
class _$NeedsRegistrationLoginResponseCopyWithImpl<$Res>
    implements $NeedsRegistrationLoginResponseCopyWith<$Res> {
  _$NeedsRegistrationLoginResponseCopyWithImpl(this._self, this._then);

  final NeedsRegistrationLoginResponse _self;
  final $Res Function(NeedsRegistrationLoginResponse) _then;

/// Create a copy of LoginResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? registerToken = null,}) {
  return _then(NeedsRegistrationLoginResponse(
registerToken: null == registerToken ? _self.registerToken : registerToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
