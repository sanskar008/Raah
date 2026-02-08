const mongoose = require('mongoose');
const { WALLET_TX_TYPE } = require('../utils/constants');

/**
 * Every wallet mutation is recorded as an immutable transaction.
 * The User.wallet field is a denormalised running total for fast reads,
 * but this collection is the **source of truth**.
 */
const walletTransactionSchema = new mongoose.Schema(
  {
    brokerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Broker reference is required'],
    },
    amount: {
      type: Number,
      required: [true, 'Amount is required'],
      min: [0, 'Amount must be positive'],
    },
    type: {
      type: String,
      enum: Object.values(WALLET_TX_TYPE),
      required: [true, 'Transaction type is required'],
    },
    reason: {
      type: String,
      required: [true, 'Reason is required'],
      trim: true,
    },
  },
  { timestamps: true } // createdAt acts as the transaction timestamp
);

/* ── Indexes ─────────────────────────────────────── */
walletTransactionSchema.index({ brokerId: 1, createdAt: -1 });

module.exports = mongoose.model('WalletTransaction', walletTransactionSchema);
