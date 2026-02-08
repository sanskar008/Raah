/**
 * Entry point – boots the server after DB is connected.
 * Keeping this separate from app.js makes it easy to
 * import `app` in integration tests without starting the listener.
 */
require('dotenv').config();

const app = require('./src/app');
const connectDB = require('./src/config/db');

const PORT = process.env.PORT || 5000;

(async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`🚀  Raah server listening on port ${PORT} [${process.env.NODE_ENV}]`);
  });
})();
