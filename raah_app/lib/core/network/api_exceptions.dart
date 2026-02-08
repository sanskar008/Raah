/// Custom exception classes for clean error handling across the app.

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  NetworkException({String message = 'No internet connection'})
      : super(message: message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Unauthorized. Please login again.'})
      : super(message: message, statusCode: 401);
}

class ServerException extends ApiException {
  ServerException({String message = 'Server error. Please try again later.'})
      : super(message: message, statusCode: 500);
}

class NotFoundException extends ApiException {
  NotFoundException({String message = 'Resource not found.'})
      : super(message: message, statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String message = 'Validation failed.',
    this.errors,
  }) : super(message: message, statusCode: 422);
}
