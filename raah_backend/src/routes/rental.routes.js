const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const authorise = require('../middlewares/role');
const { ROLES } = require('../utils/constants');
const {
  getRentalPlans,
  purchaseRentalPeriod,
  getOwnerRentals,
} = require('../controllers/rental.controller');

const router = Router();

/* ── Public routes ────────────────────────────────── */
router.get('/plans', getRentalPlans);

/* ── Owner-only routes ────────────────────────────── */
router.use(authenticate, authorise(ROLES.OWNER));

/* ── Validation ──────────────────────────────────── */
const purchaseValidation = [
  body('propertyId').notEmpty().withMessage('Property ID is required.'),
  body('days')
    .isIn([7, 15, 30])
    .withMessage('Days must be 7, 15, or 30.'),
];

/* ── Routes ──────────────────────────────────────── */
router.post('/purchase', purchaseValidation, validate, purchaseRentalPeriod);
router.get('/my', getOwnerRentals);

module.exports = router;
