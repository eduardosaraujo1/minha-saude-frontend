// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_api_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentApiModel {

 String get uuid; String? get titulo; String? get nomePaciente; String? get nomeMedico; String? get tipoDocumento; DateTime? get dataDocumento; DateTime get createdAt; DateTime? get deletedAt;
/// Create a copy of DocumentApiModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentApiModelCopyWith<DocumentApiModel> get copyWith => _$DocumentApiModelCopyWithImpl<DocumentApiModel>(this as DocumentApiModel, _$identity);

  /// Serializes this DocumentApiModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentApiModel&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.nomePaciente, nomePaciente) || other.nomePaciente == nomePaciente)&&(identical(other.nomeMedico, nomeMedico) || other.nomeMedico == nomeMedico)&&(identical(other.tipoDocumento, tipoDocumento) || other.tipoDocumento == tipoDocumento)&&(identical(other.dataDocumento, dataDocumento) || other.dataDocumento == dataDocumento)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,titulo,nomePaciente,nomeMedico,tipoDocumento,dataDocumento,createdAt,deletedAt);

@override
String toString() {
  return 'DocumentApiModel(uuid: $uuid, titulo: $titulo, nomePaciente: $nomePaciente, nomeMedico: $nomeMedico, tipoDocumento: $tipoDocumento, dataDocumento: $dataDocumento, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentApiModelCopyWith<$Res>  {
  factory $DocumentApiModelCopyWith(DocumentApiModel value, $Res Function(DocumentApiModel) _then) = _$DocumentApiModelCopyWithImpl;
@useResult
$Res call({
 String uuid, String? titulo, String? nomePaciente, String? nomeMedico, String? tipoDocumento, DateTime? dataDocumento, DateTime createdAt, DateTime? deletedAt
});




}
/// @nodoc
class _$DocumentApiModelCopyWithImpl<$Res>
    implements $DocumentApiModelCopyWith<$Res> {
  _$DocumentApiModelCopyWithImpl(this._self, this._then);

  final DocumentApiModel _self;
  final $Res Function(DocumentApiModel) _then;

/// Create a copy of DocumentApiModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? titulo = freezed,Object? nomePaciente = freezed,Object? nomeMedico = freezed,Object? tipoDocumento = freezed,Object? dataDocumento = freezed,Object? createdAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,nomePaciente: freezed == nomePaciente ? _self.nomePaciente : nomePaciente // ignore: cast_nullable_to_non_nullable
as String?,nomeMedico: freezed == nomeMedico ? _self.nomeMedico : nomeMedico // ignore: cast_nullable_to_non_nullable
as String?,tipoDocumento: freezed == tipoDocumento ? _self.tipoDocumento : tipoDocumento // ignore: cast_nullable_to_non_nullable
as String?,dataDocumento: freezed == dataDocumento ? _self.dataDocumento : dataDocumento // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentApiModel].
extension DocumentApiModelPatterns on DocumentApiModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentApiModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentApiModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentApiModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentApiModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentApiModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentApiModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String? titulo,  String? nomePaciente,  String? nomeMedico,  String? tipoDocumento,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentApiModel() when $default != null:
return $default(_that.uuid,_that.titulo,_that.nomePaciente,_that.nomeMedico,_that.tipoDocumento,_that.dataDocumento,_that.createdAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String? titulo,  String? nomePaciente,  String? nomeMedico,  String? tipoDocumento,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentApiModel():
return $default(_that.uuid,_that.titulo,_that.nomePaciente,_that.nomeMedico,_that.tipoDocumento,_that.dataDocumento,_that.createdAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String? titulo,  String? nomePaciente,  String? nomeMedico,  String? tipoDocumento,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentApiModel() when $default != null:
return $default(_that.uuid,_that.titulo,_that.nomePaciente,_that.nomeMedico,_that.tipoDocumento,_that.dataDocumento,_that.createdAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DocumentApiModel extends DocumentApiModel {
  const _DocumentApiModel({required this.uuid, this.titulo, this.nomePaciente, this.nomeMedico, this.tipoDocumento, this.dataDocumento, required this.createdAt, this.deletedAt}): super._();
  factory _DocumentApiModel.fromJson(Map<String, dynamic> json) => _$DocumentApiModelFromJson(json);

@override final  String uuid;
@override final  String? titulo;
@override final  String? nomePaciente;
@override final  String? nomeMedico;
@override final  String? tipoDocumento;
@override final  DateTime? dataDocumento;
@override final  DateTime createdAt;
@override final  DateTime? deletedAt;

/// Create a copy of DocumentApiModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentApiModelCopyWith<_DocumentApiModel> get copyWith => __$DocumentApiModelCopyWithImpl<_DocumentApiModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentApiModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentApiModel&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.nomePaciente, nomePaciente) || other.nomePaciente == nomePaciente)&&(identical(other.nomeMedico, nomeMedico) || other.nomeMedico == nomeMedico)&&(identical(other.tipoDocumento, tipoDocumento) || other.tipoDocumento == tipoDocumento)&&(identical(other.dataDocumento, dataDocumento) || other.dataDocumento == dataDocumento)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,titulo,nomePaciente,nomeMedico,tipoDocumento,dataDocumento,createdAt,deletedAt);

@override
String toString() {
  return 'DocumentApiModel(uuid: $uuid, titulo: $titulo, nomePaciente: $nomePaciente, nomeMedico: $nomeMedico, tipoDocumento: $tipoDocumento, dataDocumento: $dataDocumento, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentApiModelCopyWith<$Res> implements $DocumentApiModelCopyWith<$Res> {
  factory _$DocumentApiModelCopyWith(_DocumentApiModel value, $Res Function(_DocumentApiModel) _then) = __$DocumentApiModelCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String? titulo, String? nomePaciente, String? nomeMedico, String? tipoDocumento, DateTime? dataDocumento, DateTime createdAt, DateTime? deletedAt
});




}
/// @nodoc
class __$DocumentApiModelCopyWithImpl<$Res>
    implements _$DocumentApiModelCopyWith<$Res> {
  __$DocumentApiModelCopyWithImpl(this._self, this._then);

  final _DocumentApiModel _self;
  final $Res Function(_DocumentApiModel) _then;

/// Create a copy of DocumentApiModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? titulo = freezed,Object? nomePaciente = freezed,Object? nomeMedico = freezed,Object? tipoDocumento = freezed,Object? dataDocumento = freezed,Object? createdAt = null,Object? deletedAt = freezed,}) {
  return _then(_DocumentApiModel(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,nomePaciente: freezed == nomePaciente ? _self.nomePaciente : nomePaciente // ignore: cast_nullable_to_non_nullable
as String?,nomeMedico: freezed == nomeMedico ? _self.nomeMedico : nomeMedico // ignore: cast_nullable_to_non_nullable
as String?,tipoDocumento: freezed == tipoDocumento ? _self.tipoDocumento : tipoDocumento // ignore: cast_nullable_to_non_nullable
as String?,dataDocumento: freezed == dataDocumento ? _self.dataDocumento : dataDocumento // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
