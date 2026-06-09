// lib/features/auth/presentation/riverpod/auth_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/network/api_result.dart';
import '../../data/auth_api_service.dart';
import '../../data/models/auth_models.dart';

part 'auth_provider.g.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserDto? user;
  final String? errorMessage;
  final int? statusCode;

  AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.statusCode,
  });

  factory AuthState.initial() => AuthState(status: AuthStatus.initial);
  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(UserDto user) => AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() => AuthState(status: AuthStatus.unauthenticated);
  factory AuthState.error(String message, {int? statusCode}) => AuthState(status: AuthStatus.error, errorMessage: message, statusCode: statusCode);

  AuthState copyWith({
    AuthStatus? status,
    UserDto? user,
    String? errorMessage,
    int? statusCode,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      statusCode: statusCode ?? this.statusCode,
    );
  }
}

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  AuthState build() {
    final token = CacheHelper.getString(CacheKeys.token);
    if (token != null && token.isNotEmpty) {
      final role = CacheHelper.getInt('userRole') ?? 0;
      return AuthState.authenticated(UserDto(id: 0, role: role, status: 0));
    }
    return AuthState.initial();
  }

  /// Sets the authentication state to authenticated directly (e.g. after OTP)
  void setAuthenticated() {
    final role = CacheHelper.getInt('userRole') ?? 0;
    state = AuthState.authenticated(UserDto(id: 0, role: role, status: 0));
  }

  /// Perform authentication
  Future<bool> login({
    required String phone,
    required String password,
    required bool isUser,
  }) async {
    state = AuthState.loading();
    final result = await ref.read(authApiServiceProvider).login(phone: phone, password: password);
    
    return result.when(
      success: (response) async {
        if (response.success && response.result != null) {
          final tokenDto = response.result!;
          if (tokenDto.accessToken != null) {
            await CacheHelper.setString(CacheKeys.token, tokenDto.accessToken!);
          }
          if (tokenDto.refreshToken != null) {
            await CacheHelper.setString('refreshToken', tokenDto.refreshToken!);
          }
          
          // Cache the user role!
          await CacheHelper.setInt('userRole', isUser ? 0 : 1);
          
          state = AuthState.authenticated(UserDto(id: 0, role: isUser ? 0 : 1, status: 0));
          return true;
        } else {
          state = AuthState.error(response.message ?? "Authentication failed", statusCode: response.statusCode);
          return false;
        }
      },
      failure: (error) async {
        if (error.statusCode == 330 && error.data is Map<String, dynamic>) {
          final dataMap = error.data as Map<String, dynamic>;
          final result = dataMap['result'];
          String? tempToken;
          if (result is Map<String, dynamic>) {
            tempToken = result['accessToken'] as String? ?? result['token'] as String?;
          } else if (result is String) {
            tempToken = result;
          }
          if (tempToken == null || tempToken.isEmpty) {
            tempToken = dataMap['accessToken'] as String? ?? dataMap['token'] as String?;
          }
          if (tempToken != null && tempToken.isNotEmpty) {
            await CacheHelper.setString('tempToken', tempToken);
          }
        }
        state = AuthState.error(error.message, statusCode: error.statusCode);
        return false;
      },
    );
  }

  /// Perform registration
  Future<bool> register({
    required String phone,
    required String name,
    required String password,
    required String confirmedPassword,
    required int role, // 0: customer, 1: driver
    String? email,
    String? address,
    String? photo,
    LocationModel? location,
    String? description,
  }) async {
    state = AuthState.loading();
    final result = await ref.read(authApiServiceProvider).signup(
      phone: phone,
      name: name,
      password: password,
      confirmedPassword: confirmedPassword,
      role: role,
      email: email,
      address: address,
      photo: photo,
      location: location,
      description: description,
    );

    return result.when(
      success: (response) async {
        if (response.success && response.result != null) {
          final tokenDto = response.result!;
          
          // Store token in 'tempToken' as requested instead of the main token key
          if (tokenDto.accessToken != null) {
            await CacheHelper.setString('tempToken', tokenDto.accessToken!);
          }
          if (tokenDto.refreshToken != null) {
            await CacheHelper.setString('refreshToken', tokenDto.refreshToken!);
          }
          
          // Cache the user role!
          await CacheHelper.setInt('userRole', role);
          
          state = AuthState.unauthenticated(); // Require OTP verification first
          return true;
        } else {
          state = AuthState.error(response.message ?? "Registration failed", statusCode: response.statusCode);
          return false;
        }
      },
      failure: (error) {
        state = AuthState.error(error.message, statusCode: error.statusCode);
        return false;
      },
    );
  }

  /// Logout
  Future<void> logout() async {
    state = AuthState.loading();
    await ref.read(authApiServiceProvider).logout();
    await CacheHelper.remove(CacheKeys.token);
    await CacheHelper.remove('refreshToken');
    await CacheHelper.remove('userRole');
    state = AuthState.unauthenticated();
  }
}
