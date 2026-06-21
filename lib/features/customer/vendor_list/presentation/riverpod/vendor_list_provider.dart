import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';

part 'vendor_list_provider.g.dart';

enum VendorListStatus { initial, loading, loaded, error }

class VendorListState {
  final VendorListStatus status;
  final List<UserDto> vendors;
  final String? errorMessage;

  const VendorListState({
    this.status = VendorListStatus.initial,
    this.vendors = const [],
    this.errorMessage,
  });

  VendorListState copyWith({
    VendorListStatus? status,
    List<UserDto>? vendors,
    String? errorMessage,
  }) {
    return VendorListState(
      status: status ?? this.status,
      vendors: vendors ?? this.vendors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class VendorListNotifier extends _$VendorListNotifier {
  @override
  VendorListState build(int role, {int? categoryId}) {
    // Automatically load vendors on build
    Future.microtask(() => loadVendors(categoryId: categoryId));
    return const VendorListState();
  }

  Future<void> loadVendors({bool orderByRate = false, int? categoryId}) async {
    state = state.copyWith(status: VendorListStatus.loading);

    final result = await ref.read(homeApiServiceProvider).getUsersPaginate(
      role: role,
      orderByRate: orderByRate ? true : null,
      categoryId: categoryId,
      pageSize: 50,
    );

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = VendorListState(
            status: VendorListStatus.loaded,
            vendors: response.result!,
          );
        } else {
          state = state.copyWith(
            status: VendorListStatus.error,
            errorMessage: response.message ?? 'فشل تحميل المحلات',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: VendorListStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }
}
