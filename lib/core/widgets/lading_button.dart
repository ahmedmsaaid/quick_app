import 'package:lottie/lottie.dart';
import 'package:base_app/core/utils/assets/app_assets.dart';

import '../exports/exports.dart';

class LoadingButton extends StatelessWidget {
  final Color? color;
  final double? size;
  final BoxFit? fit;

  const LoadingButton({super.key, this.color, this.size, this.fit});

  @override
  Widget build(BuildContext context) {
    final loadingColor = color ?? Theme.of(context).primaryColor;

    return Center(
      child: SizedBox(
        width: size ?? 50,
        height: size ?? 50,
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(loadingColor, BlendMode.srcIn),
          child: Lottie.asset(
            AppAssets.loadingLottie,
            fit: fit ?? BoxFit.contain,
            animate: true,
            repeat: true,
          ),
        ),
      ),
    );
  }
}
