const jwt = require('jsonwebtoken');
const User = require('../models/User');
const asyncHandler = require('../utils/asyncHandler');

/**
 * Middleware: Optional Authenticate
 * Similar to authenticate, but doesn't fail if no token is provided.
 * If a valid token exists, attaches the user to req.user.
 * If no token or invalid token, req.user remains undefined.
 */
const optionalAuthenticate = asyncHandler(async (req, _res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next(); // No token, continue without user
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Fetch user without the password field
    const user = await User.findById(decoded.id);
    if (user) {
      req.user = user;
    }
    // If user not found, just continue without req.user
    next();
  } catch (error) {
    // Invalid token, but continue without user
    next();
  }
});

module.exports = optionalAuthenticate;
