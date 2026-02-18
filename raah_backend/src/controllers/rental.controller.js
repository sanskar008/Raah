const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const rentalService = require('../services/rental.service');

/**
 * @route   GET /api/rental/plans
 * @desc    Get available rental period plans
 * @access  Public
 */
const getRentalPlans = asyncHandler(async (req, res) => {
  const plans = await rentalService.getRentalPlans();

  res.status(200).json(new ApiResponse(200, 'Rental plans fetched.', { plans }));
});

/**
 * @route   POST /api/rental/purchase
 * @desc    Purchase a rental period for a property
 * @access  Private – Owner
 */
const purchaseRentalPeriod = asyncHandler(async (req, res) => {
  const { propertyId, days } = req.body;

  if (!propertyId || !days) {
    return res.status(400).json(new ApiResponse(400, 'Property ID and days are required.', null));
  }

  const result = await rentalService.purchaseRentalPeriod(req.user._id, propertyId, days);

  res.status(200).json(new ApiResponse(200, 'Rental period purchased successfully.', result));
});

/**
 * @route   GET /api/rental/my
 * @desc    Get owner's rental subscriptions
 * @access  Private – Owner
 */
const getOwnerRentals = asyncHandler(async (req, res) => {
  const rentals = await rentalService.getOwnerRentals(req.user._id);

  res.status(200).json(new ApiResponse(200, 'Rental subscriptions fetched.', rentals));
});

module.exports = {
  getRentalPlans,
  purchaseRentalPeriod,
  getOwnerRentals,
};
