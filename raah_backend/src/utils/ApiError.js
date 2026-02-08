/**
 * Custom API Error class.
 * Extends the native Error so we can attach an HTTP status code
 * and keep a consistent error shape throughout the app.
 */
class ApiError extends Error {
  constructor(statusCode, message, errors = [], stack = '') {
    super(message);
    this.statusCode = statusCode;
    this.success = false;
    this.errors = errors; // optional field-level errors from validation

    if (stack) {
      this.stack = stack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

module.exports = ApiError;
