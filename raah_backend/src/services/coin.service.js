const User = require('../models/User');
const CoinPack = require('../models/CoinPack');
const UnlockedProperty = require('../models/UnlockedProperty');
const Property = require('../models/Property');
const ApiError = require('../utils/ApiError');
const { ROLES } = require('../utils/constants');

/**
 * Get all available coin packs from the store.
 */
const getCoinPacks = async () => {
  const packs = await CoinPack.find({ isActive: true })
    .sort({ displayOrder: 1, createdAt: 1 })
    .lean();

  return packs;
};

/**
 * Purchase a coin pack - adds coins to customer's account.
 * In a real app, this would integrate with a payment gateway.
 */
const purchaseCoinPack = async (customerId, packId) => {
  const customer = await User.findById(customerId);
  if (!customer) {
    throw new ApiError(404, 'Customer not found.');
  }

  if (customer.role !== ROLES.CUSTOMER) {
    throw new ApiError(403, 'Only customers can purchase coin packs.');
  }

  const pack = await CoinPack.findById(packId);
  if (!pack || !pack.isActive) {
    throw new ApiError(404, 'Coin pack not found or not available.');
  }

  // In a real app, process payment here
  // For now, we'll just add the coins

  const totalCoins = pack.coins + (pack.bonusCoins || 0);

  // Update customer's coin balance
  await User.findByIdAndUpdate(customerId, {
    $inc: { coins: totalCoins },
  });

  return {
    pack: pack.toObject(),
    coinsAdded: totalCoins,
    newBalance: customer.coins + totalCoins,
  };
};

/**
 * Unlock a property for viewing by a customer.
 * First 3 properties are free, then 2 credits per property.
 */
const unlockProperty = async (customerId, propertyId) => {
  const customer = await User.findById(customerId);
  if (!customer) {
    throw new ApiError(404, 'Customer not found.');
  }

  if (customer.role !== ROLES.CUSTOMER) {
    throw new ApiError(403, 'Only customers can unlock properties.');
  }

  const property = await Property.findById(propertyId);
  if (!property) {
    throw new ApiError(404, 'Property not found.');
  }

  // Check if already unlocked
  const existing = await UnlockedProperty.findOne({
    customerId,
    propertyId,
  });

  if (existing) {
    return {
      alreadyUnlocked: true,
      wasFree: existing.wasFree,
      coinsSpent: existing.coinsSpent,
    };
  }

  // Check if customer has free views remaining
  const freeViewsRemaining = 3 - customer.freePropertyViewsUsed;
  const isFree = freeViewsRemaining > 0;
  const coinsRequired = isFree ? 0 : 2;

  if (!isFree) {
    // Check if customer has enough coins
    if (customer.coins < coinsRequired) {
      throw new ApiError(400, `Insufficient coins. You need ${coinsRequired} coins to unlock this property.`);
    }
  }

  // Deduct coins if not free
  if (!isFree) {
    await User.findByIdAndUpdate(customerId, {
      $inc: { coins: -coinsRequired },
    });
  } else {
    // Increment free views used
    await User.findByIdAndUpdate(customerId, {
      $inc: { freePropertyViewsUsed: 1 },
    });
  }

  // Record the unlock
  const unlock = await UnlockedProperty.create({
    customerId,
    propertyId,
    wasFree: isFree,
    coinsSpent: coinsRequired,
  });

  return {
    alreadyUnlocked: false,
    wasFree: isFree,
    coinsSpent: coinsRequired,
    newCoinBalance: isFree ? customer.coins : customer.coins - coinsRequired,
    unlock,
  };
};

/**
 * Get customer's coin balance and unlock history.
 */
const getCustomerWallet = async (customerId) => {
  const customer = await User.findById(customerId).select('coins freePropertyViewsUsed name email');
  if (!customer) {
    throw new ApiError(404, 'Customer not found.');
  }

  if (customer.role !== ROLES.CUSTOMER) {
    throw new ApiError(403, 'Only customers have coin wallets.');
  }

  const unlockedProperties = await UnlockedProperty.find({ customerId })
    .populate('propertyId', 'title city area rent')
    .sort('-createdAt')
    .limit(50)
    .lean();

  return {
    coins: customer.coins,
    freePropertyViewsUsed: customer.freePropertyViewsUsed,
    freePropertyViewsRemaining: Math.max(0, 3 - customer.freePropertyViewsUsed),
    unlockedProperties,
  };
};

/**
 * Check if a property is unlocked for a customer.
 */
const isPropertyUnlocked = async (customerId, propertyId) => {
  const unlock = await UnlockedProperty.findOne({
    customerId,
    propertyId,
  });

  return !!unlock;
};

module.exports = {
  getCoinPacks,
  purchaseCoinPack,
  unlockProperty,
  getCustomerWallet,
  isPropertyUnlocked,
};
