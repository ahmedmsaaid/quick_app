import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomSVGImage extends StatelessWidget {
  const CustomSVGImage({
    super.key,
    required this.asset,
    this.matchTextDirection = false,
    this.color,
    this.fit = BoxFit.contain,
    this.onTap,
    this.height,
    this.width,
  });

  final String asset;
  final void Function()? onTap;
  final Color? color;
  final BoxFit fit;
  final bool matchTextDirection;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (asset.contains("http")) {
      return SvgPicture.network(
        asset, // URL يجب أن يكون أولاً
        height: height,
        width: width,
        fit: fit,
        matchTextDirection: matchTextDirection,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: SvgPicture.asset(
        asset, // asset path يجب أن يكون أولاً
        height: height,
        width: width,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        fit: fit,
        matchTextDirection: matchTextDirection,
      ),
    );
  }
}
