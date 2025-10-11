// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_register_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserRegisterModel {

 String get nome; String get cpf; DateTime get dataNascimento; String get telefone; String get registerToken;
/// Create a copy of UserRegisterModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserRegisterModelCopyWith<UserRegisterModel> get copyWith => _$UserRegisterModelCopyWithImpl<UserRegisterModel>(this as UserRegisterModel, _$identity);

  /// Serializes this UserRegisterModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserRegisterModel&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.dataNascimento, dataNascimento) || other.dataNascimento == dataNascimento)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.registerToken, registerToken) || other.registerToken == registerToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nome,cpf,dataNascimento,telefone,registerToken);

@override
String toString() {
  return 'UserRegisterModel(nome: $nome, cpf: $cpf, dataNascimento: $dataNascimento, telefone: $telefone, registerToken: $registerToken)';
}


}

/// @nodoc
abstract mixin class $UserRegisterModelCopyWith<$Res>  {
  factory $UserRegisterModelCopyWith(UserRegisterModel value, $Res Function(UserRegisterModel) _then) = _$UserRegisterModelCopyWithImpl;
@useResult
$Res call({
 String nome, String cpf, DateTime dataNascimento, String telefone, String registerToken
});




}
/// @nodoc
class _$UserRegisterModelCopyWithImpl<$Res>
    implements $UserRegisterModelCopyWith<$Res> {
  _$UserRegisterModelCopyWithImpl(this._self, this._then);

  final UserRegisterModel _self;
  final $Res Function(UserRegisterModel) _then;

/// Create a copy of UserRegisterModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nome = null,Object? cpf = null,Object? dataNascimento = null,Object? telefone = null,Object? registerToken = null,}) {
  return _then(_self.copyWith(
nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,cpf: null == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String,dataNascimento: null == dataNascimento ? _self.dataNascimento : dataNascimento // ignore: cast_nullable_to_non_nullable
as DateTime,telefone: null == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String,registerToken: null == registerToken ? _self.registerToken : registerToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserRegisterModel].
extension UserRegisterModelPatterns on UserRegisterModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserRegisterModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserRegisterModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserRegisterModel value)  $default,){
final _that = this;
switch (_that) {
case _UserRegisterModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserRegisterModel value)?  $default,){
final _that = this;
switch (_that) {
case _UserRegisterModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nome,  String cpf,  DateTime dataNascimento,  String telefone,  String registerToken)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserRegisterModel() when $default != null:
return $default(_that.nome,_that.cpf,_that.dataNascimento,_that.telefone,_that.registerToken);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nome,  String cpf,  DateTime dataNascimento,  String telefone,  String registerToken)  $default,) {final _that = this;
switch (_that) {
case _UserRegisterModel():
return $default(_that.nome,_that.cpf,_that.dataNascimento,_that.telefone,_that.registerToken);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nome,  String cpf,  DateTime dataNascimento,  String telefone,  String registerToken)?  $default,) {final _that = this;
switch (_that) {
case _UserRegisterModel() when $default != null:
return $default(_that.nome,_that.cpf,_that.dataNascimento,_that.telefone,_that.registerToken);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserRegisterModel implements UserRegisterModel {
  const _UserRegisterModel({required this.nome, required this.cpf, required this.dataNascimento, required this.telefone, required this.registerToken});
  factory _UserRegisterModel.fromJson(Map<String, dynamic> json) => _$UserRegisterModelFromJson(json);

@override final  String nome;
@override final  String cpf;
@override final  DateTime dataNascimento;
@override final  String telefone;
@override final  String registerToken;

/// Create a copy of UserRegisterModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserRegisterModelCopyWith<_UserRegisterModel> get copyWith => __$UserRegisterModelCopyWithImpl<_UserRegisterModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserRegisterModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserRegisterModel&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.dataNascimento, dataNascimento) || other.dataNascimento == dataNascimento)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.registerToken, registerToken) || other.registerToken == registerToken));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nome,cpf,dataNascimento,telefone,registerToken);

@override
String toString() {
  return 'UserRegisterModel(nome: $nome, cpf: $cpf, dataNascimento: $dataNascimento, telefone: $telefone, registerToken: $registerToken)';
}


}

/// @nodoc
abstract mixin class _$UserRegisterModelCopyWith<$Res> implements $UserRegisterModelCopyWith<$Res> {
  factory _$UserRegisterModelCopyWith(_UserRegisterModel value, $Res Function(_UserRegisterModel) _then) = __$UserRegisterModelCopyWithImpl;
@override @useResult
$Res call({
 String nome, String cpf, DateTime dataNascimento, String telefone, String registerToken
});




}
/// @nodoc
class __$UserRegisterModelCopyWithImpl<$Res>
    implements _$UserRegisterModelCopyWith<$Res> {
  __$UserRegisterModelCopyWithImpl(this._self, this._then);

  final _UserRegisterModel _self;
  final $Res Function(_UserRegisterModel) _then;

/// Create a copy of UserRegisterModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nome = null,Object? cpf = null,Object? dataNascimento = null,Object? telefone = null,Object? registerToken = null,}) {
  return _then(_UserRegisterModel(
nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,cpf: null == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String,dataNascimento: null == dataNascimento ? _self.dataNascimento : dataNascimento // ignore: cast_nullable_to_non_nullable
as DateTime,telefone: null == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String,registerToken: null == registerToken ? _self.registerToken : registerToken // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
