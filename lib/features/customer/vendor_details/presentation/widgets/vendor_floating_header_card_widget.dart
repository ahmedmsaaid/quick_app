import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';

class VendorFloatingHeaderCardWidget extends StatelessWidget {
  const VendorFloatingHeaderCardWidget({
    super.key,
    required this.vendor,
    required this.categories,
    required this.colors,
    required this.isMarket,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  final UserDto vendor;
  final List<CategoryDto> categories;
  final AppColors colors;
  final bool isMarket;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  String _formatImageUrl(String? path) {
    if (path == null) return '';
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    String clean = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    if (clean.startsWith('quick-service-photos/')) {
      clean = clean.substring('quick-service-photos/'.length);
    }
    return '${ApiConstants.streamUrl}$clean';
  }

  String _getCuisineSubtitle() {
    if (vendor.description != null && vendor.description!.trim().isNotEmpty) {
      return vendor.description!.trim();
    }
    final validCatNames = categories
        .where((c) => c.id > 0 && c.name != null && c.name!.trim().isNotEmpty)
        .take(3)
        .map((c) => c.name!.trim())
        .toList();
    if (validCatNames.isNotEmpty) {
      return validCatNames.join('، ');
    }
    return isMarket ? 'بقالة، سوبر ماركت، منتجات طازجة' : 'ساندوتشات، مأكولات شرقية، وجبات';
  }

  void _showVendorInfoSheet(BuildContext context) {
    final bool isBusy = vendor.busy == true;
    final bool isClosed = !(vendor.active ?? true) || vendor.status == 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            16.verticalSpace,
            Row(
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9.r),
                    child: _buildVendorLogoImage(colors),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name ?? (isMarket ? 'المتجر' : 'المطعم'),
                        style: AppTextStyles.text16w700(color: colors.textPrimary),
                      ),
                      4.verticalSpace,
                      Text(
                        _getCuisineSubtitle(),
                        style: AppTextStyles.text12w400(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            Divider(color: colors.border.withValues(alpha: 0.5)),
            10.verticalSpace,
            _infoRow(
              icon: Icons.storefront_rounded,
              title: 'الحالة',
              value: isClosed
                  ? 'مغلق حالياً'
                  : (isBusy ? 'مشغول حالياً' : 'متاح للطلب'),
              valueColor: isClosed
                  ? Colors.red
                  : (isBusy ? Colors.orange : Colors.green),
            ),
            if (vendor.address != null && vendor.address!.isNotEmpty) ...[
              8.verticalSpace,
              _infoRow(
                icon: Icons.location_on_rounded,
                title: 'العنوان',
                value: vendor.address!,
              ),
            ],
            8.verticalSpace,
            _infoRow(
              icon: Icons.access_time_rounded,
              title: 'مدة التوصيل',
              value: '٣٠ - ٩٠ دقيقة',
            ),
            8.verticalSpace,
            _infoRow(
              icon: Icons.local_shipping_outlined,
              title: 'جهة التوصيل',
              value: 'التوصيل من Quick',
              valueColor: colors.primary,
            ),
            20.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: colors.textSecondary),
        8.horizontalSpace,
        Text(
          '$title: ',
          style: AppTextStyles.text12w400(color: colors.textSecondary),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.text12w700(color: valueColor ?? colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  bool _isLetterAvatar(String? path) {
    if (path == null || path.isEmpty) return false;
    final lower = path.toLowerCase();
    return lower.contains('ui-avatars.com') ||
        lower.contains('default-avatar') ||
        (lower.contains('avatar') && lower.contains('initials'));
  }

  Widget _buildVendorLogoImage(AppColors colors) {
    String? logoPath;
    // Prioritize actual store photo first over any initial/letter avatar
    if (vendor.photo != null && vendor.photo!.trim().isNotEmpty && !_isLetterAvatar(vendor.photo)) {
      logoPath = vendor.photo!.trim();
    } else if (vendor.avatar != null && vendor.avatar!.trim().isNotEmpty && !_isLetterAvatar(vendor.avatar)) {
      logoPath = vendor.avatar!.trim();
    } else if (vendor.photo != null && vendor.photo!.trim().isNotEmpty) {
      logoPath = vendor.photo!.trim();
    } else if (vendor.avatar != null && vendor.avatar!.trim().isNotEmpty) {
      logoPath = vendor.avatar!.trim();
    }

    final String url = _formatImageUrl(logoPath);
    if (url.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: colors.shimmerBase),
        errorWidget: (_, __, ___) => _defaultLogoFallback(colors),
      );
    }
    return _defaultLogoFallback(colors);
  }

  Widget _defaultLogoFallback(AppColors colors) {
    return Container(
      color: colors.containerBackground,
      alignment: Alignment.center,
      child: Icon(
        isMarket ? Icons.storefront_rounded : Icons.restaurant_rounded,
        size: 28.sp,
        color: colors.primary,
      ),
    );
  }

  Widget _placeholderCoverBg(AppColors colors) {
    return Container(
      color: colors.containerBackground,
      child: Center(
        child: Icon(
          isMarket ? Icons.storefront_rounded : Icons.restaurant_rounded,
          size: 60.sp,
          color: colors.border,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isBusy = vendor.busy == true;
    final bool isClosed = !(vendor.active ?? true) || vendor.status == 0;

    // Cover Image URL
    String? coverPath;
    if (vendor.photo != null && vendor.photo!.trim().isNotEmpty && !_isLetterAvatar(vendor.photo)) {
      coverPath = vendor.photo!.trim();
    } else if (vendor.avatar != null && vendor.avatar!.trim().isNotEmpty && !_isLetterAvatar(vendor.avatar)) {
      coverPath = vendor.avatar!.trim();
    } else if (vendor.photo != null && vendor.photo!.trim().isNotEmpty) {
      coverPath = vendor.photo!.trim();
    } else if (vendor.avatar != null && vendor.avatar!.trim().isNotEmpty) {
      coverPath = vendor.avatar!.trim();
    }
    final String coverUrl = _formatImageUrl(coverPath);

    return SizedBox(
      height: 255.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Cover Photo in Background (Height: 195.h)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 195.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colors.shimmerBase),
                        errorWidget: (_, __, ___) => _placeholderCoverBg(colors),
                      )
                    : _placeholderCoverBg(colors),

                // Top Gradient for Action Buttons
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 85.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Top Action Buttons (Back button & Favorite button)
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button (Right in RTL)
                CustomArrowBack(
                  color: Colors.white,
                  iconColor: Colors.black87,
                  isCircular: true,
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.all(8.r),
                ),

                // Favorite Button (Left in RTL)
                GestureDetector(
                  onTap: onFavoriteTap,
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      size: 18.sp,
                      color: isFavorite ? Colors.redAccent : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. White Floating Vendor Card (Drawn physically ON TOP OF cover photo)
          Positioned(
            top: 135.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.6),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Vendor Logo + Name/Subtitle + Arrow
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Vendor Logo Image next to name
                      Container(
                        width: 58.r,
                        height: 58.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11.r),
                          child: _buildVendorLogoImage(colors),
                        ),
                      ),
                      12.horizontalSpace,

                      // Vendor Name, Subtitle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    vendor.name ?? (isMarket ? 'المتجر' : 'المطعم'),
                                    style: AppTextStyles.text16w700(color: colors.textPrimary),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isBusy) ...[
                                  6.horizontalSpace,
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.orange,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'مشغول',
                                      style: AppTextStyles.text10w500(color: Colors.white),
                                    ),
                                  ),
                                ] else if (isClosed) ...[
                                  6.horizontalSpace,
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: Text(
                                      'مغلق',
                                      style: AppTextStyles.text10w500(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            3.verticalSpace,
                            Text(
                              _getCuisineSubtitle(),
                              style: AppTextStyles.text12w400(color: colors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Left Details Chevron (points left <)
                      GestureDetector(
                        onTap: () => _showVendorInfoSheet(context),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: EdgeInsets.all(4.r),
                          child: Transform.flip(
                            flipX: true,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 16.sp,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  12.verticalSpace,

                  // Row 2: Delivery Info Row (Time • Provider)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 15.sp,
                              color: colors.textSecondary,
                            ),
                            4.horizontalSpace,
                            Text(
                              '٣٠-٩٠ دقيقة',
                              style: AppTextStyles.text12w600(color: colors.textPrimary),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            '•',
                            style: TextStyle(color: colors.border, fontSize: 13.sp),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'التوصيل من ',
                              style: AppTextStyles.text11w400(color: colors.textSecondary),
                            ),
                            Text(
                              'Quick',
                              style: AppTextStyles.text13w700(color: colors.primary),
                            ),
                            3.horizontalSpace,
                            Icon(
                              Icons.info_outline_rounded,
                              size: 13.sp,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
