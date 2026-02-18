const Property = require('../models/Property');
const RentalSubscription = require('../models/RentalSubscription');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const { ROLES } = require('../utils/constants');

/**
 * Get rental period plans (7, 15, 30 days) with pricing.
 */
const getRentalPlans = async () => {
  // In a real app, these would be configurable in the database
  return [
    {
      days: 7,
      name: '7 Days',
      price: 100, // Example price in currency units
      description: 'List your property for 7 days',
    },
    {
      days: 15,
      name: '15 Days',
      price: 180, // Example: slight discount
      description: 'List your property for 15 days',
    },
    {
      days: 30,
      name: '30 Days',
      price: 300, // Example: best value
      description: 'List your property for 30 days',
    },
  ];
};

/**
 * Purchase a rental period for a property.
 * First property gets 7 days free, then owner pays for rental periods.
 */
const purchaseRentalPeriod = async (ownerId, propertyId, days) => {
  const owner = await User.findById(ownerId);
  if (!owner) {
    throw new ApiError(404, 'Owner not found.');
  }

  if (owner.role !== ROLES.OWNER) {
    throw new ApiError(403, 'Only owners can purchase rental periods.');
  }

  const property = await Property.findById(propertyId);
  if (!property) {
    throw new ApiError(404, 'Property not found.');
  }

  // Verify ownership
  if (property.ownerId.toString() !== ownerId.toString()) {
    throw new ApiError(403, 'You do not own this property.');
  }

  // Validate days
  if (![7, 15, 30].includes(days)) {
    throw new ApiError(400, 'Invalid rental period. Must be 7, 15, or 30 days.');
  }

  // Check if this is the owner's first property
  const ownerPropertiesCount = await Property.countDocuments({
    ownerId,
    isFirstProperty: true,
  });

  const isFirstProperty = ownerPropertiesCount === 0;

  // If first property and requesting 7 days, make it free
  if (isFirstProperty && days === 7) {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setDate(endDate.getDate() + 7);

    // Update property
    await Property.findByIdAndUpdate(propertyId, {
      isFirstProperty: true,
      rentalPeriodDays: 7,
      rentalPeriodStart: startDate,
      rentalPeriodEnd: endDate,
    });

    // Record free subscription
    await RentalSubscription.create({
      ownerId,
      propertyId,
      days: 7,
      amount: 0,
      startDate,
      endDate,
      wasFree: true,
      paymentStatus: 'completed',
    });

    return {
      wasFree: true,
      days: 7,
      amount: 0,
      startDate,
      endDate,
      message: 'First property gets 7 days free!',
    };
  }

  // For paid rentals, process payment
  // In a real app, integrate with payment gateway here
  const plans = await getRentalPlans();
  const plan = plans.find((p) => p.days === days);
  if (!plan) {
    throw new ApiError(400, 'Invalid rental plan.');
  }

  // Calculate start date (from now or extend from current end date)
  let startDate = new Date();
  if (property.rentalPeriodEnd && property.rentalPeriodEnd > new Date()) {
    // Extend from current end date
    startDate = new Date(property.rentalPeriodEnd);
  }

  const endDate = new Date(startDate);
  endDate.setDate(endDate.getDate() + days);

  // Update property
  await Property.findByIdAndUpdate(propertyId, {
    rentalPeriodDays: days,
    rentalPeriodStart: startDate,
    rentalPeriodEnd: endDate,
    isFirstProperty: isFirstProperty,
  });

  // Record subscription
  const subscription = await RentalSubscription.create({
    ownerId,
    propertyId,
    days,
    amount: plan.price,
    startDate,
    endDate,
    wasFree: false,
    paymentStatus: 'completed', // In real app, set to 'pending' until payment confirmed
  });

  return {
    wasFree: false,
    days,
    amount: plan.price,
    startDate,
    endDate,
    subscription,
  };
};

/**
 * Get rental subscriptions for an owner.
 */
const getOwnerRentals = async (ownerId) => {
  const owner = await User.findById(ownerId);
  if (!owner) {
    throw new ApiError(404, 'Owner not found.');
  }

  if (owner.role !== ROLES.OWNER) {
    throw new ApiError(403, 'Only owners can view rental subscriptions.');
  }

  const subscriptions = await RentalSubscription.find({ ownerId })
    .populate('propertyId', 'title city area rent')
    .sort('-createdAt')
    .lean();

  const properties = await Property.find({ ownerId })
    .select('title city area rent rentalPeriodStart rentalPeriodEnd isFirstProperty')
    .lean();

  return {
    subscriptions,
    properties: properties.map((prop) => ({
      ...prop,
      isActive: prop.rentalPeriodEnd && new Date(prop.rentalPeriodEnd) > new Date(),
      daysRemaining: prop.rentalPeriodEnd
        ? Math.max(0, Math.ceil((new Date(prop.rentalPeriodEnd) - new Date()) / (1000 * 60 * 60 * 24)))
        : 0,
    })),
  };
};

/**
 * Check if a property's rental period is active.
 */
const isRentalActive = async (propertyId) => {
  const property = await Property.findById(propertyId);
  if (!property) {
    return false;
  }

  if (!property.rentalPeriodEnd) {
    return false;
  }

  return new Date(property.rentalPeriodEnd) > new Date();
};

module.exports = {
  getRentalPlans,
  purchaseRentalPeriod,
  getOwnerRentals,
  isRentalActive,
};
