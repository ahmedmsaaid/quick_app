// lib/features/profile/presentation/riverpod/profile_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/auth/data/models/auth_models.dart';
import '../../data/profile_api_service.dart';

part 'profile_provider.g.dart';

enum ProfileStatus { initial, loading, loaded, updating, error }

class ProfileState {
  final ProfileStatus status;
  final UserDto? user;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserDto? user,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class ProfileNotifier extends _$ProfileNotifier {
  @override
  ProfileState build() => const ProfileState();

  /// Loads user profile from the backend.
  Future<void> loadProfile() async {

    state = state.copyWith(status: ProfileStatus.loading);
    final result = await ref.read(profileApiServiceProvider).getProfile();
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = ProfileState(
            status: ProfileStatus.loaded,
            user: response.result,
          );
        } else {
          state = state.copyWith(
            status: ProfileStatus.error,
            errorMessage: response.message,
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        );
      },
    );
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
}
