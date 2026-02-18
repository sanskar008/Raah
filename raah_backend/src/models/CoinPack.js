const mongoose = require('mongoose');

/**
 * Coin packs available in the store for customers to purchase.
 */
const coinPackSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Pack name is required'],
      trim: true,
    },
    coins: {
      type: Number,
      required: [true, 'Number of coins is required'],
      min: [1, 'Must have at least 1 coin'],
    },
    price: {
      type: Number,
      required: [true, 'Price is required'],
      min: [0, 'Price cannot be negative'],
    },
    /**
     * Optional bonus coins for promotional packs.
     */
    bonusCoins: {
      type: Number,
      default: 0,
      min: 0,
    },
    /**
     * Whether this pack is currently available for purchase.
     */
    isActive: {
      type: Boolean,
      default: true,
    },
    /**
     * Display order in store (lower = shown first).
     */
    displayOrder: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

/* ── Indexes ─────────────────────────────────────── */
coinPackSchema.index({ isActive: 1, displayOrder: 1 });

module.exports = mongoose.model('CoinPack', coinPackSchema);
