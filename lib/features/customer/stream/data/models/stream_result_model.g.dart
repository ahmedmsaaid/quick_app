// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StreamResult _$StreamResultFromJson(Map<String, dynamic> json) => StreamResult(
  id: (json['id'] as num).toInt(),
  url: json['url'] as String,
  name: json['name'] as String,
  type: (json['type'] as num).toInt(),
  size: (json['size'] as num).toInt(),
  extension: json['extension'] as String,
);

Map<String, dynamic> _$StreamResultToJson(StreamResult instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'name': instance.name,
      'type': instance.type,
      'size': instance.size,
      'extension': instance.extension,
    };
