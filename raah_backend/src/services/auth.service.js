const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const { ROLES } = require('../utils/constants');

/**
 * Generate a JWT for the given user id.
 */
const generateToken = (userId) => {
  return jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

/**
 * Register a new user.
 * - Validates that the email isn't already taken.
 * - Hashes the password (handled by the User pre-save hook).
 * - Returns the user object + JWT.
 */
const signup = async ({ name, email, phone, password, role }) => {
  // Check if user already exists
  const existingUser = await User.findOne({ email });
  if (existingUser) {
    throw new ApiError(409, 'An account with this email already exists.');
  }

  // Validate role
  if (role && !Object.values(ROLES).includes(role)) {
    throw new ApiError(400, `Invalid role. Must be one of: ${Object.values(ROLES).join(', ')}`);
  }

  const user = await User.create({ name, email, phone, password, role });

  // Strip password from the response object
  const userObj = user.toObject();
  delete userObj.password;

  const token = generateToken(user._id);

  return { user: userObj, token };
};

/**
 * Authenticate an existing user.
 * - Finds by email, compares password, returns JWT.
 */
const login = async ({ email, password }) => {
  // We need to explicitly select password because of `select: false` on the schema
  const user = await User.findOne({ email }).select('+password');
  if (!user) {
    throw new ApiError(401, 'Invalid email or password.');
  }

  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    throw new ApiError(401, 'Invalid email or password.');
  }

  const userObj = user.toObject();
  delete userObj.password;

  const token = generateToken(user._id);

  return { user: userObj, token };
};

module.exports = { signup, login };
