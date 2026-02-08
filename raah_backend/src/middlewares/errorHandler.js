const ApiError = require('../utils/ApiError');

/**
 * Global error-handling middleware.
 * Express recognises this as an error handler because it has 4 parameters.
 *
 * ─ Known ApiError  → use its statusCode & message.
 * ─ Mongoose validation / duplicate-key → map to 400/409.
 * ─ Everything else → generic 500.
 */
// eslint-disable-next-line no-unused-vars
const errorHandler = (err, _req, res, _next) => {
  let error = err;

  /* ── Mongoose bad ObjectId ───────────────────── */
  if (err.name === 'CastError') {
    error = new ApiError(400, `Invalid ${err.path}: ${err.value}`);
  }

  /* ── Mongoose duplicate key ──────────────────── */
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue).join(', ');
    error = new ApiError(409, `Duplicate value for field(s): ${field}`);
  }

  /* ── Mongoose validation errors ──────────────── */
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((e) => e.message);
    error = new ApiError(400, messages.join('. '));
  }

  const statusCode = error.statusCode || 500;
  const message = error.message || 'Internal Server Error';

  // Log full error in development for debugging
  if (process.env.NODE_ENV === 'development') {
    console.error('🔴  Error:', err);
  }

  res.status(statusCode).json({
    success: false,
    statusCode,
    message,
    ...(error.errors?.length && { errors: error.errors }),
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
};

module.exports = errorHandler;
