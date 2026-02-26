const mongoose = require('mongoose');

/**
 * Conversation between a customer (inquirer) and property owner.
 * One conversation per customer–property pair.
 */
const conversationSchema = new mongoose.Schema(
  {
    propertyId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Property',
      required: [true, 'Property is required'],
    },
    customerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Customer is required'],
    },
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Owner is required'],
    },
    lastMessageAt: {
      type: Date,
      default: null,
    },
    lastMessageText: {
      type: String,
      trim: true,
      default: null,
    },
  },
  { timestamps: true }
);

conversationSchema.index({ propertyId: 1, customerId: 1 }, { unique: true });
conversationSchema.index({ customerId: 1, lastMessageAt: -1 });
conversationSchema.index({ ownerId: 1, lastMessageAt: -1 });

module.exports = mongoose.model('Conversation', conversationSchema);
