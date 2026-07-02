import '../../enums/role_type_enum.dart';

class User {
  User({
    this.id,
    this.name,
    this.phone,
    this.address,
    this.photoUrl,
    this.latitude,
    this.longitude,
    this.type,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    type= RoleTypeEnum.fromJson(json['type']);
    phone = json['phone'];
    address = json['address'];
    photoUrl = json['photoUrl'];
    latitude = json['latitude'];
    longitude = json['longitude'];
  }
  int? id;
  String? name;
  String? phone;
  String? address;
  String? photoUrl;
  num? latitude;
  num? longitude;
  RoleTypeEnum?type;
}
