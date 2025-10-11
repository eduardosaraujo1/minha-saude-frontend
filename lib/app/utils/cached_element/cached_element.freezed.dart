// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cached_element.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CachedElement<T> {

 DateTime get timestamp; T get data; bool get forceStale;
/// Create a copy of CachedElement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedElementCopyWith<T, CachedElement<T>> get copyWith => _$CachedElementCopyWithImpl<T, CachedElement<T>>(this as CachedElement<T>, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CachedElement<T>&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.forceStale, forceStale) || other.forceStale == forceStale));
}


@override
int get hashCode => Object.hash(runtimeType,timestamp,const DeepCollectionEquality().hash(data),forceStale);

@override
String toString() {
  return 'CachedElement<$T>(timestamp: $timestamp, data: $data, forceStale: $forceStale)';
}


}

/// @nodoc
abstract mixin class $CachedElementCopyWith<T,$Res>  {
  factory $CachedElementCopyWith(CachedElement<T> value, $Res Function(CachedElement<T>) _then) = _$CachedElementCopyWithImpl;
@useResult
$Res call({
 T data, DateTime? timestamp, bool forceStale
});




}
/// @nodoc
class _$CachedElementCopyWithImpl<T,$Res>
    implements $CachedElementCopyWith<T, $Res> {
  _$CachedElementCopyWithImpl(this._self, this._then);

  final CachedElement<T> _self;
  final $Res Function(CachedElement<T>) _then;

/// Create a copy of CachedElement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? data = freezed,Object? timestamp = freezed,Object? forceStale = null,}) {
  return _then(_self.copyWith(
data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,forceStale: null == forceStale ? _self.forceStale : forceStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CachedElement].
extension CachedElementPatterns<T> on CachedElement<T> {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CachedElement<T> value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CachedElement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CachedElement<T> value)  $default,){
final _that = this;
switch (_that) {
case _CachedElement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CachedElement<T> value)?  $default,){
final _that = this;
switch (_that) {
case _CachedElement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( T data,  DateTime? timestamp,  bool forceStale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CachedElement() when $default != null:
return $default(_that.data,_that.timestamp,_that.forceStale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( T data,  DateTime? timestamp,  bool forceStale)  $default,) {final _that = this;
switch (_that) {
case _CachedElement():
return $default(_that.data,_that.timestamp,_that.forceStale);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( T data,  DateTime? timestamp,  bool forceStale)?  $default,) {final _that = this;
switch (_that) {
case _CachedElement() when $default != null:
return $default(_that.data,_that.timestamp,_that.forceStale);case _:
  return null;

}
}

}

/// @nodoc


class _CachedElement<T> extends CachedElement<T> {
   _CachedElement(this.data, {final  DateTime? timestamp, this.forceStale = false}): super._(timestamp: timestamp);
  

@override final  T data;
@override@JsonKey() final  bool forceStale;

/// Create a copy of CachedElement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedElementCopyWith<T, _CachedElement<T>> get copyWith => __$CachedElementCopyWithImpl<T, _CachedElement<T>>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CachedElement<T>&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.forceStale, forceStale) || other.forceStale == forceStale));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(data),timestamp,forceStale);

@override
String toString() {
  return 'CachedElement<$T>(data: $data, timestamp: $timestamp, forceStale: $forceStale)';
}


}

/// @nodoc
abstract mixin class _$CachedElementCopyWith<T,$Res> implements $CachedElementCopyWith<T, $Res> {
  factory _$CachedElementCopyWith(_CachedElement<T> value, $Res Function(_CachedElement<T>) _then) = __$CachedElementCopyWithImpl;
@override @useResult
$Res call({
 T data, DateTime? timestamp, bool forceStale
});




}
/// @nodoc
class __$CachedElementCopyWithImpl<T,$Res>
    implements _$CachedElementCopyWith<T, $Res> {
  __$CachedElementCopyWithImpl(this._self, this._then);

  final _CachedElement<T> _self;
  final $Res Function(_CachedElement<T>) _then;

/// Create a copy of CachedElement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? data = freezed,Object? timestamp = freezed,Object? forceStale = null,}) {
  return _then(_CachedElement<T>(
freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as T,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,forceStale: null == forceStale ? _self.forceStale : forceStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
