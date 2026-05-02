// import 'package:lottie/lottie.dart';
// import 'package:rashed_mobile/core/utils/app_assets.dart';
// import '../../exports/exports.dart';
//
// bool _isLoadingDialogShowing = false;
//
// void showLoadingDialog(BuildContext context) {
//   if (!_isLoadingDialogShowing) {
//     _isLoadingDialogShowing = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       useSafeArea: true,
//       builder: (context) {
//         return Dialog(
//           backgroundColor: AppColors.transparent,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: SizedBox(
//             width: 120.w,
//             height: 300.h,
//             child: Center(
//               child: Lottie.asset(AppAssets.loadingLottie),
//             ),
//           ),
//         );
//       },
//     ).then((_) {
//       _isLoadingDialogShowing = false;
//     });
//   }
// }
//
// Future<void> hideLoadingDialog(BuildContext context) async {
//   if (_isLoadingDialogShowing && Navigator.canPop(context)) {
//     Navigator.of(context, rootNavigator: true).pop();
//     _isLoadingDialogShowing = false;
//     // تأخير صغير للتأكد من إغلاق الديالوج
//     await Future.delayed(const Duration(milliseconds: 150));
//   }
// }
