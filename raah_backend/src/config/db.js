const mongoose = require('mongoose');

/**
 * Connect to MongoDB Atlas.
 * We keep this in its own file so the connection logic is
 * reusable and testable independently of the Express app.
 */
const connectDB = async () => {
  try {
    const conn = await mongoose.connect(process.env.MONGO_URI);
    console.log(`✅  MongoDB connected: ${conn.connection.host}`);
  } catch (error) {
    console.error(`❌  MongoDB connection error: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
