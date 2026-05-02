import 'package:shimmer/shimmer.dart';
import 'package:base_app/core/styles/app_colors.dart';
import '../../../core/exports/exports.dart';

enum ShimmerType { list, grid }

class CustomShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxShape boxShape;
  final double? radius;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<BoxShadow>? boxShadow;
  final Color? baseColor;
  final Color? highlightColor;
  final int itemCount;
  final bool isHorizontal;
  final double separatorSpace;
  final Duration duration;

  final ShimmerType type;
  final int? crossAxisCount;
  final double? crossAxisSpacing;
  final double? mainAxisSpacing;
  final double? childAspectRatio;

  const CustomShimmer({
    super.key,
    this.height,
    this.width,
    this.boxShape = BoxShape.rectangle,
    this.radius,
    this.borderRadius,
    this.padding,
    this.margin,
    this.boxShadow,
    this.baseColor,
    this.highlightColor,
    this.itemCount = 1,
    this.isHorizontal = false,
    this.separatorSpace = 10,
    this.duration = const Duration(milliseconds: 1500),
    this.type = ShimmerType.list,
    this.crossAxisCount,
    this.crossAxisSpacing,
    this.mainAxisSpacing,
    this.childAspectRatio,
  });

  /// Rectangle shimmer for single item
  const CustomShimmer.fromRectangle({
    super.key,
    this.height = 12,
    this.width = 20,
    this.borderRadius,
    this.padding,
    this.margin,
    this.boxShadow,
    this.baseColor,
    this.highlightColor,
  }) : boxShape = BoxShape.rectangle,
        radius = null,
        itemCount = 1,
        isHorizontal = false,
        separatorSpace = 10,
        duration = const Duration(milliseconds: 1500),
        type = ShimmerType.list,
        crossAxisCount = null,
        crossAxisSpacing = null,
        mainAxisSpacing = null,
        childAspectRatio = null;

  /// Circular shimmer for single item
  const CustomShimmer.fromCircular({
    super.key,
    this.radius,
    this.height,
    this.width,
    this.borderRadius,
    this.padding,
    this.margin,
    this.boxShadow,
    this.baseColor,
    this.highlightColor,
  }) : boxShape = BoxShape.circle,
        itemCount = 1,
        isHorizontal = false,
        separatorSpace = 10,
        duration = const Duration(milliseconds: 1500),
        type = ShimmerType.list,
        crossAxisCount = null,
        crossAxisSpacing = null,
        mainAxisSpacing = null,
        childAspectRatio = null;

  /// Factory for List shimmer
  factory CustomShimmer.list({
    Key? key,
    int itemCount = 5,
    bool isHorizontal = false,
    required double height,
    required double width,
    double separatorSpace = 10,
    BoxShape boxShape = BoxShape.rectangle,
    BorderRadius? borderRadius,
    double? radius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    List<BoxShadow>? boxShadow,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return CustomShimmer(
      key: key,
      itemCount: itemCount,
      isHorizontal: isHorizontal,
      separatorSpace: separatorSpace,
      height: height,
      width: width,
      boxShape: boxShape,
      borderRadius: borderRadius,
      radius: radius,
      padding: padding,
      margin: margin,
      boxShadow: boxShadow,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      type: ShimmerType.list,
    );
  }

  factory CustomShimmer.grid({
    Key? key,
    required int itemCount,
    required int crossAxisCount,
    required double height,
    required double width,
    double crossAxisSpacing = 10,
    double mainAxisSpacing = 10,
    double childAspectRatio = 1.0,
    BoxShape boxShape = BoxShape.rectangle,
    BorderRadius? borderRadius,
    double? radius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    List<BoxShadow>? boxShadow,
    Color? baseColor,
    Color? highlightColor,
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return CustomShimmer(
      key: key,
      itemCount: itemCount,
      height: height,
      width: width,
      boxShape: boxShape,
      borderRadius: borderRadius,
      radius: radius,
      padding: padding,
      margin: margin,
      boxShadow: boxShadow,
      baseColor: baseColor,
      highlightColor: highlightColor,
      duration: duration,
      type: ShimmerType.grid,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      childAspectRatio: childAspectRatio,
    );
  }

  Widget _buildShimmerItem(BuildContext context) {
    final colors = AppColors(context);

    return Shimmer.fromColors(
      baseColor: baseColor ?? colors.shimmerBase,
      highlightColor: highlightColor ?? colors.shimmerHighlight,
      period: duration,
      child: boxShape == BoxShape.rectangle
          ? Container(
        height: height,
        width: width,
        padding: padding,
        margin: margin,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          color: colors.shimmerBase,
          boxShadow: boxShadow,
        ),
      )
          : CircleAvatar(
        radius: radius ?? (height ?? 20) / 2,
        backgroundColor: colors.shimmerBase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (itemCount <= 1) return _buildShimmerItem(context);

    switch (type) {
      case ShimmerType.list:
        if (!isHorizontal) {
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: itemCount,
            itemBuilder: (context, index) => _buildShimmerItem(context),
            separatorBuilder: (context, index) => SizedBox(height: separatorSpace),
          );
        } else {
          return SizedBox(
            height: height ?? 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: itemCount,
              itemBuilder: (context, index) => _buildShimmerItem(context),
              separatorBuilder: (context, index) => SizedBox(width: separatorSpace),
            ),
          );
        }

      case ShimmerType.grid:
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount ?? 2,
            crossAxisSpacing: crossAxisSpacing ?? 10,
            mainAxisSpacing: mainAxisSpacing ?? 10,
            childAspectRatio: childAspectRatio ?? 1.0,
          ),
          itemCount: itemCount,
          itemBuilder: (context, index) => _buildShimmerItem(context),
        );
    }
  }
}

class QuranShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration duration;

  const QuranShimmer({
    super.key,
    required this.child,
    this.isLoading = true,
    this.baseColor,
    this.highlightColor,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<QuranShimmer> createState() => _QuranShimmerState();
}

class _QuranShimmerState extends State<QuranShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(QuranShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _controller.repeat();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }

    final colors = AppColors(context);
    final effectiveBaseColor = widget.baseColor ?? colors.shimmerBase;
    final effectiveHighlightColor = widget.highlightColor ?? colors.shimmerHighlight;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                effectiveBaseColor,
                effectiveHighlightColor,
                effectiveBaseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animation.value),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
