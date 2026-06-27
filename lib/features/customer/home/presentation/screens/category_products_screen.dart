import 'package:base_app/core/exports/exports.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({super.key, required this.category});

  final CategoryDto category;

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<ProductDetailDto> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(homeApiServiceProvider).getProductsByCategory(
      categoryId: widget.category.id,
    );

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          setState(() {
            _products = response.result!;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message ?? 'فشل تحميل المنتجات';
            _isLoading = false;
          });
        }
      },
      failure: (error) {
        setState(() {
          _errorMessage = error.message;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          widget.category.name ?? '',
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final colors = AppColors(context);

    if (_isLoading) {
      return const LoadingButton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: colors.error),
              10.verticalSpace,
              Text(
                _errorMessage!,
                style: AppTextStyles.text14w500(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              15.verticalSpace,
              ElevatedButton(
                onPressed: _loadProducts,
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 64.sp, color: colors.textHint),
            10.verticalSpace,
            Text(
              'لا توجد منتجات في هذا القسم حالياً',
              style: AppTextStyles.text16w600(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: _products.length,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductItem(context, product);
      },
    );
  }

  Widget _buildProductItem(BuildContext context, ProductDetailDto product) {
    final colors = AppColors(context);
    final String? photo = product.photo;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.storeProductDetailsScreen,
        arguments: {
          'product': product,
          'vendorId': widget.category.creatorId,
        },
      ),
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 70.w,
                        height: 70.h,
                        color: colors.border.withValues(alpha: 0.5),
                      ),
                      errorWidget: (context, url, error) => Image.asset('assets/image/logo.png', width: 70.w, height: 70.h, fit: BoxFit.cover),
                    )
                  : Image.asset('assets/image/logo.png', width: 70.w, height: 70.h, fit: BoxFit.cover),
            ),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  5.verticalSpace,
                  Text(
                    product.description ?? '',
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.hasDiscount ? (product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(0) : product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: AppTextStyles.text14w700(color: colors.primary),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          4.horizontalSpace,
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: AppTextStyles.text12w600(color: colors.textPrimary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            10.horizontalSpace,
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: colors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
