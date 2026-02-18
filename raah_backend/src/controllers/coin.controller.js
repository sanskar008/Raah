const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const coinService = require('../services/coin.service');

/**
 * @route   GET /api/coins/packs
 * @desc    Get all available coin packs
 * @access  Public
 */
const getCoinPacks = asyncHandler(async (req, res) => {
  const packs = await coinService.getCoinPacks();

  res.status(200).json(new ApiResponse(200, 'Coin packs fetched.', { packs }));
});

/**
 * @route   POST /api/coins/purchase
 * @desc    Purchase a coin pack
 * @access  Private – Customer
 */
const purchaseCoinPack = asyncHandler(async (req, res) => {
  const result = await coinService.purchaseCoinPack(req.user._id, req.body.packId);

  res.status(200).json(new ApiResponse(200, 'Coin pack purchased successfully.', result));
});

/**
 * @route   POST /api/coins/unlock-property
 * @desc    Unlock a property to view details
 * @access  Private – Customer
 */
const unlockProperty = asyncHandler(async (req, res) => {
  const { propertyId } = req.body;

  if (!propertyId) {
    return res.status(400).json(new ApiResponse(400, 'Property ID is required.', null));
  }

  const result = await coinService.unlockProperty(req.user._id, propertyId);

  res.status(200).json(new ApiResponse(200, 'Property unlocked successfully.', result));
});

/**
 * @route   GET /api/coins/wallet
 * @desc    Get customer's coin wallet and unlock history
 * @access  Private – Customer
 */
const getCustomerWallet = asyncHandler(async (req, res) => {
  const wallet = await coinService.getCustomerWallet(req.user._id);

  res.status(200).json(new ApiResponse(200, 'Wallet fetched.', wallet));
});

module.exports = {
  getCoinPacks,
  purchaseCoinPack,
  unlockProperty,
  getCustomerWallet,
};
