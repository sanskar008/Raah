const mongoose = require('mongoose');

const propertySchema = new mongoose.Schema(
  {
    title: {
      type: String,
      required: [true, 'Property title is required'],
      trim: true,
      maxlength: [200, 'Title cannot exceed 200 characters'],
    },
    description: {
      type: String,
      required: [true, 'Description is required'],
      trim: true,
      maxlength: [2000, 'Description cannot exceed 2000 characters'],
    },
    rent: {
      type: Number,
      required: [true, 'Rent amount is required'],
      min: [0, 'Rent cannot be negative'],
    },
    deposit: {
      type: Number,
      required: [true, 'Deposit amount is required'],
      min: [0, 'Deposit cannot be negative'],
    },
    area: {
      type: String,
      required: [true, 'Area / locality is required'],
      trim: true,
    },
    city: {
      type: String,
      required: [true, 'City is required'],
      trim: true,
    },
    /**
     * Store image URLs (cloud links).
     * Actual file upload is handled by the client → cloud storage;
     * the backend only persists the resulting URLs.
     */
    images: {
      type: [String],
      default: [],
    },
    amenities: {
      type: [String],
      default: [],
    },
    /**
     * The user who owns the physical property.
     * Always required — even when a broker lists it on behalf of an owner,
     * the owner is captured here.
     */
    ownerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: [true, 'Owner is required'],
    },
    /**
     * If a broker listed this property, track them here
     * so they receive wallet rewards.
     */
    brokerId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    /**
     * Rental period in days - how long the property is listed for rent.
     * Owner pays for rental periods after first 7 days free.
     */
    rentalPeriodDays: {
      type: Number,
      default: null,
      min: 1,
    },
    /**
     * Rental period start date - when the rental period begins.
     */
    rentalPeriodStart: {
      type: Date,
      default: null,
    },
    /**
     * Rental period end date - when the rental period expires.
     */
    rentalPeriodEnd: {
      type: Date,
      default: null,
    },
    /**
     * Whether this is the owner's first property (gets 7 days free).
     */
    isFirstProperty: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

/* ── Indexes for common query patterns ───────────── */
propertySchema.index({ city: 1, area: 1 });
propertySchema.index({ rent: 1 });
propertySchema.index({ ownerId: 1 });
propertySchema.index({ brokerId: 1 });

module.exports = mongoose.model('Property', propertySchema);
