// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'about_type_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AboutTypeState {

 String get description; List<ServiceEntity> get services; String get currentServiceName; String get currentServicePrice; File? get currentServiceImage; bool get isLoading; bool get isPickingImage; String? get errorMessage;
/// Create a copy of AboutTypeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AboutTypeStateCopyWith<AboutTypeState> get copyWith => _$AboutTypeStateCopyWithImpl<AboutTypeState>(this as AboutTypeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AboutTypeState&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.services, services)&&(identical(other.currentServiceName, currentServiceName) || other.currentServiceName == currentServiceName)&&(identical(other.currentServicePrice, currentServicePrice) || other.currentServicePrice == currentServicePrice)&&(identical(other.currentServiceImage, currentServiceImage) || other.currentServiceImage == currentServiceImage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPickingImage, isPickingImage) || other.isPickingImage == isPickingImage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,description,const DeepCollectionEquality().hash(services),currentServiceName,currentServicePrice,currentServiceImage,isLoading,isPickingImage,errorMessage);

@override
String toString() {
  return 'AboutTypeState(description: $description, services: $services, currentServiceName: $currentServiceName, currentServicePrice: $currentServicePrice, currentServiceImage: $currentServiceImage, isLoading: $isLoading, isPickingImage: $isPickingImage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AboutTypeStateCopyWith<$Res>  {
  factory $AboutTypeStateCopyWith(AboutTypeState value, $Res Function(AboutTypeState) _then) = _$AboutTypeStateCopyWithImpl;
@useResult
$Res call({
 String description, List<ServiceEntity> services, String currentServiceName, String currentServicePrice, File? currentServiceImage, bool isLoading, bool isPickingImage, String? errorMessage
});




}
/// @nodoc
class _$AboutTypeStateCopyWithImpl<$Res>
    implements $AboutTypeStateCopyWith<$Res> {
  _$AboutTypeStateCopyWithImpl(this._self, this._then);

  final AboutTypeState _self;
  final $Res Function(AboutTypeState) _then;

/// Create a copy of AboutTypeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? services = null,Object? currentServiceName = null,Object? currentServicePrice = null,Object? currentServiceImage = freezed,Object? isLoading = null,Object? isPickingImage = null,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceEntity>,currentServiceName: null == currentServiceName ? _self.currentServiceName : currentServiceName // ignore: cast_nullable_to_non_nullable
as String,currentServicePrice: null == currentServicePrice ? _self.currentServicePrice : currentServicePrice // ignore: cast_nullable_to_non_nullable
as String,currentServiceImage: freezed == currentServiceImage ? _self.currentServiceImage : currentServiceImage // ignore: cast_nullable_to_non_nullable
as File?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPickingImage: null == isPickingImage ? _self.isPickingImage : isPickingImage // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AboutTypeState].
extension AboutTypeStatePatterns on AboutTypeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AboutTypeState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AboutTypeState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AboutTypeState value)  $default,){
final _that = this;
switch (_that) {
case _AboutTypeState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AboutTypeState value)?  $default,){
final _that = this;
switch (_that) {
case _AboutTypeState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  List<ServiceEntity> services,  String currentServiceName,  String currentServicePrice,  File? currentServiceImage,  bool isLoading,  bool isPickingImage,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AboutTypeState() when $default != null:
return $default(_that.description,_that.services,_that.currentServiceName,_that.currentServicePrice,_that.currentServiceImage,_that.isLoading,_that.isPickingImage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  List<ServiceEntity> services,  String currentServiceName,  String currentServicePrice,  File? currentServiceImage,  bool isLoading,  bool isPickingImage,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AboutTypeState():
return $default(_that.description,_that.services,_that.currentServiceName,_that.currentServicePrice,_that.currentServiceImage,_that.isLoading,_that.isPickingImage,_that.errorMessage);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  List<ServiceEntity> services,  String currentServiceName,  String currentServicePrice,  File? currentServiceImage,  bool isLoading,  bool isPickingImage,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AboutTypeState() when $default != null:
return $default(_that.description,_that.services,_that.currentServiceName,_that.currentServicePrice,_that.currentServiceImage,_that.isLoading,_that.isPickingImage,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _AboutTypeState implements AboutTypeState {
  const _AboutTypeState({this.description = '', final  List<ServiceEntity> services = const [], this.currentServiceName = '', this.currentServicePrice = '', this.currentServiceImage, this.isLoading = false, this.isPickingImage = false, this.errorMessage}): _services = services;
  

@override@JsonKey() final  String description;
 final  List<ServiceEntity> _services;
@override@JsonKey() List<ServiceEntity> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

@override@JsonKey() final  String currentServiceName;
@override@JsonKey() final  String currentServicePrice;
@override final  File? currentServiceImage;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isPickingImage;
@override final  String? errorMessage;

/// Create a copy of AboutTypeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AboutTypeStateCopyWith<_AboutTypeState> get copyWith => __$AboutTypeStateCopyWithImpl<_AboutTypeState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AboutTypeState&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._services, _services)&&(identical(other.currentServiceName, currentServiceName) || other.currentServiceName == currentServiceName)&&(identical(other.currentServicePrice, currentServicePrice) || other.currentServicePrice == currentServicePrice)&&(identical(other.currentServiceImage, currentServiceImage) || other.currentServiceImage == currentServiceImage)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isPickingImage, isPickingImage) || other.isPickingImage == isPickingImage)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,description,const DeepCollectionEquality().hash(_services),currentServiceName,currentServicePrice,currentServiceImage,isLoading,isPickingImage,errorMessage);

@override
String toString() {
  return 'AboutTypeState(description: $description, services: $services, currentServiceName: $currentServiceName, currentServicePrice: $currentServicePrice, currentServiceImage: $currentServiceImage, isLoading: $isLoading, isPickingImage: $isPickingImage, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AboutTypeStateCopyWith<$Res> implements $AboutTypeStateCopyWith<$Res> {
  factory _$AboutTypeStateCopyWith(_AboutTypeState value, $Res Function(_AboutTypeState) _then) = __$AboutTypeStateCopyWithImpl;
@override @useResult
$Res call({
 String description, List<ServiceEntity> services, String currentServiceName, String currentServicePrice, File? currentServiceImage, bool isLoading, bool isPickingImage, String? errorMessage
});




}
/// @nodoc
class __$AboutTypeStateCopyWithImpl<$Res>
    implements _$AboutTypeStateCopyWith<$Res> {
  __$AboutTypeStateCopyWithImpl(this._self, this._then);

  final _AboutTypeState _self;
  final $Res Function(_AboutTypeState) _then;

/// Create a copy of AboutTypeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? services = null,Object? currentServiceName = null,Object? currentServicePrice = null,Object? currentServiceImage = freezed,Object? isLoading = null,Object? isPickingImage = null,Object? errorMessage = freezed,}) {
  return _then(_AboutTypeState(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<ServiceEntity>,currentServiceName: null == currentServiceName ? _self.currentServiceName : currentServiceName // ignore: cast_nullable_to_non_nullable
as String,currentServicePrice: null == currentServicePrice ? _self.currentServicePrice : currentServicePrice // ignore: cast_nullable_to_non_nullable
as String,currentServiceImage: freezed == currentServiceImage ? _self.currentServiceImage : currentServiceImage // ignore: cast_nullable_to_non_nullable
as File?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isPickingImage: null == isPickingImage ? _self.isPickingImage : isPickingImage // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
