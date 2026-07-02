// This is a generated file - do not edit.
//
// Generated from Chat.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'Chat.pbenum.dart';
import 'google/protobuf/timestamp.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'Chat.pbenum.dart';

/// models
class GrpcSendMessageRequest extends $pb.GeneratedMessage {
  factory GrpcSendMessageRequest({
    $fixnum.Int64? recipientId,
    $core.String? message,
    GrpcMessageType? type,
    $core.String? mediaUrl,
  }) {
    final result = create();
    if (recipientId != null) result.recipientId = recipientId;
    if (message != null) result.message = message;
    if (type != null) result.type = type;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    return result;
  }

  GrpcSendMessageRequest._();

  factory GrpcSendMessageRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrpcSendMessageRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrpcSendMessageRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'RecipientId', $pb.PbFieldType.Q6,
        protoName: 'RecipientId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(2, _omitFieldNames ? '' : 'Message', protoName: 'Message')
    ..e<GrpcMessageType>(3, _omitFieldNames ? '' : 'Type', $pb.PbFieldType.QE,
        protoName: 'Type',
        defaultOrMaker: GrpcMessageType.Text,
        valueOf: GrpcMessageType.valueOf,
        enumValues: GrpcMessageType.values)
    ..aOS(4, _omitFieldNames ? '' : 'MediaUrl', protoName: 'MediaUrl');

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrpcSendMessageRequest clone() =>
      GrpcSendMessageRequest()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrpcSendMessageRequest copyWith(
          void Function(GrpcSendMessageRequest) updates) =>
      super.copyWith((message) => updates(message as GrpcSendMessageRequest))
          as GrpcSendMessageRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrpcSendMessageRequest create() => GrpcSendMessageRequest._();
  @$core.override
  GrpcSendMessageRequest createEmptyInstance() => create();
  static $pb.PbList<GrpcSendMessageRequest> createRepeated() =>
      $pb.PbList<GrpcSendMessageRequest>();
  @$core.pragma('dart2js:noInline')
  static GrpcSendMessageRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrpcSendMessageRequest>(create);
  static GrpcSendMessageRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get recipientId => $_getI64(0);
  @$pb.TagNumber(1)
  set recipientId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecipientId() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecipientId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  GrpcMessageType get type => $_getN(2);
  @$pb.TagNumber(3)
  set type(GrpcMessageType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mediaUrl => $_getSZ(3);
  @$pb.TagNumber(4)
  set mediaUrl($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMediaUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearMediaUrl() => $_clearField(4);
}

class GrpcRrecipientMessage extends $pb.GeneratedMessage {
  factory GrpcRrecipientMessage({
    $fixnum.Int64? chatId,
    $fixnum.Int64? recipientId,
    $fixnum.Int64? creatorId,
    $core.String? content,
    GrpcMessageType? type,
    $core.String? mediaUrl,
    $1.Timestamp? createdOn,
  }) {
    final result = create();
    if (chatId != null) result.chatId = chatId;
    if (recipientId != null) result.recipientId = recipientId;
    if (creatorId != null) result.creatorId = creatorId;
    if (content != null) result.content = content;
    if (type != null) result.type = type;
    if (mediaUrl != null) result.mediaUrl = mediaUrl;
    if (createdOn != null) result.createdOn = createdOn;
    return result;
  }

  GrpcRrecipientMessage._();

  factory GrpcRrecipientMessage.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrpcRrecipientMessage.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrpcRrecipientMessage',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'chat'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'ChatId', $pb.PbFieldType.Q6,
        protoName: 'ChatId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'RecipientId', $pb.PbFieldType.Q6,
        protoName: 'RecipientId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'CreatorId', $pb.PbFieldType.Q6,
        protoName: 'CreatorId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'Content', protoName: 'Content')
    ..e<GrpcMessageType>(5, _omitFieldNames ? '' : 'Type', $pb.PbFieldType.QE,
        protoName: 'Type',
        defaultOrMaker: GrpcMessageType.Text,
        valueOf: GrpcMessageType.valueOf,
        enumValues: GrpcMessageType.values)
    ..aOS(6, _omitFieldNames ? '' : 'MediaUrl', protoName: 'MediaUrl')
    ..aQM<$1.Timestamp>(7, _omitFieldNames ? '' : 'CreatedOn',
        protoName: 'CreatedOn', subBuilder: $1.Timestamp.create);

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrpcRrecipientMessage clone() =>
      GrpcRrecipientMessage()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GrpcRrecipientMessage copyWith(
          void Function(GrpcRrecipientMessage) updates) =>
      super.copyWith((message) => updates(message as GrpcRrecipientMessage))
          as GrpcRrecipientMessage;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrpcRrecipientMessage create() => GrpcRrecipientMessage._();
  @$core.override
  GrpcRrecipientMessage createEmptyInstance() => create();
  static $pb.PbList<GrpcRrecipientMessage> createRepeated() =>
      $pb.PbList<GrpcRrecipientMessage>();
  @$core.pragma('dart2js:noInline')
  static GrpcRrecipientMessage getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrpcRrecipientMessage>(create);
  static GrpcRrecipientMessage? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get chatId => $_getI64(0);
  @$pb.TagNumber(1)
  set chatId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChatId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChatId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get recipientId => $_getI64(1);
  @$pb.TagNumber(2)
  set recipientId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecipientId() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecipientId() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get creatorId => $_getI64(2);
  @$pb.TagNumber(3)
  set creatorId($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCreatorId() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatorId() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  GrpcMessageType get type => $_getN(4);
  @$pb.TagNumber(5)
  set type(GrpcMessageType value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasType() => $_has(4);
  @$pb.TagNumber(5)
  void clearType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get mediaUrl => $_getSZ(5);
  @$pb.TagNumber(6)
  set mediaUrl($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMediaUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearMediaUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $1.Timestamp get createdOn => $_getN(6);
  @$pb.TagNumber(7)
  set createdOn($1.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedOn() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedOn() => $_clearField(7);
  @$pb.TagNumber(7)
  $1.Timestamp ensureCreatedOn() => $_ensure(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
