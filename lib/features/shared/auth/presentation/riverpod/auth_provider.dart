// lib/features/auth/presentation/riverpod/auth_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/utils/jwt_helper.dart';
import 'package:base_app/features/shared/auth/data/auth_api_service.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/core/services/push_notification/push_notification_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/core/providers/auth_state_provider.dart';
import 'dart:developer' as dev;

part 'auth_provider.g.dart';

/// Flag to ensure GoogleSignIn is initialized only once (required in v7.x)
bool _googleSignInInitialized = false;

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
      ref.read(guestModeProvider.notifier).state = false;
      final decodedRole = JwtHelper.getRoleFromToken(token);
      final role = decodedRole?.value ?? (CacheHelper.getInt('userRole') ?? 2);
      return AuthState.authenticated(UserDto(id: 0, role: role, status: 0));
    }
    return AuthState.initial();
  }

  /// Sets the authentication state to authenticated directly (e.g. after OTP)
  void setAuthenticated() {
    ref.invalidate(profileProvider);
    ref.read(guestModeProvider.notifier).state = false;
    final token = CacheHelper.getString(CacheKeys.token);
    final decodedRole = token != null ? JwtHelper.getRoleFromToken(token) : null;
    final role = decodedRole?.value ?? (CacheHelper.getInt('userRole') ?? 2);
    CacheHelper.setInt('userRole', role);
    ref.read(pushNotificationServiceProvider).registerDeviceTokenWithBackend();
    state = AuthState.authenticated(UserDto(id: 0, role: role, status: 0));
  }

  /// Perform authentication
  Future<bool> login({
    required String countryCode,
    required String rawPhone,
    required String password,
    required bool isUser,
  }) async {
    state = AuthState.loading();

    var normalizedPhone = rawPhone.trim();
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = normalizedPhone.substring(1);
    }
    final fullPhone = "+$countryCode$normalizedPhone";

    final result = await ref.read(authApiServiceProvider).login(phone: fullPhone, password: password);
    
    return result.when(
      success: (response) async {
        if (response.success && response.result != null) {
          final tokenDto = response.result!;
          final token = tokenDto.accessToken;
          final RoleTypeEnum? decodedRole =
              token != null ? JwtHelper.getRoleFromToken(token) : null;

          // Enforce role separation: Customer (role 2) vs Captain/Driver (role 3)
          if (isUser && decodedRole != null && decodedRole != RoleTypeEnum.customer) {
            final String msg = decodedRole == RoleTypeEnum.captain
                ? "هذا الحساب مسجل كمندوب توصيل. يرجى تسجيل الدخول من بوابة المندوب."
                : "غير مصرح لهذا الحساب بالدخول كعميل.";
            state = AuthState.error(msg);
            return false;
          }

          if (!isUser && decodedRole != null && decodedRole != RoleTypeEnum.captain) {
            final String msg = decodedRole == RoleTypeEnum.customer
                ? "هذا الحساب مسجل كعميل. يرجى تسجيل الدخول من بوابة العميل."
                : "غير مصرح لهذا الحساب بالدخول كمندوب توصيل.";
            state = AuthState.error(msg);
            return false;
          }

          final int resolvedRole = decodedRole?.value ?? (isUser ? 2 : 3);

          if (token != null) {
            await CacheHelper.setString(CacheKeys.token, token);
          }
          if (tokenDto.refreshToken != null) {
            await CacheHelper.setString('refreshToken', tokenDto.refreshToken!);
          }
          
          // Reset guest mode
          ref.read(guestModeProvider.notifier).state = false;

          // Cache the user role!
          await CacheHelper.setInt('userRole', resolvedRole);
          
          // Register FCM token with backend immediately upon login!
          ref.read(pushNotificationServiceProvider).registerDeviceTokenWithBackend();
          
          state = AuthState.authenticated(UserDto(id: 0, role: resolvedRole, status: 0));
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
            final decodedRole = JwtHelper.getRoleFromToken(tempToken);
            if (isUser && decodedRole != null && decodedRole != RoleTypeEnum.customer) {
              final String msg = decodedRole == RoleTypeEnum.captain
                  ? "هذا الحساب مسجل كمندوب توصيل. يرجى تسجيل الدخول من بوابة المندوب."
                  : "غير مصرح لهذا الحساب بالدخول كعميل.";
              state = AuthState.error(msg);
              return false;
            }
            if (!isUser && decodedRole != null && decodedRole != RoleTypeEnum.captain) {
              final String msg = decodedRole == RoleTypeEnum.customer
                  ? "هذا الحساب مسجل كعميل. يرجى تسجيل الدخول من بوابة العميل."
                  : "غير مصرح لهذا الحساب بالدخول كمندوب توصيل.";
              state = AuthState.error(msg);
              return false;
            }
            await CacheHelper.setString('tempToken', tempToken);
          }
          // Cache temporary phone for OTP verification
          await CacheHelper.setString('temp_phone', fullPhone);
        }
        state = AuthState.error(error.message, statusCode: error.statusCode);
        return false;
      },
    );
  }

  /// Perform registration
  Future<bool> register({
    required String countryCode,
    required String rawPhone,
    required String name,
    required String password,
    required String confirmedPassword,
    required int role, // 2: customer, 3: driver
    String? email,
    String? address,
    LocationModel? location,
    String? photo,
    String? description,
    String? invitationCode,
  }) async {
    state = AuthState.loading();

    var normalizedPhone = rawPhone.trim();
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = normalizedPhone.substring(1);
    }
    final fullPhone = "+$countryCode$normalizedPhone";

    // Cache temporary phone for OTP resends or confirmation checks
    await CacheHelper.setString('temp_phone', fullPhone);

    final result = await ref.read(authApiServiceProvider).signup(
      phone: fullPhone,
      name: name,
      password: password,
      confirmedPassword: confirmedPassword,
      role: role,
      email: email,
      address: address,
      photo: photo,
      location: location,
      description: description,
      invitationCode: invitationCode,
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
    ref.read(guestModeProvider.notifier).state = false;
    ref.invalidate(profileProvider);
    state = AuthState.unauthenticated();
  }

  /// Perform Google authentication login
  Future<bool> loginWithGoogle({
    required bool isUser,
  }) async {
    state = AuthState.loading();
    final role = isUser ? 2 : 3;
    dev.log("🚀 [GoogleAuth] Starting Google Sign-In (isUser: $isUser, targetRole: $role)", name: 'GoogleAuth');

    try {
      final googleSignIn = GoogleSignIn.instance;

      if (!_googleSignInInitialized) {
        dev.log("🔄 [GoogleAuth] Initializing GoogleSignIn with serverClientId: ${ApiConstants.googleServerClientId}...", name: 'GoogleAuth');
        await googleSignIn.initialize(
          serverClientId: ApiConstants.googleServerClientId,
        );
        _googleSignInInitialized = true;
        dev.log("✅ [GoogleAuth] GoogleSignIn initialized successfully.", name: 'GoogleAuth');
      }

      dev.log("📱 [GoogleAuth] Calling googleSignIn.authenticate(scopeHint: ['email'])...", name: 'GoogleAuth');
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: ['email'],
      );

      dev.log("👤 [GoogleAuth] User signed in with Google: email=${googleUser.email}, displayName=${googleUser.displayName}", name: 'GoogleAuth');

      final GoogleSignInAuthentication googleAuthDetails = googleUser.authentication;
      final idToken = googleAuthDetails.idToken;

      dev.log("🔑 [GoogleAuth] idToken received: ${idToken != null ? 'Length: ${idToken.length} (Starts with: ${idToken.substring(0, idToken.length > 25 ? 25 : idToken.length)}...)' : 'NULL'}", name: 'GoogleAuth');

      if (idToken == null || idToken.isEmpty) {
        dev.log("❌ [GoogleAuth] idToken is null or empty!", name: 'GoogleAuth');
        state = AuthState.error("فشل الحصول على رمز تعريف جوجل (idToken)");
        return false;
      }

      dev.log("🌐 [GoogleAuth] Sending POST /api/v1/users/google-auth with role=$role...", name: 'GoogleAuth');
      final result = await ref.read(authApiServiceProvider).googleAuth(
        idToken: idToken,
        role: role,
      );

      return await result.when(
        success: (response) async {
          dev.log("📥 [GoogleAuth] Backend response: success=${response.success}, statusCode=${response.statusCode}, message=${response.message}", name: 'GoogleAuth');

          if (response.success && response.result != null) {
            final tokenDto = response.result!;
            final token = tokenDto.accessToken;
            final RoleTypeEnum? decodedRole =
                token != null ? JwtHelper.getRoleFromToken(token) : null;

            dev.log("🎟️ [GoogleAuth] Token decoded role: $decodedRole", name: 'GoogleAuth');

            // Enforce role separation: Customer (role 2) vs Captain/Driver (role 3)
            if (isUser && decodedRole != null && decodedRole != RoleTypeEnum.customer) {
              final String msg = decodedRole == RoleTypeEnum.captain
                  ? "هذا الحساب مسجل كمندوب توصيل. يرجى تسجيل الدخول من بوابة المندوب."
                  : "غير مصرح لهذا الحساب بالدخول كعميل.";
              dev.log("⚠️ [GoogleAuth] Role mismatch: $msg", name: 'GoogleAuth');
              state = AuthState.error(msg);
              return false;
            }

            if (!isUser && decodedRole != null && decodedRole != RoleTypeEnum.captain) {
              final String msg = decodedRole == RoleTypeEnum.customer
                  ? "هذا الحساب مسجل كعميل. يرجى تسجيل الدخول من بوابة العميل."
                  : "غير مصرح لهذا الحساب بالدخول كمندوب توصيل.";
              dev.log("⚠️ [GoogleAuth] Role mismatch: $msg", name: 'GoogleAuth');
              state = AuthState.error(msg);
              return false;
            }

            final int resolvedRole = decodedRole?.value ?? role;

            if (token != null) {
              await CacheHelper.setString(CacheKeys.token, token);
            }
            if (tokenDto.refreshToken != null) {
              await CacheHelper.setString('refreshToken', tokenDto.refreshToken!);
            }

            // Reset guest mode
            ref.read(guestModeProvider.notifier).state = false;

            // Cache the user role!
            await CacheHelper.setInt('userRole', resolvedRole);

            // Register FCM token with backend immediately upon login!
            ref.read(pushNotificationServiceProvider).registerDeviceTokenWithBackend();

            dev.log("🎉 [GoogleAuth] Login completed successfully! User Role: $resolvedRole", name: 'GoogleAuth');
            state = AuthState.authenticated(UserDto(id: 0, role: resolvedRole, status: 0));
            return true;
          } else {
            final errorMsg = response.message ?? "فشل تسجيل الدخول بـ جوجل";
            dev.log("❌ [GoogleAuth] API returned unsuccess response: $errorMsg (code: ${response.statusCode})", name: 'GoogleAuth');
            state = AuthState.error(errorMsg, statusCode: response.statusCode);
            return false;
          }
        },
        failure: (error) async {
          dev.log("❌ [GoogleAuth] API call failure: ${error.message} (statusCode: ${error.statusCode})", name: 'GoogleAuth');
          state = AuthState.error(error.message, statusCode: error.statusCode);
          return false;
        },
      );
    } catch (e, stackTrace) {
      dev.log("💥 [GoogleAuth] Exception caught during Google Sign-In!", name: 'GoogleAuth', error: e, stackTrace: stackTrace);
      if (e is GoogleSignInException) {
        dev.log("🔍 [GoogleAuth] GoogleSignInException code: ${e.code}, description: ${e.description}", name: 'GoogleAuth');
        if (e.code == GoogleSignInExceptionCode.canceled) {
          dev.log("ℹ️ [GoogleAuth] User canceled Google Sign-In flow.", name: 'GoogleAuth');
          state = AuthState.initial();
          return false;
        }
      }
      state = AuthState.error("حدث خطأ أثناء تسجيل الدخول بـ جوجل: $e");
      return false;
    }
  }
}
