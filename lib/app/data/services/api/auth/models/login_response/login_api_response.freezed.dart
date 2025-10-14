// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_api_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LoginApiResponse {

/// Indicates if user has completed registration
 bool get isRegistered;/// Session token for authenticated users (only when isRegistered = true)
 String? get sessionToken;/// Register token for users who need to complete registration (only when isRegistered = false)
 String? get registerToken;
/// Create a copy of LoginApiResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginApiResponseCopyWith<LoginApiResponse> get copyWith => _$LoginApiResponseCopyWithImpl<LoginApiResponse>(this as LoginApiResponse, _$identity);

  /// Serializes this LoginApiResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginApiResponse&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.sessionToken, sessionToken) || other.sessionToken == sessionToken)&&(identical(other.registerToken, registerToken) || other.registerToken == registerToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isRegistered,sessionToken,registerToken);

@override
String toString() {
  return 'LoginApiResponse(isRegistered: $isRegistered, sessionToken: $sessionToken, registerToken: $registerToken)';
}


}

/// @nodoc
abstract mixin class $LoginApiResponseCopyWith<$Res>  {
  factory $LoginApiResponseCopyWith(LoginApiResponse value, $Res Function(LoginApiResponse) _then) = _$LoginApiResponseCopyWithImpl;
@useResult
$Res call({
 bool isRegistered, String? sessionToken, String? registerToken
});




}
/// @nodoc
class _$LoginApiResponseCopyWithImpl<$Res>
    implements $LoginApiResponseCopyWith<$Res> {
  _$LoginApiResponseCopyWithImpl(this._self, this._then);

  final LoginApiResponse _self;
  final $Res Function(LoginApiResponse) _then;

/// Create a copy of LoginApiResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isRegistered = null,Object? sessionToken = freezed,Object? registerToken = freezed,}) {
  return _then(_self.copyWith(
isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,sessionToken: freezed == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String?,registerToken: freezed == registerToken ? _self.registerToken : registerToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [LoginApiResponse].
extension LoginApiResponsePatterns on LoginApiResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginApiResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginApiResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginApiResponse value)  $default,){
final _that = this;
switch (_that) {
case _LoginApiResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginApiResponse value)?  $default,){
final _that = this;
switch (_that) {
case _LoginApiResponse() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isRegistered,  String? sessionToken,  String? registerToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginApiResponse() when $default != null:
return $default(_that.isRegistered,_that.sessionToken,_that.registerToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isRegistered,  String? sessionToken,  String? registerToken)  $default,) {final _that = this;
switch (_that) {
case _LoginApiResponse():
return $default(_that.isRegistered,_that.sessionToken,_that.registerToken);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isRegistered,  String? sessionToken,  String? registerToken)?  $default,) {final _that = this;
switch (_that) {
case _LoginApiResponse() when $default != null:
return $default(_that.isRegistered,_that.sessionToken,_that.registerToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LoginApiResponse implements LoginApiResponse {
  const _LoginApiResponse({required this.isRegistered, this.sessionToken, this.registerToken});
  factory _LoginApiResponse.fromJson(Map<String, dynamic> json) => _$LoginApiResponseFromJson(json);

/// Indicates if user has completed registration
@override final  bool isRegistered;
/// Session token for authenticated users (only when isRegistered = true)
@override final  String? sessionToken;
/// Register token for users who need to complete registration (only when isRegistered = false)
@override final  String? registerToken;

/// Create a copy of LoginApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginApiResponseCopyWith<_LoginApiResponse> get copyWith => __$LoginApiResponseCopyWithImpl<_LoginApiResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LoginApiResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginApiResponse&&(identical(other.isRegistered, isRegistered) || other.isRegistered == isRegistered)&&(identical(other.sessionToken, sessionToken) || other.sessionToken == sessionToken)&&(identical(other.registerToken, registerToken) || other.registerToken == registerToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isRegistered,sessionToken,registerToken);

@override
String toString() {
  return 'LoginApiResponse(isRegistered: $isRegistered, sessionToken: $sessionToken, registerToken: $registerToken)';
}


}

/// @nodoc
abstract mixin class _$LoginApiResponseCopyWith<$Res> implements $LoginApiResponseCopyWith<$Res> {
  factory _$LoginApiResponseCopyWith(_LoginApiResponse value, $Res Function(_LoginApiResponse) _then) = __$LoginApiResponseCopyWithImpl;
@override @useResult
$Res call({
 bool isRegistered, String? sessionToken, String? registerToken
});




}
/// @nodoc
class __$LoginApiResponseCopyWithImpl<$Res>
    implements _$LoginApiResponseCopyWith<$Res> {
  __$LoginApiResponseCopyWithImpl(this._self, this._then);

  final _LoginApiResponse _self;
  final $Res Function(_LoginApiResponse) _then;

/// Create a copy of LoginApiResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isRegistered = null,Object? sessionToken = freezed,Object? registerToken = freezed,}) {
  return _then(_LoginApiResponse(
isRegistered: null == isRegistered ? _self.isRegistered : isRegistered // ignore: cast_nullable_to_non_nullable
as bool,sessionToken: freezed == sessionToken ? _self.sessionToken : sessionToken // ignore: cast_nullable_to_non_nullable
as String?,registerToken: freezed == registerToken ? _self.registerToken : registerToken // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
