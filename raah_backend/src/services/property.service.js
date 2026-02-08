const Property = require('../models/Property');
const User = require('../models/User');
const WalletTransaction = require('../models/WalletTransaction');
const ApiError = require('../utils/ApiError');
const { ROLES, WALLET_TX_TYPE } = require('../utils/constants');

/**
 * Create a new property listing.
 *
 * Business rules:
 *  - Owners set themselves as ownerId.
 *  - Brokers set themselves as brokerId and must provide an ownerId
 *    (in a real app, the owner would verify this — kept simple here).
 *  - Brokers receive wallet coins for every successful upload.
 */
const createProperty = async (data, currentUser) => {
  let propertyData = { ...data };

  if (currentUser.role === ROLES.OWNER) {
    propertyData.ownerId = currentUser._id;
    propertyData.brokerId = null;
  } else if (currentUser.role === ROLES.BROKER) {
    propertyData.brokerId = currentUser._id;

    // Broker must specify which owner this property belongs to.
    // For simplicity, if not provided, the broker is also treated as the de-facto owner.
    if (!propertyData.ownerId) {
      propertyData.ownerId = currentUser._id;
    }
  } else {
    throw new ApiError(403, 'Customers cannot create property listings.');
  }

  const property = await Property.create(propertyData);

  // ── Reward broker with coins ────────────────────
  if (currentUser.role === ROLES.BROKER) {
    const rewardAmount = Number(process.env.BROKER_UPLOAD_REWARD) || 10;

    await WalletTransaction.create({
      brokerId: currentUser._id,
      amount: rewardAmount,
      type: WALLET_TX_TYPE.CREDIT,
      reason: `Reward for listing property: ${property.title}`,
    });

    // Update the denormalised wallet balance on the user document
    await User.findByIdAndUpdate(currentUser._id, {
      $inc: { wallet: rewardAmount },
    });
  }

  return property;
};

/**
 * List properties with optional filters and pagination.
 *
 * Supported query params:
 *  - area        : partial / case-insensitive match
 *  - city        : partial / case-insensitive match
 *  - minRent     : minimum rent
 *  - maxRent     : maximum rent
 *  - amenities   : comma-separated list (match any)
 *  - page        : page number (default 1)
 *  - limit       : items per page (default 10, max 50)
 *  - sort        : field to sort by (default: -createdAt)
 */
const listProperties = async (query) => {
  const {
    area,
    city,
    minRent,
    maxRent,
    amenities,
    page = 1,
    limit = 10,
    sort = '-createdAt',
  } = query;

  const filter = {};

  if (area) filter.area = { $regex: area, $options: 'i' };
  if (city) filter.city = { $regex: city, $options: 'i' };
  if (minRent || maxRent) {
    filter.rent = {};
    if (minRent) filter.rent.$gte = Number(minRent);
    if (maxRent) filter.rent.$lte = Number(maxRent);
  }
  if (amenities) {
    const list = amenities.split(',').map((a) => a.trim());
    filter.amenities = { $in: list };
  }

  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(50, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const [properties, total] = await Promise.all([
    Property.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(pageSize)
      .populate('ownerId', 'name email phone')
      .populate('brokerId', 'name email phone')
      .lean(),
    Property.countDocuments(filter),
  ]);

  return {
    properties,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

/**
 * Get a single property by ID with populated owner/broker info.
 */
const getPropertyById = async (propertyId) => {
  const property = await Property.findById(propertyId)
    .populate('ownerId', 'name email phone')
    .populate('brokerId', 'name email phone')
    .lean();

  if (!property) {
    throw new ApiError(404, 'Property not found.');
  }

  return property;
};

/**
 * Get properties listed by the currently authenticated user.
 * Owners see properties where ownerId matches.
 * Brokers see properties where brokerId matches.
 */
const getMyProperties = async (currentUser, query) => {
  const { page = 1, limit = 10, sort = '-createdAt' } = query;

  const filter =
    currentUser.role === ROLES.BROKER
      ? { brokerId: currentUser._id }
      : { ownerId: currentUser._id };

  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(50, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const [properties, total] = await Promise.all([
    Property.find(filter)
      .sort(sort)
      .skip(skip)
      .limit(pageSize)
      .populate('ownerId', 'name email phone')
      .populate('brokerId', 'name email phone')
      .lean(),
    Property.countDocuments(filter),
  ]);

  return {
    properties,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

module.exports = { createProperty, listProperties, getPropertyById, getMyProperties };
