const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const ApiError = require('../utils/ApiError');
const User = require('../models/User');

/**
 * @route   GET /api/users/referral-info
 * @desc    Get current user's referral code, count and coins earned from referrals
 * @access  Private
 */
const getReferralInfo = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user._id)
    .select('referralCode referredCount coins name')
    .lean();

  if (!user) {
    throw new ApiError(404, 'User not found.');
  }

  res.status(200).json(
    new ApiResponse(200, 'Referral info fetched.', {
      referralCode: user.referralCode,
      referredCount: user.referredCount || 0,
      coinsEarnedFromReferrals: (user.referredCount || 0) * 5,
    })
  );
});

/**
 * @route   PUT /api/users/location
 * @desc    Update current user's location
 * @access  Private
 */
const updateLocation = asyncHandler(async (req, res) => {
  const { lat, lng, address } = req.body;

  if (lat === undefined || lng === undefined) {
    throw new ApiError(400, 'Latitude and longitude are required.');
  }

  await User.findByIdAndUpdate(req.user._id, {
    location: {
      lat: parseFloat(lat),
      lng: parseFloat(lng),
      address: address || null,
      updatedAt: new Date(),
    },
  });

  res.status(200).json(
    new ApiResponse(200, 'Location updated successfully.', {
      lat: parseFloat(lat),
      lng: parseFloat(lng),
      address: address || null,
    })
  );
});

module.exports = { getReferralInfo, updateLocation };
