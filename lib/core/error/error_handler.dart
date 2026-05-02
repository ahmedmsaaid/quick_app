import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'app_error.dart';
import 'error_configs.dart';
import 'http_errors.dart';

AppError handleError(Object exception) {
  // Network connectivity issues
  if (exception is SocketException) {
    return const NetworkError(
      message: "No internet connection. Please check your network.",
    );
  }

  // HTTP client errors (Dio)
  if (exception is DioException) {
    return _handleDioError(exception);
  }

  // Firebase authentication errors
  if (exception is FirebaseAuthException) {
    return _handleFirebaseError(exception);
  }

  // Format exceptions (JSON parsing, etc.)
  if (exception is FormatException) {
    return ParseError(
      message: "Invalid data format: ${exception.message}",
      data: exception,
    );
  }

  // Type errors
  if (exception is TypeError) {
    return const ParseError(message: "Data type mismatch occurred.");
  }

  // Already an AppError
  if (exception is AppError) {
    return exception;
  }

  // Generic fallback
  return GenericError(
    message: "Something went wrong. Please try again.",
    data: exception,
  );
}

AppError _handleDioError(DioException exception) {
  // Handle socket exceptions within Dio
  if (exception.error is SocketException) {
    return const NetworkError(
      message: "No internet connection. Please check your network.",
    );
  }

  // Handle by DioExceptionType
  switch (exception.type) {
    case DioExceptionType.connectionError:
      return const NetworkError(
        message: "Connection error. Please check your internet connection.",
      );

    case DioExceptionType.receiveTimeout:
      return const TimeoutError(
        message: "Server took too long to respond. Please try again.",
      );

    case DioExceptionType.sendTimeout:
      return const TimeoutError(
        message: "Request timeout. Please check your connection.",
      );

    case DioExceptionType.connectionTimeout:
      return const TimeoutError(
        message: "Connection timeout. Please try again.",
      );

    case DioExceptionType.cancel:
      return const GenericError(message: "Request was cancelled.");

    case DioExceptionType.badResponse:
      return _handleHttpStatusCode(exception);

    case DioExceptionType.badCertificate:
      return const GenericError(
        message: "Security certificate error. Please contact support.",
      );

    case DioExceptionType.unknown:
      if (exception.error is SocketException) {
        return const NetworkError(
          message: "No internet connection. Please check your network.",
        );
      }
      return GenericError(
        message: "Unexpected error occurred. Please try again.",
        data: exception.error,
      );
  }
}

AppError _handleHttpStatusCode(DioException exception) {
  final statusCode = exception.response?.statusCode;
  final responseData = exception.response?.data;

  // Extract error message from response
  String? serverMessage;
  if (responseData is Map<String, dynamic>) {
    serverMessage =
        responseData['message'] as String? ??
        responseData['error'] as String? ??
        responseData['msg'] as String?;
  } else if (responseData is String) {
    serverMessage = responseData;
  }

  // Check if we have a configuration for this status code
  if (statusCode != null) {
    final config = HttpErrorConfigs.getByStatusCode(statusCode);
    if (config != null) {
      return config.errorBuilder(
        serverMessage ?? config.defaultMessage,
        responseData,
      );
    }
  }

  // Fallback for other 4xx or 5xx errors
  if (statusCode != null && statusCode >= 400 && statusCode < 500) {
    return BadRequestError(
      message: serverMessage ?? "Client error occurred (Code: $statusCode).",
      statusCode: statusCode,
      data: responseData,
    );
  } else if (statusCode != null && statusCode >= 500) {
    return InternalServerError(
      message: serverMessage ?? "Server error occurred (Code: $statusCode).",
      statusCode: statusCode,
      data: responseData,
    );
  }

  // Unknown error
  return GenericError(
    message: serverMessage ?? "Unexpected error from server.",
    statusCode: statusCode,
    data: responseData,
  );
}

AppError _handleFirebaseError(FirebaseException exception) {
  final config = FirebaseErrorConfigs.getByCode(exception.code);

  final message =
      config?.message ?? exception.message ?? "Authentication error occurred.";

  return GenericError(message: message, data: exception);
}
