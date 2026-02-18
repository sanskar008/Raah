const mongoose = require('mongoose');

/**
 * Tracks rental period subscriptions/payments for property owners.
 * Records when owners pay for rental periods (7, 15, 30 days).
 */
const rentalSubscriptionSchema = new mongoose.Schema(
  {
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Owner reference is required'],
    },
    propertyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Property',
      required: [true, 'Property reference is required'],
    },
    /**
     * Number of days in this rental period.
     */
    days: {
      type: Number,
      required: [true, 'Number of days is required'],
      enum: [7, 15, 30],
    },
    /**
     * Amount paid for this rental period.
     */
    amount: {
      type: Number,
      required: [true, 'Amount is required'],
      min: [0, 'Amount cannot be negative'],
    },
    /**
     * Start date of the rental period.
     */
    startDate: {
      type: Date,
      required: [true, 'Start date is required'],
    },
    /**
     * End date of the rental period.
     */
    endDate: {
      type: Date,
      required: [true, 'End date is required'],
    },
    /**
     * Whether this was a free period (first 7 days for first property).
     */
    wasFree: {
      type: Boolean,
      default: false,
    },
    /**
     * Payment status (for future payment gateway integration).
     */
    paymentStatus: {
      type: String,
      enum: ['pending', 'completed', 'failed'],
      default: 'completed',
    },
  },
  { timestamps: true }
);

/* ── Indexes ─────────────────────────────────────── */
rentalSubscriptionSchema.index({ ownerId: 1, createdAt: -1 });
rentalSubscriptionSchema.index({ propertyId: 1 });
rentalSubscriptionSchema.index({ endDate: 1 }); // For finding expired subscriptions

module.exports = mongoose.model('RentalSubscription', rentalSubscriptionSchema);
