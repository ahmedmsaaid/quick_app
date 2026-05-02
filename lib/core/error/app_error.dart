import 'package:equatable/equatable.dart';

abstract class AppError extends Equatable {
  final String message;
  final int? statusCode;
  final dynamic data;

  const AppError({required this.message, this.statusCode, this.data});

  @override
  List<Object?> get props => [message, statusCode, data];
}

class GenericError extends AppError {
  const GenericError({required super.message, super.statusCode, super.data});
}

class NetworkError extends AppError {
  const NetworkError({
    super.message = "No internet connection. Please check your network.",
  });
}

class TimeoutError extends AppError {
  const TimeoutError({super.message = "Request timeout. Please try again."});
}

class ParseError extends AppError {
  const ParseError({
    super.message = "Failed to parse data from server.",
    super.data,
  });
}

class CacheError extends AppError {
  const CacheError({super.message = "Failed to load cached data.", super.data});
}
