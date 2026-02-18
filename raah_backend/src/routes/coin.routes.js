const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const authorise = require('../middlewares/role');
const { ROLES } = require('../utils/constants');
const {
  getCoinPacks,
  purchaseCoinPack,
  unlockProperty,
  getCustomerWallet,
} = require('../controllers/coin.controller');

const router = Router();

/* ── Public routes ────────────────────────────────── */
router.get('/packs', getCoinPacks);

/* ── Customer-only routes ────────────────────────── */
router.use(authenticate, authorise(ROLES.CUSTOMER));

/* ── Validation ──────────────────────────────────── */
const purchaseValidation = [
  body('packId').notEmpty().withMessage('Pack ID is required.'),
];

const unlockValidation = [
  body('propertyId').notEmpty().withMessage('Property ID is required.'),
];

/* ── Routes ──────────────────────────────────────── */
router.post('/purchase', purchaseValidation, validate, purchaseCoinPack);
router.post('/unlock-property', unlockValidation, validate, unlockProperty);
router.get('/wallet', getCustomerWallet);

module.exports = router;
