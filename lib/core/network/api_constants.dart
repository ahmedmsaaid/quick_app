abstract class ApiConstants {
  static const String baseUrl = 'https://quick-service.runasp.net/api/v1/';
  static const String streamUrl = 'https://gtranzimdtayekdgopoq.supabase.co/storage/v1/object/public/quick-service-photos/';
  static const String signup = 'users/signup';
  static const String login = 'users/login';
  static const String sendOtp = 'users/send-otp';
  static const String verifyOtp = 'users/verify-otp';
  static const String refreshToken = 'users/refresh-token';
  static const String logout = 'users/logout';
  static const String logoutAllDevices = 'users/logout-all-devices';
  static const String changePassword = 'users/change-password';
  static const String resetPassword = 'users/reset-password';
  static const String toggleActivity = 'users/toggle-activity';
  static const String profile = 'users';
  static const String getById = 'users/get-by-id';
  static const String updateProfile = 'users/update-profile';
  static const String deleteAccount = 'users/delete-account';
  static const String addFcmToken = 'users/add-fcm-token';
  static const String stream = 'stream';
  static const String streamPublic = 'stream/public';
}
