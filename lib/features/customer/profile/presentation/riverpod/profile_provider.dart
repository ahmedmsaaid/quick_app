// lib/features/profile/presentation/riverpod/profile_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';

part 'profile_provider.g.dart';

enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileState {
  final ProfileStatus status;
  final UserDto? user;
  final List<LocationDto> locations;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.locations = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserDto? user,
    List<LocationDto>? locations,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      locations: locations ?? this.locations,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() => const ProfileState();

  /// Loads user profile and user locations from the backend.
  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    
    final profileResult = await ref.read(profileApiServiceProvider).getProfile();
    
    UserDto? user;
    List<LocationDto> locations = [];
    String? errorMessage;
    
    profileResult.when(
      success: (response) {
        if (response.success && response.result != null) {
          user = response.result;
        } else {
          errorMessage = response.message;
        }
      },
      failure: (error) {
        errorMessage = error.message;
      },
    );

    if (user != null) {
      final locationsResult = await ref.read(profileApiServiceProvider).getLocations(creatorId: user!.id);
      locationsResult.when(
        success: (response) {
          if (response.success && response.result != null) {
            locations = response.result!;
          }
        },
        failure: (error) {
          // locations loading failure shouldn't block profile loading entirely,
          // but we can log or keep locations as empty
        },
      );
    }

    if (user != null) {
      state = ProfileState(
        status: ProfileStatus.loaded,
        user: user,
        locations: locations,
      );
    } else {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: errorMessage ?? 'Failed to load profile',
      );
    }
  }

  /// Update profile fields (name, email, address, photo, description).
  Future<bool> updateProfile({
    String? name,
    String? email,
    String? address,
    String? photo,
    String? description,
    LocationModel? location,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);
    final currentUser = state.user;

    final result = await ref.read(profileApiServiceProvider).updateProfile(
          name: name ?? currentUser?.name,
          email: email ?? currentUser?.email,
          address: address ?? currentUser?.address,
          photo: photo ?? currentUser?.photo ?? currentUser?.avatar,
          description: description ?? "", // Assuming default empty if null
          location: location ?? currentUser?.location,
        );
    return result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = ProfileState(
            status: ProfileStatus.loaded,
            user: response.result,
            locations: state.locations,
          );
          return true;
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message,
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Upload a new profile photo and then update the profile.
  Future<bool> uploadAndUpdatePhoto(dynamic file) async {
    state = state.copyWith(status: ProfileStatus.updating);
    final uploadResult =
        await ref.read(profileApiServiceProvider).uploadProfilePhoto(file);
    return uploadResult.when(
      success: (photoUrl) async {
        return await updateProfile(photo: photoUrl);
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Change the user's password.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmedNewPassword,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);
    final result = await ref.read(profileApiServiceProvider).changePassword(
          oldPassword: oldPassword,
          newPassword: newPassword,
          confirmedNewPassword: confirmedNewPassword,
        );
    return result.when(
      success: (response) {
        if (response.success) {
          state = state.copyWith(status: ProfileStatus.loaded);
          return true;
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message,
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Save the user's base address via locations endpoint.
  Future<bool> saveAddress({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    return addAddress(
      address: address,
      latitude: latitude,
      longitude: longitude,
      base: true,
    );
  }

  /// Add a new address/location.
  Future<bool> addAddress({
    required String address,
    required double latitude,
    required double longitude,
    required bool base,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);

    // Workaround: Reset other base addresses manually because the backend allows multiple base:true 
    // and its PUT endpoint is broken, so we recreate old base entries as base:false.
    if (base) {
      final oldBases = state.locations.where((l) => l.base).toList();
      for (final oldLoc in oldBases) {
        await ref.read(profileApiServiceProvider).deleteLocation(oldLoc.id);
        await ref.read(profileApiServiceProvider).addLocation(
              address: oldLoc.address ?? '',
              latitude: oldLoc.latitude,
              longitude: oldLoc.longitude,
              base: false,
            );
      }
    }

    final result = await ref.read(profileApiServiceProvider).addLocation(
          address: address,
          latitude: latitude,
          longitude: longitude,
          base: base,
        );
    return result.when(
      success: (response) async {
        if (response.success) {
          // If setting as base, also update the user's main profile
          if (base) {
            await ref.read(profileApiServiceProvider).updateProfile(
                  address: address,
                  location: LocationModel(latitude: latitude, longitude: longitude),
                );
          }
          await loadProfile(); // Reload to refresh both user profile and locations
          return true;
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message,
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Update an existing address/location. (Workaround: DELETE + POST because PUT endpoint returns 500)
  Future<bool> updateAddress({
    required int id,
    required String address,
    required double latitude,
    required double longitude,
    required bool base,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);

    // Reset other base addresses if setting this one as base
    if (base) {
      final oldBases = state.locations.where((l) => l.base && l.id != id).toList();
      for (final oldLoc in oldBases) {
        await ref.read(profileApiServiceProvider).deleteLocation(oldLoc.id);
        await ref.read(profileApiServiceProvider).addLocation(
              address: oldLoc.address ?? '',
              latitude: oldLoc.latitude,
              longitude: oldLoc.longitude,
              base: false,
            );
      }
    }

    // Delete old location entry
    final deleteResult = await ref.read(profileApiServiceProvider).deleteLocation(id);
    bool deleteSuccess = false;
    deleteResult.when(
      success: (response) {
        if (response.success) {
          deleteSuccess = true;
        }
      },
      failure: (_) {},
    );

    if (!deleteSuccess) {
      state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: "فشل تحديث العنوان: غير قادر على تعديل الإدخال القديم",
      );
      return false;
    }

    // Create updated location entry
    final addResult = await ref.read(profileApiServiceProvider).addLocation(
          address: address,
          latitude: latitude,
          longitude: longitude,
          base: base,
        );

    return addResult.when(
      success: (response) async {
        if (response.success) {
          // If setting as base, also update user's main profile
          if (base) {
            await ref.read(profileApiServiceProvider).updateProfile(
                  address: address,
                  location: LocationModel(latitude: latitude, longitude: longitude),
                );
          }
          await loadProfile(); // Reload to refresh both user profile and locations
          return true;
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message,
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Delete an address/location by ID.
  Future<bool> deleteAddress(int id) async {
    state = state.copyWith(status: ProfileStatus.updating);
    final result = await ref.read(profileApiServiceProvider).deleteLocation(id);
    return result.when(
      success: (response) async {
        if (response.success) {
          await loadProfile(); // Reload to refresh both user profile and locations
          return true;
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message,
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Set a location as base (default).
  Future<bool> setBaseAddress(LocationDto location) async {
    return updateAddress(
      id: location.id,
      address: location.address ?? '',
      latitude: location.latitude,
      longitude: location.longitude,
      base: true,
    );
  }
}
