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
  // Check if user already exists by phone (phone is now unique)
  const existingUser = await User.findOne({ phone });
  if (existingUser) {
    throw new ApiError(409, 'An account with this phone number already exists.');
  }

  // Check email if provided
  if (email) {
    const existingEmail = await User.findOne({ email });
    if (existingEmail) {
      throw new ApiError(409, 'An account with this email already exists.');
    }
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

/**
 * Send OTP to phone number (demo mode - always returns success)
 * In production, this would send SMS via Twilio, AWS SNS, etc.
 */
const sendOTP = async ({ phone }) => {
  // Validate phone format
  if (!/^\d{10}$/.test(phone)) {
    throw new ApiError(400, 'Phone number must be exactly 10 digits.');
  }

  // Demo mode: Always return success
  // In production, you would:
  // 1. Generate a 6-digit OTP
  // 2. Store it in Redis/cache with phone number and expiry (5 minutes)
  // 3. Send SMS via Twilio/AWS SNS/etc.
  // 4. Return success

  return { message: 'OTP sent successfully', phone };
};

/**
 * Verify OTP and login user
 * - Finds user by phone number
 * - Verifies OTP (demo: accepts 123456)
 * - Returns JWT token
 */
const verifyOTP = async ({ phone, otp }) => {
  // Validate phone format
  if (!/^\d{10}$/.test(phone)) {
    throw new ApiError(400, 'Phone number must be exactly 10 digits.');
  }

  // Demo OTP: Accept 123456 for any phone number
  const DEMO_OTP = '123456';
  if (otp !== DEMO_OTP) {
    throw new ApiError(401, 'Invalid OTP. Use 123456 for demo.');
  }

  // Find user by phone number
  const user = await User.findOne({ phone });
  if (!user) {
    throw new ApiError(404, 'User not found. Please sign up first.');
  }

  const userObj = user.toObject();
  delete userObj.password;

  const token = generateToken(user._id);

  return { user: userObj, token };
};

module.exports = { signup, login, sendOTP, verifyOTP };
