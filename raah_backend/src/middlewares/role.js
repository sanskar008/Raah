const ApiError = require('../utils/ApiError');

/**
 * Middleware factory: Role-Based Access Control
 *
 * Usage:  router.get('/path', authenticate, authorise('broker', 'owner'), handler)
 *
 * Accepts one or more allowed roles. If the authenticated user's role
 * is not in the list, a 403 Forbidden is thrown.
 */
const authorise = (...allowedRoles) => {
  return (req, _res, next) => {
    if (!req.user) {
      throw new ApiError(401, 'Authentication required before authorisation.');
    }

    if (!allowedRoles.includes(req.user.role)) {
      throw new ApiError(
        403,
        `Role '${req.user.role}' is not authorised to access this resource.`
      );
    }

    next();
  };
};

module.exports = authorise;
