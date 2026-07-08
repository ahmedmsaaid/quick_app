// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_chat_grbc_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppChatGrbcState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppChatGrbcState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppChatGrbcState()';
}


}

/// @nodoc
class $AppChatGrbcStateCopyWith<$Res>  {
$AppChatGrbcStateCopyWith(AppChatGrbcState _, $Res Function(AppChatGrbcState) __);
}


/// Adds pattern-matching-related methods to [AppChatGrbcState].
extension AppChatGrbcStatePatterns on AppChatGrbcState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( _Initial value)?  initial,TResult Function( _Connecting value)?  connecting,TResult Function( _Connected value)?  connected,TResult Function( _SendingMessage value)?  sendingMessage,TResult Function( _MessageSent value)?  messageSent,TResult Function( _Loaded value)?  loaded,TResult Function( _Error value)?  error,TResult Function( _Disconnected value)?  disconnected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Connecting() when connecting != null:
return connecting(_that);case _Connected() when connected != null:
return connected(_that);case _SendingMessage() when sendingMessage != null:
return sendingMessage(_that);case _MessageSent() when messageSent != null:
return messageSent(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _Disconnected() when disconnected != null:
return disconnected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( _Initial value)  initial,required TResult Function( _Connecting value)  connecting,required TResult Function( _Connected value)  connected,required TResult Function( _SendingMessage value)  sendingMessage,required TResult Function( _MessageSent value)  messageSent,required TResult Function( _Loaded value)  loaded,required TResult Function( _Error value)  error,required TResult Function( _Disconnected value)  disconnected,}){
final _that = this;
switch (_that) {
case _Initial():
return initial(_that);case _Connecting():
return connecting(_that);case _Connected():
return connected(_that);case _SendingMessage():
return sendingMessage(_that);case _MessageSent():
return messageSent(_that);case _Loaded():
return loaded(_that);case _Error():
return error(_that);case _Disconnected():
return disconnected(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( _Initial value)?  initial,TResult? Function( _Connecting value)?  connecting,TResult? Function( _Connected value)?  connected,TResult? Function( _SendingMessage value)?  sendingMessage,TResult? Function( _MessageSent value)?  messageSent,TResult? Function( _Loaded value)?  loaded,TResult? Function( _Error value)?  error,TResult? Function( _Disconnected value)?  disconnected,}){
final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial(_that);case _Connecting() when connecting != null:
return connecting(_that);case _Connected() when connected != null:
return connected(_that);case _SendingMessage() when sendingMessage != null:
return sendingMessage(_that);case _MessageSent() when messageSent != null:
return messageSent(_that);case _Loaded() when loaded != null:
return loaded(_that);case _Error() when error != null:
return error(_that);case _Disconnected() when disconnected != null:
return disconnected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  connecting,TResult Function( int currentUserId)?  connected,TResult Function()?  sendingMessage,TResult Function( int currentUserId)?  messageSent,TResult Function( List<AppChatMessageGrpcModel> messages,  int currentUserId)?  loaded,TResult Function( String message)?  error,TResult Function()?  disconnected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Connecting() when connecting != null:
return connecting();case _Connected() when connected != null:
return connected(_that.currentUserId);case _SendingMessage() when sendingMessage != null:
return sendingMessage();case _MessageSent() when messageSent != null:
return messageSent(_that.currentUserId);case _Loaded() when loaded != null:
return loaded(_that.messages,_that.currentUserId);case _Error() when error != null:
return error(_that.message);case _Disconnected() when disconnected != null:
return disconnected();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  connecting,required TResult Function( int currentUserId)  connected,required TResult Function()  sendingMessage,required TResult Function( int currentUserId)  messageSent,required TResult Function( List<AppChatMessageGrpcModel> messages,  int currentUserId)  loaded,required TResult Function( String message)  error,required TResult Function()  disconnected,}) {final _that = this;
switch (_that) {
case _Initial():
return initial();case _Connecting():
return connecting();case _Connected():
return connected(_that.currentUserId);case _SendingMessage():
return sendingMessage();case _MessageSent():
return messageSent(_that.currentUserId);case _Loaded():
return loaded(_that.messages,_that.currentUserId);case _Error():
return error(_that.message);case _Disconnected():
return disconnected();case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  connecting,TResult? Function( int currentUserId)?  connected,TResult? Function()?  sendingMessage,TResult? Function( int currentUserId)?  messageSent,TResult? Function( List<AppChatMessageGrpcModel> messages,  int currentUserId)?  loaded,TResult? Function( String message)?  error,TResult? Function()?  disconnected,}) {final _that = this;
switch (_that) {
case _Initial() when initial != null:
return initial();case _Connecting() when connecting != null:
return connecting();case _Connected() when connected != null:
return connected(_that.currentUserId);case _SendingMessage() when sendingMessage != null:
return sendingMessage();case _MessageSent() when messageSent != null:
return messageSent(_that.currentUserId);case _Loaded() when loaded != null:
return loaded(_that.messages,_that.currentUserId);case _Error() when error != null:
return error(_that.message);case _Disconnected() when disconnected != null:
return disconnected();case _:
  return null;

}
}

}

/// @nodoc


class _Initial implements AppChatGrbcState {
  const _Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppChatGrbcState.initial()';
}


}




/// @nodoc


class _Connecting implements AppChatGrbcState {
  const _Connecting();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connecting);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppChatGrbcState.connecting()';
}


}




/// @nodoc


class _Connected implements AppChatGrbcState {
  const _Connected({required this.currentUserId});
  

 final  int currentUserId;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConnectedCopyWith<_Connected> get copyWith => __$ConnectedCopyWithImpl<_Connected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Connected&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId));
}


@override
int get hashCode => Object.hash(runtimeType,currentUserId);

@override
String toString() {
  return 'AppChatGrbcState.connected(currentUserId: $currentUserId)';
}


}

/// @nodoc
abstract mixin class _$ConnectedCopyWith<$Res> implements $AppChatGrbcStateCopyWith<$Res> {
  factory _$ConnectedCopyWith(_Connected value, $Res Function(_Connected) _then) = __$ConnectedCopyWithImpl;
@useResult
$Res call({
 int currentUserId
});




}
/// @nodoc
class __$ConnectedCopyWithImpl<$Res>
    implements _$ConnectedCopyWith<$Res> {
  __$ConnectedCopyWithImpl(this._self, this._then);

  final _Connected _self;
  final $Res Function(_Connected) _then;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentUserId = null,}) {
  return _then(_Connected(
currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _SendingMessage implements AppChatGrbcState {
  const _SendingMessage();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SendingMessage);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppChatGrbcState.sendingMessage()';
}


}




/// @nodoc


class _MessageSent implements AppChatGrbcState {
  const _MessageSent({required this.currentUserId});
  

 final  int currentUserId;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageSentCopyWith<_MessageSent> get copyWith => __$MessageSentCopyWithImpl<_MessageSent>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MessageSent&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId));
}


@override
int get hashCode => Object.hash(runtimeType,currentUserId);

@override
String toString() {
  return 'AppChatGrbcState.messageSent(currentUserId: $currentUserId)';
}


}

/// @nodoc
abstract mixin class _$MessageSentCopyWith<$Res> implements $AppChatGrbcStateCopyWith<$Res> {
  factory _$MessageSentCopyWith(_MessageSent value, $Res Function(_MessageSent) _then) = __$MessageSentCopyWithImpl;
@useResult
$Res call({
 int currentUserId
});




}
/// @nodoc
class __$MessageSentCopyWithImpl<$Res>
    implements _$MessageSentCopyWith<$Res> {
  __$MessageSentCopyWithImpl(this._self, this._then);

  final _MessageSent _self;
  final $Res Function(_MessageSent) _then;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? currentUserId = null,}) {
  return _then(_MessageSent(
currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Loaded implements AppChatGrbcState {
  const _Loaded({required final  List<AppChatMessageGrpcModel> messages, required this.currentUserId}): _messages = messages;
  

 final  List<AppChatMessageGrpcModel> _messages;
 List<AppChatMessageGrpcModel> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

 final  int currentUserId;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoadedCopyWith<_Loaded> get copyWith => __$LoadedCopyWithImpl<_Loaded>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Loaded&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),currentUserId);

@override
String toString() {
  return 'AppChatGrbcState.loaded(messages: $messages, currentUserId: $currentUserId)';
}


}

/// @nodoc
abstract mixin class _$LoadedCopyWith<$Res> implements $AppChatGrbcStateCopyWith<$Res> {
  factory _$LoadedCopyWith(_Loaded value, $Res Function(_Loaded) _then) = __$LoadedCopyWithImpl;
@useResult
$Res call({
 List<AppChatMessageGrpcModel> messages, int currentUserId
});




}
/// @nodoc
class __$LoadedCopyWithImpl<$Res>
    implements _$LoadedCopyWith<$Res> {
  __$LoadedCopyWithImpl(this._self, this._then);

  final _Loaded _self;
  final $Res Function(_Loaded) _then;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? currentUserId = null,}) {
  return _then(_Loaded(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<AppChatMessageGrpcModel>,currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class _Error implements AppChatGrbcState {
  const _Error(this.message);
  

 final  String message;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ErrorCopyWith<_Error> get copyWith => __$ErrorCopyWithImpl<_Error>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Error&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,message);

@override
String toString() {
  return 'AppChatGrbcState.error(message: $message)';
}


}

/// @nodoc
abstract mixin class _$ErrorCopyWith<$Res> implements $AppChatGrbcStateCopyWith<$Res> {
  factory _$ErrorCopyWith(_Error value, $Res Function(_Error) _then) = __$ErrorCopyWithImpl;
@useResult
$Res call({
 String message
});




}
/// @nodoc
class __$ErrorCopyWithImpl<$Res>
    implements _$ErrorCopyWith<$Res> {
  __$ErrorCopyWithImpl(this._self, this._then);

  final _Error _self;
  final $Res Function(_Error) _then;

/// Create a copy of AppChatGrbcState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,}) {
  return _then(_Error(
null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class _Disconnected implements AppChatGrbcState {
  const _Disconnected();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Disconnected);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppChatGrbcState.disconnected()';
}


}




// dart format on
