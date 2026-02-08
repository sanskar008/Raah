const { validationResult } = require('express-validator');
const ApiError = require('../utils/ApiError');

/**
 * Middleware: Validate
 * Runs after express-validator checks and collects any errors.
 * If errors exist, it throws an ApiError with a 422 status
 * and the array of field-level issues.
 */
const validate = (req, _res, next) => {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const extractedErrors = errors.array().map((err) => ({
      field: err.path,
      message: err.msg,
    }));

    throw new ApiError(422, 'Validation failed.', extractedErrors);
  }

  next();
};

module.exports = validate;
