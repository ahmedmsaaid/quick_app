// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Service _$ServiceFromJson(Map<String, dynamic> json) => _Service(
  name: json['name'] as String,
  price: json['price'] as String,
  imagePath: json['imagePath'] as String?,
);

Map<String, dynamic> _$ServiceToJson(_Service instance) => <String, dynamic>{
  'name': instance.name,
  'price': instance.price,
  'imagePath': instance.imagePath,
};
