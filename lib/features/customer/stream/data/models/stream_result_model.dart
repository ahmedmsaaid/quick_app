// lib/features/stream/data/models/stream_result_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'stream_result_model.g.dart';

@JsonSerializable()
class StreamResult {
  final int id;
  final String url;
  final String name;
  final int type;
  final int size;
  final String extension;

  const StreamResult({
    required this.id,
    required this.url,
    required this.name,
    required this.type,
    required this.size,
    required this.extension,
  });

  factory StreamResult.fromJson(Map<String, dynamic> json) =>
      _$StreamResultFromJson(json);

  @override
  String toString() => 'StreamResult(id: $id, url: $url, name: $name)';
}
