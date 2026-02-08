/**
 * Standardised success response wrapper.
 * Every successful API response goes through this so the
 * frontend always receives a predictable JSON shape:
 *   { success: true, statusCode, message, data }
 */
class ApiResponse {
  constructor(statusCode, message = 'Success', data = null) {
    this.success = statusCode < 400;
    this.statusCode = statusCode;
    this.message = message;
    this.data = data;
  }
}

module.exports = ApiResponse;
