const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./config/swagger');

const errorHandler = require('./middlewares/errorHandler');
const ApiError = require('./utils/ApiError');

/* ── Route imports ────────────────────────────────── */
const authRoutes = require('./routes/auth.routes');
const propertyRoutes = require('./routes/property.routes');
const appointmentRoutes = require('./routes/appointment.routes');
const walletRoutes = require('./routes/wallet.routes');
const coinRoutes = require('./routes/coin.routes');
const rentalRoutes = require('./routes/rental.routes');
const chatRoutes = require('./routes/chat.routes');
const userRoutes = require('./routes/user.routes');

const app = express();

/* ── Global middlewares ──────────────────────────── */
app.use(helmet()); // security headers
app.use(cors()); // enable CORS for all origins (tighten in production)
app.use(express.json({ limit: '10mb' })); // JSON body parser
app.use(express.urlencoded({ extended: true }));

// HTTP request logger (skip in test environment)
if (process.env.NODE_ENV !== 'test') {
  app.use(morgan('dev'));
}

// Basic rate limiting — 100 requests per 15 minutes per IP
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use('/api', limiter);

/* ── Swagger API docs ────────────────────────────── */
app.use(
  '/api-docs',
  swaggerUi.serve,
  swaggerUi.setup(swaggerSpec, {
    customCss: '.swagger-ui .topbar { display: none }',
    customSiteTitle: 'Raah API Docs',
  })
);
// Serve the raw OpenAPI JSON for tooling (Postman import, codegen, etc.)
app.get('/api-docs.json', (_req, res) => {
  res.setHeader('Content-Type', 'application/json');
  res.send(swaggerSpec);
});

/* ── Health check ────────────────────────────────── */
app.get('/api/health', (_req, res) => {
  res.json({ success: true, message: 'Raah API is running 🚀' });
});

/* ── API routes ──────────────────────────────────── */
app.use('/api/auth', authRoutes);
app.use('/api/properties', propertyRoutes);
app.use('/api/appointments', appointmentRoutes);
app.use('/api/wallet', walletRoutes);
app.use('/api/coins', coinRoutes);
app.use('/api/rental', rentalRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/users', userRoutes);

/* ── 404 handler for unknown routes ──────────────── */
app.all('*', (req, _res, next) => {
  next(new ApiError(404, `Route ${req.originalUrl} not found.`));
});

/* ── Centralised error handler (must be last) ────── */
app.use(errorHandler);

module.exports = app;
