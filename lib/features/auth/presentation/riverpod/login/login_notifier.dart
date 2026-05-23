import 'package:flutter_riverpod/legacy.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'login_state.dart';
import '../../../data/models/user_model.dart';

class LoginNotifier extends StateNotifier<LoginState> {
  LoginNotifier() : super(const LoginState.initial());

  Future<void> login({
    required String phone,
    required String password,
    required bool isUser,
  }) async {
    state = const LoginState.loading();

    try {
      // Mocking login for now
      await Future.delayed(const Duration(seconds: 2));

      if (phone == "0123456789" && password == "123456") {
        final mockUser = UserModel(
          id: "1",
          name: isUser ? "Ahmed Customer" : "Mohamed Captain",
          phone: phone,
          role: isUser ? "customer" : "driver",
          token: "mock_token_123",
        );

        // Save to cache
        await CacheHelper.setString(CacheKeys.token, mockUser.token);
        
        state = LoginState.success(mockUser);
      } else {
        state = const LoginState.error("رقم الهاتف أو كلمة المرور غير صحيحة");
      }
    } catch (e) {
      state = LoginState.error(e.toString());
    }
  }
}

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier();
});
