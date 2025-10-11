// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Profile {

 String get id; String get email; String get cpf; String get nome; String get telefone; DateTime get dataNascimento; AuthMethod get metodoAutenticacao;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.dataNascimento, dataNascimento) || other.dataNascimento == dataNascimento)&&(identical(other.metodoAutenticacao, metodoAutenticacao) || other.metodoAutenticacao == metodoAutenticacao));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,cpf,nome,telefone,dataNascimento,metodoAutenticacao);

@override
String toString() {
  return 'Profile(id: $id, email: $email, cpf: $cpf, nome: $nome, telefone: $telefone, dataNascimento: $dataNascimento, metodoAutenticacao: $metodoAutenticacao)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String email, String cpf, String nome, String telefone, DateTime dataNascimento, AuthMethod metodoAutenticacao
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? cpf = null,Object? nome = null,Object? telefone = null,Object? dataNascimento = null,Object? metodoAutenticacao = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,cpf: null == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,telefone: null == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String,dataNascimento: null == dataNascimento ? _self.dataNascimento : dataNascimento // ignore: cast_nullable_to_non_nullable
as DateTime,metodoAutenticacao: null == metodoAutenticacao ? _self.metodoAutenticacao : metodoAutenticacao // ignore: cast_nullable_to_non_nullable
as AuthMethod,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  String cpf,  String nome,  String telefone,  DateTime dataNascimento,  AuthMethod metodoAutenticacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.email,_that.cpf,_that.nome,_that.telefone,_that.dataNascimento,_that.metodoAutenticacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  String cpf,  String nome,  String telefone,  DateTime dataNascimento,  AuthMethod metodoAutenticacao)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.email,_that.cpf,_that.nome,_that.telefone,_that.dataNascimento,_that.metodoAutenticacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  String cpf,  String nome,  String telefone,  DateTime dataNascimento,  AuthMethod metodoAutenticacao)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.email,_that.cpf,_that.nome,_that.telefone,_that.dataNascimento,_that.metodoAutenticacao);case _:
  return null;

}
}

}

/// @nodoc


class _Profile implements Profile {
  const _Profile({required this.id, required this.email, required this.cpf, required this.nome, required this.telefone, required this.dataNascimento, required this.metodoAutenticacao});
  

@override final  String id;
@override final  String email;
@override final  String cpf;
@override final  String nome;
@override final  String telefone;
@override final  DateTime dataNascimento;
@override final  AuthMethod metodoAutenticacao;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.dataNascimento, dataNascimento) || other.dataNascimento == dataNascimento)&&(identical(other.metodoAutenticacao, metodoAutenticacao) || other.metodoAutenticacao == metodoAutenticacao));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,cpf,nome,telefone,dataNascimento,metodoAutenticacao);

@override
String toString() {
  return 'Profile(id: $id, email: $email, cpf: $cpf, nome: $nome, telefone: $telefone, dataNascimento: $dataNascimento, metodoAutenticacao: $metodoAutenticacao)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, String cpf, String nome, String telefone, DateTime dataNascimento, AuthMethod metodoAutenticacao
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? cpf = null,Object? nome = null,Object? telefone = null,Object? dataNascimento = null,Object? metodoAutenticacao = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,cpf: null == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,telefone: null == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String,dataNascimento: null == dataNascimento ? _self.dataNascimento : dataNascimento // ignore: cast_nullable_to_non_nullable
as DateTime,metodoAutenticacao: null == metodoAutenticacao ? _self.metodoAutenticacao : metodoAutenticacao // ignore: cast_nullable_to_non_nullable
as AuthMethod,
  ));
}


}

// dart format on
