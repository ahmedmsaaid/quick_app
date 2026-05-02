import 'app_error.dart';
import 'http_errors.dart';

class HttpErrorConfig {
  final int statusCode;
  final String defaultMessage;
  final AppError Function(String message, dynamic data) errorBuilder;

  const HttpErrorConfig({
    required this.statusCode,
    required this.defaultMessage,
    required this.errorBuilder,
  });
}

class HttpErrorConfigs {
  static final List<HttpErrorConfig> all = [
    // 4xx Client Errors
    HttpErrorConfig(
      statusCode: 400,
      defaultMessage: "Bad request. Please check your input.",
      errorBuilder: (msg, data) => BadRequestError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 401,
      defaultMessage: "Unauthorized. Please login again.",
      errorBuilder: (msg, data) => UnauthorizedError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 403,
      defaultMessage: "Access forbidden. You don't have permission.",
      errorBuilder: (msg, data) => ForbiddenError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 404,
      defaultMessage: "Resource not found.",
      errorBuilder: (msg, data) => NotFoundError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 405,
      defaultMessage: "Method not allowed.",
      errorBuilder: (msg, data) =>
          MethodNotAllowedError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 409,
      defaultMessage: "Conflict occurred. Resource already exists.",
      errorBuilder: (msg, data) => ConflictError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 422,
      defaultMessage: "Unable to process your request.",
      errorBuilder: (msg, data) =>
          UnprocessableEntityError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 429,
      defaultMessage: "Too many requests. Please try again later.",
      errorBuilder: (msg, data) =>
          TooManyRequestsError(message: msg, data: data),
    ),

    // 5xx Server Errors
    HttpErrorConfig(
      statusCode: 500,
      defaultMessage: "Internal server error. Please try again later.",
      errorBuilder: (msg, data) =>
          InternalServerError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 501,
      defaultMessage: "Feature not implemented.",
      errorBuilder: (msg, data) =>
          NotImplementedError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 502,
      defaultMessage: "Bad gateway. Please try again.",
      errorBuilder: (msg, data) => BadGatewayError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 503,
      defaultMessage:
          "Service temporarily unavailable. Please try again later.",
      errorBuilder: (msg, data) =>
          ServiceUnavailableError(message: msg, data: data),
    ),
    HttpErrorConfig(
      statusCode: 504,
      defaultMessage: "Gateway timeout. Please try again.",
      errorBuilder: (msg, data) =>
          GatewayTimeoutError(message: msg, data: data),
    ),
  ];

  static final Map<int, HttpErrorConfig> _cache = {
    for (var config in all) config.statusCode: config,
  };

  static HttpErrorConfig? getByStatusCode(int statusCode) {
    return _cache[statusCode];
  }
}

class FirebaseErrorConfig {
  final String code;
  final String message;

  const FirebaseErrorConfig({required this.code, required this.message});
}

class FirebaseErrorConfigs {
  static final List<FirebaseErrorConfig> all = [
    // Account related
    const FirebaseErrorConfig(
      code: 'account-exists-with-different-credential',
      message: "Account exists with different credentials.",
    ),
    const FirebaseErrorConfig(
      code: 'credential-already-in-use',
      message: "Credential already in use.",
    ),
    const FirebaseErrorConfig(
      code: 'user-disabled',
      message: "This user account has been disabled.",
    ),
    const FirebaseErrorConfig(
      code: 'user-not-found',
      message: "User not found.",
    ),

    // Authentication related
    const FirebaseErrorConfig(
      code: 'invalid-credential',
      message:
          "The email or password is incorrect. Please check your credentials and try again.",
    ),
    const FirebaseErrorConfig(
      code: 'wrong-password',
      message: "Incorrect password.",
    ),
    const FirebaseErrorConfig(
      code: 'invalid-verification-code',
      message: "Invalid verification code.",
    ),
    const FirebaseErrorConfig(
      code: 'invalid-verification-id',
      message: "Invalid verification ID.",
    ),

    // Email related
    const FirebaseErrorConfig(
      code: 'email-already-in-use',
      message: "This email is already in use.",
    ),
    const FirebaseErrorConfig(
      code: 'invalid-email',
      message: "Invalid email address.",
    ),

    // Password related
    const FirebaseErrorConfig(
      code: 'weak-password',
      message: "Password is too weak. Please use a stronger password.",
    ),
    const FirebaseErrorConfig(
      code: 'requires-recent-login',
      message:
          "This operation requires recent authentication. Please login again.",
    ),

    // Operation related
    const FirebaseErrorConfig(
      code: 'operation-not-allowed',
      message: "This operation is not allowed.",
    ),
    const FirebaseErrorConfig(
      code: 'too-many-requests',
      message: "Too many requests. Please try again later.",
    ),

    // Network related
    const FirebaseErrorConfig(
      code: 'network-request-failed',
      message: "Network request failed. Please check your connection.",
    ),
    const FirebaseErrorConfig(
      code: 'internal-error',
      message: "Internal error occurred. Please try again.",
    ),

    // Token related
    const FirebaseErrorConfig(
      code: 'invalid-custom-token',
      message: "Invalid custom token.",
    ),
    const FirebaseErrorConfig(
      code: 'custom-token-mismatch',
      message: "Custom token mismatch.",
    ),

    // Provider related
    const FirebaseErrorConfig(
      code: 'provider-already-linked',
      message: "Provider already linked to this account.",
    ),
    const FirebaseErrorConfig(
      code: 'no-such-provider',
      message: "No such provider linked to this account.",
    ),

    // Session related
    const FirebaseErrorConfig(
      code: 'session-expired',
      message: "Session expired. Please login again.",
    ),
    const FirebaseErrorConfig(
      code: 'invalid-api-key',
      message: "Invalid API key.",
    ),
    const FirebaseErrorConfig(
      code: 'app-not-authorized',
      message: "App not authorized.",
    ),
  ];

  // Cache for fast lookup
  static final Map<String, FirebaseErrorConfig> _cache = {
    for (var config in all) config.code: config,
  };

  static FirebaseErrorConfig? getByCode(String code) {
    return _cache[code];
  }
}
