const mongoose = require('mongoose');

/**
 * Tracks every coin credit and debit for customers.
 * - Credits: referral bonus, coin pack purchase
 * - Debits: property unlock
 */
const coinTransactionSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    /** Positive = credit, negative = debit */
    amount: {
      type: Number,
      required: true,
    },
    type: {
      type: String,
      enum: ['credit', 'debit'],
      required: true,
    },
    reason: {
      type: String,
      required: true,
      trim: true,
    },
    /** Optional reference to a property (for unlock debits) */
    propertyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Property',
      default: null,
    },
    /** Coin balance after this transaction */
    balanceAfter: {
      type: Number,
      required: true,
    },
  },
  { timestamps: true }
);

coinTransactionSchema.index({ userId: 1, createdAt: -1 });

module.exports = mongoose.model('CoinTransaction', coinTransactionSchema);
