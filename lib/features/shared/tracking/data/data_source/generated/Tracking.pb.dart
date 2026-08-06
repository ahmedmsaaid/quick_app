// This is a generated file - do not edit.
//
// Generated from Tracking.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'Tracking.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'Tracking.pbenum.dart';

class GrpcSubscribeRequest extends $pb.GeneratedMessage {
  factory GrpcSubscribeRequest({
    $fixnum.Int64? orderId,
  }) {
    final result = create();
    if (orderId != null) result.orderId = orderId;
    return result;
  }

  GrpcSubscribeRequest._();

  factory GrpcSubscribeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrpcSubscribeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrpcSubscribeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tracking'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'OrderId', $pb.PbFieldType.OU6,
        protoName: 'OrderId', defaultOrMaker: $fixnum.Int64.ZERO);

  @$core.override
  GrpcSubscribeRequest clone() => GrpcSubscribeRequest()..mergeFromMessage(this);
  @$core.override
  GrpcSubscribeRequest copyWith(void Function(GrpcSubscribeRequest) updates) =>
      super.copyWith((message) => updates(message as GrpcSubscribeRequest)) as GrpcSubscribeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrpcSubscribeRequest create() => GrpcSubscribeRequest._();
  @$core.override
  GrpcSubscribeRequest createEmptyInstance() => create();
  static $pb.PbList<GrpcSubscribeRequest> createRepeated() =>
      $pb.PbList<GrpcSubscribeRequest>();
  @$core.pragma('dart2js:noInline')
  static GrpcSubscribeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrpcSubscribeRequest>(create);
  static GrpcSubscribeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get orderId => $_getI64(0);
  @$pb.TagNumber(1)
  set orderId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);
}

class GrpcLocationUpdate extends $pb.GeneratedMessage {
  factory GrpcLocationUpdate({
    $fixnum.Int64? orderId,
    $fixnum.Int64? deliveryId,
    $core.double? latitude,
    $core.double? longitude,
    GrpcOrderStatus? status,
  }) {
    final result = create();
    if (orderId != null) result.orderId = orderId;
    if (deliveryId != null) result.deliveryId = deliveryId;
    if (latitude != null) result.latitude = latitude;
    if (longitude != null) result.longitude = longitude;
    if (status != null) result.status = status;
    return result;
  }

  GrpcLocationUpdate._();

  factory GrpcLocationUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrpcLocationUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrpcLocationUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tracking'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'OrderId', $pb.PbFieldType.OU6,
        protoName: 'OrderId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'DeliveryId', $pb.PbFieldType.OU6,
        protoName: 'DeliveryId', defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'Latitude', $pb.PbFieldType.OD,
        protoName: 'Latitude')
    ..a<$core.double>(
        4, _omitFieldNames ? '' : 'Longitude', $pb.PbFieldType.OD,
        protoName: 'Longitude')
    ..e<GrpcOrderStatus>(5, _omitFieldNames ? '' : 'Status', $pb.PbFieldType.OE,
        protoName: 'Status',
        defaultOrMaker: GrpcOrderStatus.OutForDelivery,
        valueOf: GrpcOrderStatus.valueOf,
        enumValues: GrpcOrderStatus.values);

  @$core.override
  GrpcLocationUpdate clone() => GrpcLocationUpdate()..mergeFromMessage(this);
  @$core.override
  GrpcLocationUpdate copyWith(void Function(GrpcLocationUpdate) updates) =>
      super.copyWith((message) => updates(message as GrpcLocationUpdate)) as GrpcLocationUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrpcLocationUpdate create() => GrpcLocationUpdate._();
  @$core.override
  GrpcLocationUpdate createEmptyInstance() => create();
  static $pb.PbList<GrpcLocationUpdate> createRepeated() =>
      $pb.PbList<GrpcLocationUpdate>();
  @$core.pragma('dart2js:noInline')
  static GrpcLocationUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrpcLocationUpdate>(create);
  static GrpcLocationUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get orderId => $_getI64(0);
  @$pb.TagNumber(1)
  set orderId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOrderId() => $_has(0);
  @$pb.TagNumber(1)
  void clearOrderId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get deliveryId => $_getI64(1);
  @$pb.TagNumber(2)
  set deliveryId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDeliveryId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDeliveryId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.double get latitude => $_getN(2);
  @$pb.TagNumber(3)
  set latitude($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLatitude() => $_has(2);
  @$pb.TagNumber(3)
  void clearLatitude() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get longitude => $_getN(3);
  @$pb.TagNumber(4)
  set longitude($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLongitude() => $_has(3);
  @$pb.TagNumber(4)
  void clearLongitude() => $_clearField(4);

  @$pb.TagNumber(5)
  GrpcOrderStatus get status => $_getN(4);
  @$pb.TagNumber(5)
  set status(GrpcOrderStatus value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasStatus() => $_has(4);
  @$pb.TagNumber(5)
  void clearStatus() => $_clearField(5);
}

class GrpcTrackingAck extends $pb.GeneratedMessage {
  factory GrpcTrackingAck({
    $core.bool? received,
  }) {
    final result = create();
    if (received != null) result.received = received;
    return result;
  }

  GrpcTrackingAck._();

  factory GrpcTrackingAck.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory GrpcTrackingAck.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GrpcTrackingAck',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'tracking'),
      createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'Received', protoName: 'Received');

  @$core.override
  GrpcTrackingAck clone() => GrpcTrackingAck()..mergeFromMessage(this);
  @$core.override
  GrpcTrackingAck copyWith(void Function(GrpcTrackingAck) updates) =>
      super.copyWith((message) => updates(message as GrpcTrackingAck)) as GrpcTrackingAck;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GrpcTrackingAck create() => GrpcTrackingAck._();
  @$core.override
  GrpcTrackingAck createEmptyInstance() => create();
  static $pb.PbList<GrpcTrackingAck> createRepeated() =>
      $pb.PbList<GrpcTrackingAck>();
  @$core.pragma('dart2js:noInline')
  static GrpcTrackingAck getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GrpcTrackingAck>(create);
  static GrpcTrackingAck? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get received => $_getBF(0);
  @$pb.TagNumber(1)
  set received($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReceived() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceived() => $_clearField(1);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
