// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'document.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Document {

 String get id; String get uuid; String? get paciente; String? get titulo; String? get tipo; String? get medico; DateTime? get dataDocumento; DateTime get createdAt; DateTime? get deletedAt;
/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DocumentCopyWith<Document> get copyWith => _$DocumentCopyWithImpl<Document>(this as Document, _$identity);

  /// Serializes this Document to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Document&&(identical(other.id, id) || other.id == id)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.paciente, paciente) || other.paciente == paciente)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.medico, medico) || other.medico == medico)&&(identical(other.dataDocumento, dataDocumento) || other.dataDocumento == dataDocumento)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uuid,paciente,titulo,tipo,medico,dataDocumento,createdAt,deletedAt);

@override
String toString() {
  return 'Document(id: $id, uuid: $uuid, paciente: $paciente, titulo: $titulo, tipo: $tipo, medico: $medico, dataDocumento: $dataDocumento, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class $DocumentCopyWith<$Res>  {
  factory $DocumentCopyWith(Document value, $Res Function(Document) _then) = _$DocumentCopyWithImpl;
@useResult
$Res call({
 String id, String uuid, String? paciente, String? titulo, String? tipo, String? medico, DateTime? dataDocumento, DateTime createdAt, DateTime? deletedAt
});




}
/// @nodoc
class _$DocumentCopyWithImpl<$Res>
    implements $DocumentCopyWith<$Res> {
  _$DocumentCopyWithImpl(this._self, this._then);

  final Document _self;
  final $Res Function(Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uuid = null,Object? paciente = freezed,Object? titulo = freezed,Object? tipo = freezed,Object? medico = freezed,Object? dataDocumento = freezed,Object? createdAt = null,Object? deletedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,paciente: freezed == paciente ? _self.paciente : paciente // ignore: cast_nullable_to_non_nullable
as String?,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,medico: freezed == medico ? _self.medico : medico // ignore: cast_nullable_to_non_nullable
as String?,dataDocumento: freezed == dataDocumento ? _self.dataDocumento : dataDocumento // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Document].
extension DocumentPatterns on Document {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Document value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Document value)  $default,){
final _that = this;
switch (_that) {
case _Document():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Document value)?  $default,){
final _that = this;
switch (_that) {
case _Document() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uuid,  String? paciente,  String? titulo,  String? tipo,  String? medico,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.uuid,_that.paciente,_that.titulo,_that.tipo,_that.medico,_that.dataDocumento,_that.createdAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uuid,  String? paciente,  String? titulo,  String? tipo,  String? medico,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Document():
return $default(_that.id,_that.uuid,_that.paciente,_that.titulo,_that.tipo,_that.medico,_that.dataDocumento,_that.createdAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uuid,  String? paciente,  String? titulo,  String? tipo,  String? medico,  DateTime? dataDocumento,  DateTime createdAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Document() when $default != null:
return $default(_that.id,_that.uuid,_that.paciente,_that.titulo,_that.tipo,_that.medico,_that.dataDocumento,_that.createdAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Document implements Document {
  const _Document({required this.id, required this.uuid, this.paciente, this.titulo, this.tipo, this.medico, this.dataDocumento, required this.createdAt, this.deletedAt});
  factory _Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);

@override final  String id;
@override final  String uuid;
@override final  String? paciente;
@override final  String? titulo;
@override final  String? tipo;
@override final  String? medico;
@override final  DateTime? dataDocumento;
@override final  DateTime createdAt;
@override final  DateTime? deletedAt;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DocumentCopyWith<_Document> get copyWith => __$DocumentCopyWithImpl<_Document>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DocumentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Document&&(identical(other.id, id) || other.id == id)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.paciente, paciente) || other.paciente == paciente)&&(identical(other.titulo, titulo) || other.titulo == titulo)&&(identical(other.tipo, tipo) || other.tipo == tipo)&&(identical(other.medico, medico) || other.medico == medico)&&(identical(other.dataDocumento, dataDocumento) || other.dataDocumento == dataDocumento)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uuid,paciente,titulo,tipo,medico,dataDocumento,createdAt,deletedAt);

@override
String toString() {
  return 'Document(id: $id, uuid: $uuid, paciente: $paciente, titulo: $titulo, tipo: $tipo, medico: $medico, dataDocumento: $dataDocumento, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$DocumentCopyWith<$Res> implements $DocumentCopyWith<$Res> {
  factory _$DocumentCopyWith(_Document value, $Res Function(_Document) _then) = __$DocumentCopyWithImpl;
@override @useResult
$Res call({
 String id, String uuid, String? paciente, String? titulo, String? tipo, String? medico, DateTime? dataDocumento, DateTime createdAt, DateTime? deletedAt
});




}
/// @nodoc
class __$DocumentCopyWithImpl<$Res>
    implements _$DocumentCopyWith<$Res> {
  __$DocumentCopyWithImpl(this._self, this._then);

  final _Document _self;
  final $Res Function(_Document) _then;

/// Create a copy of Document
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uuid = null,Object? paciente = freezed,Object? titulo = freezed,Object? tipo = freezed,Object? medico = freezed,Object? dataDocumento = freezed,Object? createdAt = null,Object? deletedAt = freezed,}) {
  return _then(_Document(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,paciente: freezed == paciente ? _self.paciente : paciente // ignore: cast_nullable_to_non_nullable
as String?,titulo: freezed == titulo ? _self.titulo : titulo // ignore: cast_nullable_to_non_nullable
as String?,tipo: freezed == tipo ? _self.tipo : tipo // ignore: cast_nullable_to_non_nullable
as String?,medico: freezed == medico ? _self.medico : medico // ignore: cast_nullable_to_non_nullable
as String?,dataDocumento: freezed == dataDocumento ? _self.dataDocumento : dataDocumento // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
