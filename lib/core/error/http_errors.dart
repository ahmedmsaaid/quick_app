import 'app_error.dart';

class BadRequestError extends AppError {
  const BadRequestError({
    super.message = "Bad request. Please check your input.",
    super.statusCode = 400,
    super.data,
  });
}

class UnauthorizedError extends AppError {
  const UnauthorizedError({
    super.message = "Unauthorized. Please login again.",
    super.statusCode = 401,
    super.data,
  });
}

class ForbiddenError extends AppError {
  const ForbiddenError({
    super.message = "Access forbidden. You don't have permission.",
    super.statusCode = 403,
    super.data,
  });
}

class NotFoundError extends AppError {
  const NotFoundError({
    super.message = "Resource not found.",
    super.statusCode = 404,
    super.data,
  });
}

class MethodNotAllowedError extends AppError {
  const MethodNotAllowedError({
    super.message = "Method not allowed.",
    super.statusCode = 405,
    super.data,
  });
}

class ConflictError extends AppError {
  const ConflictError({
    super.message = "Conflict occurred. Resource already exists.",
    super.statusCode = 409,
    super.data,
  });
}

class UnprocessableEntityError extends AppError {
  const UnprocessableEntityError({
    super.message = "Unable to process your request.",
    super.statusCode = 422,
    super.data,
  });
}

class TooManyRequestsError extends AppError {
  const TooManyRequestsError({
    super.message = "Too many requests. Please try again later.",
    super.statusCode = 429,
    super.data,
  });
}

class InternalServerError extends AppError {
  const InternalServerError({
    super.message = "Internal server error. Please try again later.",
    super.statusCode = 500,
    super.data,
  });
}

class NotImplementedError extends AppError {
  const NotImplementedError({
    super.message = "Feature not implemented.",
    super.statusCode = 501,
    super.data,
  });
}

class BadGatewayError extends AppError {
  const BadGatewayError({
    super.message = "Bad gateway. Please try again.",
    super.statusCode = 502,
    super.data,
  });
}

class ServiceUnavailableError extends AppError {
  const ServiceUnavailableError({
    super.message = "Service temporarily unavailable. Please try again later.",
    super.statusCode = 503,
    super.data,
  });
}

class GatewayTimeoutError extends AppError {
  const GatewayTimeoutError({
    super.message = "Gateway timeout. Please try again.",
    super.statusCode = 504,
    super.data,
  });
}
