import 'package:base_app/core/models/booking_day_model.dart';
import 'package:base_app/core/models/salon_model.dart';
import 'package:base_app/core/utils/assets/app_images.dart';

final List<SalonModel> salons = [
  SalonModel(
    name: "Salon 1",
    imageUrl: AppImages.demo1,
    rating: 4.5,
    distance: 2.5,
    address: "123 Main St, City",
  ),
  SalonModel(
    name: "Salon 1",
    imageUrl: AppImages.demo2,
    rating: 4.5,
    distance: 2.5,
    address: "123 Main St, City",
  ),
  SalonModel(
    name: "Salon 1",
    imageUrl: AppImages.demo3,
    rating: 4.5,
    distance: 2.5,
    address: "123 Main St, City",
  ),
  SalonModel(
    name: "Salon 1",
    imageUrl: AppImages.demo1,
    rating: 4.5,
    distance: 2.5,
    address: "123 Main St, City",
  ),
];
final days = [
  BookingDay(label: 'السبت 4 أكتوبر', date: DateTime(2025, 10, 4)),
  BookingDay(label: 'الأحد 5 أكتوبر', date: DateTime(2025, 10, 5)),
  BookingDay(label: 'الاثنين 6 أكتوبر', date: DateTime(2025, 10, 6)),
];

final times = [
  BookingTime(label: '7:00 AM', value: '07:00'),
  BookingTime(label: '7:30 AM', value: '07:30'),
  BookingTime(label: '8:00 AM', value: '08:00'),
];
