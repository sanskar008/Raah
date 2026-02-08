/**
 * Wraps an async route handler so that any rejected promise
 * is automatically forwarded to Express's error-handling middleware.
 * This eliminates repetitive try/catch blocks in every controller.
 *
 * Usage:  router.get('/path', asyncHandler(myController));
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

module.exports = asyncHandler;
