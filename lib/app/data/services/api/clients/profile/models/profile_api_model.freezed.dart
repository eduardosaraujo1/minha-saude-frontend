// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileApiModel {

 String get id; String get nome; String get cpf; String get email; String get telefone; DateTime get dataNascimento; String get metodoAutenticacao;
/// Create a copy of ProfileApiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileApiModelCopyWith<ProfileApiModel> get copyWith => _$ProfileApiModelCopyWithImpl<ProfileApiModel>(this as ProfileApiModel, _$identity);

  /// Serializes this ProfileApiModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileApiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.email, email) || other.email == email)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.dataNascimento, dataNascimento) || other.dataNascimento == dataNascimento)&&(identical(other.metodoAutenticacao, metodoAutenticacao) || other.metodoAutenticacao == metodoAutenticacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nome,cpf,email,telefone,dataNascimento,metodoAutenticacao);

@override
String toString() {
  return 'ProfileApiModel(id: $id, nome: $nome, cpf: $cpf, email: $email, telefone: $telefone, dataNascimento: $dataNascimento, metodoAutenticacao: $metodoAutenticacao)';
}


}

/// @nodoc
abstract mixin class $ProfileApiModelCopyWith<$Res>  {
  factory $ProfileApiModelCopyWith(ProfileApiModel value, $Res Function(ProfileApiModel) _then) = _$ProfileApiModelCopyWithImpl;
@useResult
$Res call({
 String id, String nome, String cpf, String email, String telefone, DateTime dataNascimento, String metodoAutenticacao
});




}
/// @nodoc
class _$ProfileApiModelCopyWithImpl<$Res>
    implements $ProfileApiModelCopyWith<$Res> {
  _$ProfileApiModelCopyWithImpl(this._self, this._then);

  final ProfileApiModel _self;
  final $Res Function(ProfileApiModel) _then;

/// Create a copy of ProfileApiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,Object? cpf = null,Object? email = null,Object? telefone = null,Object? dataNascimento = null,Object? metodoAutenticacao = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,cpf: null == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,telefone: null == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String,dataNascimento: null == dataNascimento ? _self.dataNascimento : dataNascimento // ignore: cast_nullable_to_non_nullable
as DateTime,metodoAutenticacao: null == metodoAutenticacao ? _self.metodoAutenticacao : metodoAutenticacao // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileApiModel].
extension ProfileApiModelPatterns on ProfileApiModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileApiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileApiModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileApiModel value)  $default,){
final _that = this;
switch (_that) {
case _ProfileApiModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileApiModel value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileApiModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nome,  String cpf,  String email,  String telefone,  DateTime dataNascimento,  String metodoAutenticacao)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileApiModel() when $default != null:
return $default(_that.id,_that.nome,_that.cpf,_that.email,_that.telefone,_that.dataNascimento,_that.metodoAutenticacao);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nome,  String cpf,  String email,  String telefone,  DateTime dataNascimento,  String metodoAutenticacao)  $default,) {final _that = this;
switch (_that) {
case _ProfileApiModel():
return $default(_that.id,_that.nome,_that.cpf,_that.email,_that.telefone,_that.dataNascimento,_that.metodoAutenticacao);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nome,  String cpf,  String email,  String telefone,  DateTime dataNascimento,  String metodoAutenticacao)?  $default,) {final _that = this;
switch (_that) {
case _ProfileApiModel() when $default != null:
return $default(_that.id,_that.nome,_that.cpf,_that.email,_that.telefone,_that.dataNascimento,_that.metodoAutenticacao);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _ProfileApiModel implements ProfileApiModel {
  const _ProfileApiModel({required this.id, required this.nome, required this.cpf, required this.email, required this.telefone, required this.dataNascimento, required this.metodoAutenticacao});
  factory _ProfileApiModel.fromJson(Map<String, dynamic> json) => _$ProfileApiModelFromJson(json);

@override final  String id;
@override final  String nome;
@override final  String cpf;
@override final  String email;
@override final  String telefone;
@override final  DateTime dataNascimento;
@override final  String metodoAutenticacao;

/// Create a copy of ProfileApiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileApiModelCopyWith<_ProfileApiModel> get copyWith => __$ProfileApiModelCopyWithImpl<_ProfileApiModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileApiModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileApiModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.cpf, cpf) || other.cpf == cpf)&&(identical(other.email, email) || other.email == email)&&(identical(other.telefone, telefone) || other.telefone == telefone)&&(identical(other.dataNascimento, dataNascimento) || other.dataNascimento == dataNascimento)&&(identical(other.metodoAutenticacao, metodoAutenticacao) || other.metodoAutenticacao == metodoAutenticacao));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nome,cpf,email,telefone,dataNascimento,metodoAutenticacao);

@override
String toString() {
  return 'ProfileApiModel(id: $id, nome: $nome, cpf: $cpf, email: $email, telefone: $telefone, dataNascimento: $dataNascimento, metodoAutenticacao: $metodoAutenticacao)';
}


}

/// @nodoc
abstract mixin class _$ProfileApiModelCopyWith<$Res> implements $ProfileApiModelCopyWith<$Res> {
  factory _$ProfileApiModelCopyWith(_ProfileApiModel value, $Res Function(_ProfileApiModel) _then) = __$ProfileApiModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nome, String cpf, String email, String telefone, DateTime dataNascimento, String metodoAutenticacao
});




}
/// @nodoc
class __$ProfileApiModelCopyWithImpl<$Res>
    implements _$ProfileApiModelCopyWith<$Res> {
  __$ProfileApiModelCopyWithImpl(this._self, this._then);

  final _ProfileApiModel _self;
  final $Res Function(_ProfileApiModel) _then;

/// Create a copy of ProfileApiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,Object? cpf = null,Object? email = null,Object? telefone = null,Object? dataNascimento = null,Object? metodoAutenticacao = null,}) {
  return _then(_ProfileApiModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,cpf: null == cpf ? _self.cpf : cpf // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,telefone: null == telefone ? _self.telefone : telefone // ignore: cast_nullable_to_non_nullable
as String,dataNascimento: null == dataNascimento ? _self.dataNascimento : dataNascimento // ignore: cast_nullable_to_non_nullable
as DateTime,metodoAutenticacao: null == metodoAutenticacao ? _self.metodoAutenticacao : metodoAutenticacao // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
