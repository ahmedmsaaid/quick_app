 import '../../../../core/utils/assets/app_images.dart';
 import '../../../../core/localizations/app_strings.g.dart';

class OnBoardingModel {
  final String title;
  final String description;
  final String mainImage;

  OnBoardingModel({
    required this.title,
    required this.description,
    required this.mainImage,
   });
}

 List<OnBoardingModel> onboardingPages() => [
   OnBoardingModel(
     title: AppStrings.findEverythingYouNeed,
     description: AppStrings.orderGroceriesMealsAndDailyNeedsEasily,
     mainImage: AppImages.coverOnBoarding1,
   ),
   OnBoardingModel(
     title: AppStrings.fastDeliveryAnytime,
     description:
     AppStrings.trackYourOrdersInRealTimeFromStoresAndRestaurants,
     mainImage: AppImages.coverOnBoarding2,
   ),
   OnBoardingModel(
     title: AppStrings.bestRestaurantsAndMarkets,
     description:
     AppStrings.enjoyAWideRangeOfRestaurantsAndSupermarketsNearYou,
     mainImage: AppImages.coverOnBoarding3,
   ),
 ];