const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const crypto = require('crypto');
const { ROLES } = require('../utils/constants');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Name is required'],
      trim: true,
      maxlength: [100, 'Name cannot exceed 100 characters'],
    },
    email: {
      type: String,
      required: false,
      unique: true,
      sparse: true, // Allows multiple null values
      lowercase: true,
      trim: true,
      match: [/^\S+@\S+\.\S+$/, 'Please provide a valid email'],
    },
    phone: {
      type: String,
      required: [true, 'Phone number is required'],
      unique: true,
      trim: true,
      match: [/^\d{10}$/, 'Phone number must be 10 digits'],
    },
    password: {
      type: String,
      required: [true, 'Password is required'],
      minlength: [6, 'Password must be at least 6 characters'],
      select: false, // never return password by default in queries
    },
    role: {
      type: String,
      enum: Object.values(ROLES),
      default: ROLES.CUSTOMER,
    },
    /**
     * Wallet balance is only relevant for brokers.
     * We keep it on the User document for quick reads;
     * the WalletTransaction collection is the source of truth.
     */
    wallet: {
      type: Number,
      default: 0,
      min: 0,
    },
    /**
     * Coins balance for customers to unlock property details.
     * First 3 properties are free, then 2 credits per property.
     */
    coins: {
      type: Number,
      default: 0,
      min: 0,
    },
    /**
     * Track how many free property views the customer has used.
     * Resets or increments based on business logic.
     */
    freePropertyViewsUsed: {
      type: Number,
      default: 0,
      min: 0,
    },
    /**
     * Unique referral code for this user — generated on creation.
     * Other users enter this during signup to earn the referrer 5 coins.
     */
    referralCode: {
      type: String,
      unique: true,
      sparse: true,
    },
    /**
     * The user who referred this user (via referral code at signup).
     */
    referredBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      default: null,
    },
    /**
     * Count of users who successfully signed up using this user's referral code.
     */
    referredCount: {
      type: Number,
      default: 0,
      min: 0,
    },
    /**
     * User's last known location (set when they share location from app).
     */
    location: {
      lat: { type: Number, default: null },
      lng: { type: Number, default: null },
      address: { type: String, default: null },
      updatedAt: { type: Date, default: null },
    },
  },
  { timestamps: true }
);

/* ── Indexes ─────────────────────────────────────── */
userSchema.index({ email: 1 }, { sparse: true });
userSchema.index({ phone: 1 });
userSchema.index({ role: 1 });

/* ── Pre-save hook: hash password + generate referral code ── */
userSchema.pre('save', async function (next) {
  // Hash password if modified
  if (this.isModified('password')) {
    const salt = await bcrypt.genSalt(12);
    this.password = await bcrypt.hash(this.password, salt);
  }

  // Generate unique referral code for new users
  if (this.isNew && !this.referralCode) {
    this.referralCode = crypto.randomBytes(4).toString('hex').toUpperCase();
  }

  next();
});

/* ── Instance method: compare password ───────────── */
userSchema.methods.comparePassword = async function (candidatePassword) {
  return bcrypt.compare(candidatePassword, this.password);
};

module.exports = mongoose.model('User', userSchema);
