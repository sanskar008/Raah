const User = require('../models/User');
const WalletTransaction = require('../models/WalletTransaction');
const ApiError = require('../utils/ApiError');
const { WALLET_TX_TYPE } = require('../utils/constants');

/**
 * Get wallet balance and recent transactions for a broker.
 */
const getWallet = async (brokerId, query) => {
  const { page = 1, limit = 20 } = query;
  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(50, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const user = await User.findById(brokerId).select('wallet name email');
  if (!user) {
    throw new ApiError(404, 'User not found.');
  }

  const filter = { brokerId };

  const [transactions, total] = await Promise.all([
    WalletTransaction.find(filter)
      .sort('-createdAt')
      .skip(skip)
      .limit(pageSize)
      .lean(),
    WalletTransaction.countDocuments(filter),
  ]);

  return {
    balance: user.wallet,
    transactions,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

/**
 * Withdraw coins from the broker's wallet.
 *
 * Business rules:
 *  - Amount must be > 0 and ≤ current balance.
 *  - A debit transaction is recorded.
 *  - The denormalised User.wallet is decremented atomically.
 */
const withdraw = async (brokerId, amount) => {
  if (!amount || amount <= 0) {
    throw new ApiError(400, 'Withdrawal amount must be greater than zero.');
  }

  const user = await User.findById(brokerId);
  if (!user) {
    throw new ApiError(404, 'User not found.');
  }

  if (user.wallet < amount) {
    throw new ApiError(400, `Insufficient balance. Current balance: ${user.wallet}`);
  }

  // Atomic decrement to prevent race conditions
  const updatedUser = await User.findOneAndUpdate(
    { _id: brokerId, wallet: { $gte: amount } },
    { $inc: { wallet: -amount } },
    { new: true }
  );

  if (!updatedUser) {
    throw new ApiError(400, 'Withdrawal failed. Insufficient balance (concurrent update).');
  }

  const transaction = await WalletTransaction.create({
    brokerId,
    amount,
    type: WALLET_TX_TYPE.DEBIT,
    reason: `Wallet withdrawal of ${amount} coins`,
  });

  return {
    newBalance: updatedUser.wallet,
    transaction,
  };
};

module.exports = { getWallet, withdraw };
