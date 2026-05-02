import '../../../../core/localizations/app_strings.g.dart';
import '../../../../core/utils/assets/app_images.dart';

class OnBoardingModel {
  final String title;
  final String description;
  final String mainImage;
  final String smallImage;

  OnBoardingModel({
    required this.title,
    required this.description,
    required this.mainImage,
    required this.smallImage,
  });
}

List<OnBoardingModel> onboardingPages() => [
  OnBoardingModel(
    title: AppStrings.bookYourViewEasily,
    description: AppStrings.accurateTimesClearPricesEffortlessBooking,
    mainImage: AppImages.coverOnBoarding1,
    smallImage: AppImages.profileOnBoarding1,
  ),
  OnBoardingModel(
    title: AppStrings.yourBeautyStartsHere,
    description: AppStrings.chooseYourHairstyleDescription,
    mainImage: AppImages.coverOnBoarding2,
    smallImage: AppImages.profileOnBoarding2,
  ),
  OnBoardingModel(
    title: AppStrings.yourBeautyStartsHere,
    description: AppStrings.relaxingMassageDescription,
    mainImage: AppImages.coverOnBoarding3,
    smallImage: AppImages.profileOnBoarding3,
  ),
];
