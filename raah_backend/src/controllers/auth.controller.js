const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const authService = require('../services/auth.service');

/**
 * @route   POST /api/auth/signup
 * @desc    Register a new user
 * @access  Public
 */
const signup = asyncHandler(async (req, res) => {
  const { name, email, phone, password, role } = req.body;

  const result = await authService.signup({ name, email: email || undefined, phone, password, role });

  res.status(201).json(new ApiResponse(201, 'User registered successfully.', result));
});

/**
 * @route   POST /api/auth/login
 * @desc    Authenticate user & return JWT
 * @access  Public
 */
const login = asyncHandler(async (req, res) => {
  const { email, password } = req.body;

  const result = await authService.login({ email, password });

  res.status(200).json(new ApiResponse(200, 'Login successful.', result));
});

/**
 * @route   POST /api/auth/send-otp
 * @desc    Send OTP to phone number (demo mode)
 * @access  Public
 */
const sendOTP = asyncHandler(async (req, res) => {
  const { phone } = req.body;

  const result = await authService.sendOTP({ phone });

  res.status(200).json(new ApiResponse(200, 'OTP sent successfully.', result));
});

/**
 * @route   POST /api/auth/verify-otp
 * @desc    Verify OTP and login user
 * @access  Public
 */
const verifyOTP = asyncHandler(async (req, res) => {
  const { phone, otp } = req.body;

  const result = await authService.verifyOTP({ phone, otp });

  res.status(200).json(new ApiResponse(200, 'OTP verified. Login successful.', result));
});

/**
 * @route   GET /api/auth/me
 * @desc    Get currently authenticated user's profile
 * @access  Private
 */
const getMe = asyncHandler(async (req, res) => {
  res.status(200).json(new ApiResponse(200, 'User profile fetched.', { user: req.user }));
});

module.exports = { signup, login, sendOTP, verifyOTP, getMe };
