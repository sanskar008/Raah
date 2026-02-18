const mongoose = require('mongoose');

/**
 * Tracks which properties a customer has unlocked to view details.
 * Used to prevent duplicate charges and track viewing history.
 */
const unlockedPropertySchema = new mongoose.Schema(
  {
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Customer reference is required'],
    },
    propertyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Property',
      required: [true, 'Property reference is required'],
    },
    /**
     * Whether this was a free unlock (first 3 properties).
     */
    wasFree: {
      type: Boolean,
      default: false,
    },
    /**
     * Coins spent to unlock (0 if free).
     */
    coinsSpent: {
      type: Number,
      default: 0,
      min: 0,
    },
  },
  { timestamps: true }
);

/* ── Indexes ─────────────────────────────────────── */
unlockedPropertySchema.index({ customerId: 1, propertyId: 1 }, { unique: true });
unlockedPropertySchema.index({ customerId: 1, createdAt: -1 });

module.exports = mongoose.model('UnlockedProperty', unlockedPropertySchema);
