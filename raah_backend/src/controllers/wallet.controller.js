const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const walletService = require('../services/wallet.service');

/**
 * @route   GET /api/wallet
 * @desc    Get broker's wallet balance and transaction history
 * @access  Private – Broker
 */
const getWallet = asyncHandler(async (req, res) => {
  const result = await walletService.getWallet(req.user._id, req.query);

  res.status(200).json(new ApiResponse(200, 'Wallet details fetched.', result));
});

/**
 * @route   POST /api/wallet/withdraw
 * @desc    Withdraw coins from broker's wallet
 * @access  Private – Broker
 */
const withdraw = asyncHandler(async (req, res) => {
  const { amount } = req.body;

  const result = await walletService.withdraw(req.user._id, Number(amount));

  res.status(200).json(new ApiResponse(200, 'Withdrawal successful.', result));
});

module.exports = { getWallet, withdraw };
