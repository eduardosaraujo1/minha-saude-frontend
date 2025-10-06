// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document_db_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DocumentDbModel {

 DateTime get cachedAt; String get uuid; String? get titulo; String? get paciente; String? get medico; String? get tipo; DateTime? get dataDocumento; DateTime get createdAt; DateTime? get deletedAt;
/// Create a copy of DocumentDbModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentDbModelCopyWith<DocumentDbModel> get copyWith => _$DocumentDbModelCopyWithImpl<DocumentDbModel>(this as DocumentDbModel, _$identity);

  /// Serializes this DocumentDbModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DocumentDbModel&&(identical(other.cachedAt, cachedAt) || other.cachedAt == cachedAt)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.paciente, paciente) || other.paciente == paciente)&&(identical(other.medico, medico) || other.medico == medico)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.dataDocumento, dataDocumento) || other.dataDocumento == dataDocumento)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,cachedAt,uuid,titulo,paciente,medico,tipo,dataDocumento,createdAt,deletedAt);

@override
String toString() {
  return 'DocumentDbModel(cachedAt: $cachedAt, uuid: $uuid, titulo: $titulo, paciente: $paciente, medico: $medico, tipo: $tipo, dataDocumento: $dataDocumento, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentDbModelCopyWith<$Res>  {
  factory $DocumentDbModelCopyWith(DocumentDbModel value, $Res Function(DocumentDbModel) _then) = _$DocumentDbModelCopyWithImpl;
@useResult
$Res call({
 String uuid, String? titulo, String? paciente, String? medico, String? tipo, DateTime? dataDocumento, DateTime createdAt, DateTime? deletedAt, DateTime? cachedAt
});




}
/// @nodoc
class _$DocumentDbModelCopyWithImpl<$Res>
    implements $DocumentDbModelCopyWith<$Res> {
  _$DocumentDbModelCopyWithImpl(this._self, this._then);

  final DocumentDbModel _self;
  final $Res Function(DocumentDbModel) _then;

/// Create a copy of DocumentDbModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uuid = null,Object? titulo = freezed,Object? paciente = freezed,Object? medico = freezed,Object? tipo = freezed,Object? dataDocumento = freezed,Object? createdAt = null,Object? deletedAt = freezed,Object? cachedAt = freezed,}) {
  return _then(_self.copyWith(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,paciente: freezed == paciente ? _self.paciente : paciente // ignore: cast_nullable_to_non_nullable
as String?,medico: freezed == medico ? _self.medico : medico // ignore: cast_nullable_to_non_nullable
as String?,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,dataDocumento: freezed == dataDocumento ? _self.dataDocumento : dataDocumento // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cachedAt: freezed == cachedAt ? _self.cachedAt : cachedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DocumentDbModel].
extension DocumentDbModelPatterns on DocumentDbModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DocumentDbModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DocumentDbModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DocumentDbModel value)  $default,){
final _that = this;
switch (_that) {
case _DocumentDbModel():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DocumentDbModel value)?  $default,){
final _that = this;
switch (_that) {
case _DocumentDbModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uuid,  String? titulo,  String? paciente,  String? medico,  String? tipo,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt,  DateTime? cachedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DocumentDbModel() when $default != null:
return $default(_that.uuid,_that.titulo,_that.paciente,_that.medico,_that.tipo,_that.dataDocumento,_that.createdAt,_that.deletedAt,_that.cachedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uuid,  String? titulo,  String? paciente,  String? medico,  String? tipo,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt,  DateTime? cachedAt)  $default,) {final _that = this;
switch (_that) {
case _DocumentDbModel():
return $default(_that.uuid,_that.titulo,_that.paciente,_that.medico,_that.tipo,_that.dataDocumento,_that.createdAt,_that.deletedAt,_that.cachedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uuid,  String? titulo,  String? paciente,  String? medico,  String? tipo,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt,  DateTime? cachedAt)?  $default,) {final _that = this;
switch (_that) {
case _DocumentDbModel() when $default != null:
return $default(_that.uuid,_that.titulo,_that.paciente,_that.medico,_that.tipo,_that.dataDocumento,_that.createdAt,_that.deletedAt,_that.cachedAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _DocumentDbModel extends DocumentDbModel {
   _DocumentDbModel({required this.uuid, this.titulo, this.paciente, this.medico, this.tipo, this.dataDocumento, required this.createdAt, this.deletedAt, final  DateTime? cachedAt}): super._(cachedAt: cachedAt);
  factory _DocumentDbModel.fromJson(Map<String, dynamic> json) => _$DocumentDbModelFromJson(json);

@override final  String uuid;
@override final  String? titulo;
@override final  String? paciente;
@override final  String? medico;
@override final  String? tipo;
@override final  DateTime? dataDocumento;
@override final  DateTime createdAt;
@override final  DateTime? deletedAt;

/// Create a copy of DocumentDbModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentDbModelCopyWith<_DocumentDbModel> get copyWith => __$DocumentDbModelCopyWithImpl<_DocumentDbModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentDbModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DocumentDbModel&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.paciente, paciente) || other.paciente == paciente)&&(identical(other.medico, medico) || other.medico == medico)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.dataDocumento, dataDocumento) || other.dataDocumento == dataDocumento)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.cachedAt, cachedAt) || other.cachedAt == cachedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,uuid,titulo,paciente,medico,tipo,dataDocumento,createdAt,deletedAt,cachedAt);

@override
String toString() {
  return 'DocumentDbModel(uuid: $uuid, titulo: $titulo, paciente: $paciente, medico: $medico, tipo: $tipo, dataDocumento: $dataDocumento, createdAt: $createdAt, deletedAt: $deletedAt, cachedAt: $cachedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentDbModelCopyWith<$Res> implements $DocumentDbModelCopyWith<$Res> {
  factory _$DocumentDbModelCopyWith(_DocumentDbModel value, $Res Function(_DocumentDbModel) _then) = __$DocumentDbModelCopyWithImpl;
@override @useResult
$Res call({
 String uuid, String? titulo, String? paciente, String? medico, String? tipo, DateTime? dataDocumento, DateTime createdAt, DateTime? deletedAt, DateTime? cachedAt
});




}
/// @nodoc
class __$DocumentDbModelCopyWithImpl<$Res>
    implements _$DocumentDbModelCopyWith<$Res> {
  __$DocumentDbModelCopyWithImpl(this._self, this._then);

  final _DocumentDbModel _self;
  final $Res Function(_DocumentDbModel) _then;

/// Create a copy of DocumentDbModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uuid = null,Object? titulo = freezed,Object? paciente = freezed,Object? medico = freezed,Object? tipo = freezed,Object? dataDocumento = freezed,Object? createdAt = null,Object? deletedAt = freezed,Object? cachedAt = freezed,}) {
  return _then(_DocumentDbModel(
uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,paciente: freezed == paciente ? _self.paciente : paciente // ignore: cast_nullable_to_non_nullable
as String?,medico: freezed == medico ? _self.medico : medico // ignore: cast_nullable_to_non_nullable
as String?,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,dataDocumento: freezed == dataDocumento ? _self.dataDocumento : dataDocumento // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cachedAt: freezed == cachedAt ? _self.cachedAt : cachedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
