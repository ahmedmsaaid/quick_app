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

import 'package:protobuf/protobuf.dart' as $pb;

/// enums
class GrpcMessageType extends $pb.ProtobufEnum {
  static const GrpcMessageType Text =
      GrpcMessageType._(0, _omitEnumNames ? '' : 'Text');
  static const GrpcMessageType Video =
      GrpcMessageType._(1, _omitEnumNames ? '' : 'Video');
  static const GrpcMessageType Audio =
      GrpcMessageType._(2, _omitEnumNames ? '' : 'Audio');
  static const GrpcMessageType Image =
      GrpcMessageType._(3, _omitEnumNames ? '' : 'Image');
  static const GrpcMessageType File =
      GrpcMessageType._(4, _omitEnumNames ? '' : 'File');

  static const $core.List<GrpcMessageType> values = <GrpcMessageType>[
    Text,
    Video,
    Audio,
    Image,
    File,
  ];

  static final $core.List<GrpcMessageType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 4);
  static GrpcMessageType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const GrpcMessageType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
