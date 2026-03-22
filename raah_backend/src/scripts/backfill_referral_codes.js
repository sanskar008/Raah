require("dotenv").config();
const mongoose = require("mongoose");
const crypto = require("crypto");
const User = require("../models/User");

const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log("✅ Connected to MongoDB");
  } catch (error) {
    console.error("❌ MongoDB connection error:", error.message);
    process.exit(1);
  }
};

const generateUniqueCode = async () => {
  while (true) {
    const code = crypto.randomBytes(4).toString("hex").toUpperCase();
    const exists = await User.findOne({ referralCode: code }).lean();
    if (!exists) return code;
  }
};

const backfill = async () => {
  await connectDB();

  const users = await User.find({
    $or: [
      { referralCode: { $exists: false } },
      { referralCode: null },
      { referralCode: "" },
    ],
  });
  console.log(`Found ${users.length} user(s) without referralCode.`);

  let updated = 0;
  for (const user of users) {
    const code = await generateUniqueCode();
    user.referralCode = code;
    try {
      await user.save();
      console.log(`Updated user ${user._id} -> ${code}`);
      updated++;
    } catch (e) {
      console.error(`Failed to update user ${user._id}:`, e.message);
    }
  }

  console.log(`Done. Updated ${updated} user(s).`);
  mongoose.disconnect();
};

backfill().catch((e) => {
  console.error("Backfill error:", e);
  process.exit(1);
});
