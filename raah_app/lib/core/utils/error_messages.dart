import '../network/api_exceptions.dart';

/// Centralized error message utility.
/// Converts technical errors to user-friendly messages.
class ErrorMessages {
  ErrorMessages._();

  /// Get user-friendly error message from any error
  static String getFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'Something went wrong. Please try again.';
    }

    // Handle ApiException types
    if (error is ApiException) {
      return _getApiExceptionMessage(error);
    }

    // Handle String errors
    if (error is String) {
      return _sanitizeMessage(error);
    }

    // Handle generic Exception
    if (error is Exception) {
      final message = error.toString();
      return _sanitizeMessage(message);
    }

    // Default fallback
    return 'Something went wrong. Please try again.';
  }

  /// Get friendly message for ApiException
  static String _getApiExceptionMessage(ApiException exception) {
    // Use the exception's message if it's already user-friendly
    if (exception.message.isNotEmpty) {
      final sanitized = _sanitizeMessage(exception.message);
      if (_isUserFriendly(sanitized)) {
        return sanitized;
      }
    }

    // Map exception types to friendly messages
    if (exception is NetworkException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (exception is UnauthorizedException) {
      return 'Your session has expired. Please login again.';
    }

    if (exception is NotFoundException) {
      return 'The requested information could not be found.';
    }

    if (exception is ValidationException) {
      if (exception.errors != null && exception.errors!.isNotEmpty) {
        // Extract first validation error
        final firstError = exception.errors!.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return _sanitizeMessage(firstError[0].toString());
        }
        if (firstError is String) {
          return _sanitizeMessage(firstError);
        }
      }
      return _sanitizeMessage(exception.message) != exception.message
          ? _sanitizeMessage(exception.message)
          : 'Please check your input and try again.';
    }

    if (exception is ServerException) {
      return 'Our servers are experiencing issues. Please try again in a moment.';
    }

    // Generic API exception
    return _sanitizeMessage(exception.message);
  }

  /// Sanitize technical error messages
  static String _sanitizeMessage(String message) {
    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    // Remove technical prefixes
    String cleaned = message;

    // Remove exception class names
    cleaned = cleaned.replaceAll(RegExp(r'^[A-Z][a-zA-Z]*Exception[:\s]*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'^[A-Z][a-zA-Z]*Error[:\s]*'), '');

    // Remove status codes
    cleaned = cleaned.replaceAll(RegExp(r'\(\d{3}\)'), '');
    cleaned = cleaned.replaceAll(RegExp(r'Status code: \d{3}'), '');

    // Remove stack trace indicators
    cleaned = cleaned.replaceAll(RegExp(r'at .*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'#\d+'), '');

    // Remove file paths
    cleaned = cleaned.replaceAll(RegExp(r'[a-zA-Z]:\\[^\s]+'), '');
    cleaned = cleaned.replaceAll(RegExp(r'/[^\s]+'), '');

    // Remove technical keywords
    cleaned = cleaned.replaceAll(RegExp(r'\b(Error|Exception|Failed|Failure)\b', caseSensitive: false), '');
    cleaned = cleaned.replaceAll(RegExp(r'\b(HTTP|API|Request|Response)\b', caseSensitive: false), '');

    // Clean up whitespace
    cleaned = cleaned.trim();
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');

    // Capitalize first letter
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    // If message is too technical or empty after cleaning, return default
    if (cleaned.isEmpty || 
        cleaned.length < 10 || 
        _isTooTechnical(cleaned)) {
      return 'Something went wrong. Please try again.';
    }

    return cleaned;
  }

  /// Check if message is already user-friendly
  static bool _isUserFriendly(String message) {
    final technicalPatterns = [
      RegExp(r'Exception'),
      RegExp(r'Error:'),
      RegExp(r'at \w+'),
      RegExp(r'#\d+'),
      RegExp(r'[a-zA-Z]:\\'),
      RegExp(r'HTTP \d+'),
      RegExp(r'Status code'),
      RegExp(r'Failed to'),
    ];

    return !technicalPatterns.any((pattern) => pattern.hasMatch(message));
  }

  /// Check if message is too technical even after cleaning
  static bool _isTooTechnical(String message) {
    final technicalKeywords = [
      'stack',
      'trace',
      'undefined',
      'null',
      'object',
      'type',
      'cast',
      'parse',
      'json',
      'dart',
      'flutter',
      'runtime',
    ];

    final lowerMessage = message.toLowerCase();
    return technicalKeywords.any((keyword) => lowerMessage.contains(keyword));
  }

  /// Get context-specific error messages
  static String getContextMessage(String context, dynamic error) {
    final baseMessage = getFriendlyMessage(error);

    switch (context) {
      case 'login':
        if (error is UnauthorizedException) {
          return 'Invalid phone number or OTP. Please try again.';
        }
        if (error is NetworkException) {
          return 'Unable to connect. Please check your internet and try again.';
        }
        return baseMessage;

      case 'signup':
        if (error is ValidationException) {
          return 'Please check your information and try again.';
        }
        return baseMessage;

      case 'property_add':
        if (error is ValidationException) {
          return 'Please fill all required fields correctly.';
        }
        if (error is NetworkException) {
          return 'Unable to upload property. Please check your connection and try again.';
        }
        return 'Unable to add property. Please try again.';

      case 'image_upload':
        if (error is NetworkException) {
          return 'Unable to upload images. Please check your internet connection.';
        }
        return 'Image upload failed. Please try again.';

      case 'appointment':
        if (error is ValidationException) {
          return 'Please select a valid date and time.';
        }
        return 'Unable to book appointment. Please try again.';

      case 'wallet':
        if (error is ValidationException) {
          return 'Invalid withdrawal amount. Please check and try again.';
        }
        return 'Unable to process wallet transaction. Please try again.';

      default:
        return baseMessage;
    }
  }
}
