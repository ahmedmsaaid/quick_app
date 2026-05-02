class SalonModel {
  final String name;
  final String imageUrl;
  final double rating;
  final double distance;
  final String? address;

  SalonModel({
    required this.name,
    required this.distance,
    required this.imageUrl,
    required this.rating,
    this.address,
  });
}
