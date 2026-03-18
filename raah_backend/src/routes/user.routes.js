const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const { getReferralInfo, updateLocation } = require('../controllers/user.controller');

const router = Router();

// All user routes require authentication
router.use(authenticate);

router.get('/referral-info', getReferralInfo);

router.put(
  '/location',
  [
    body('lat').isFloat({ min: -90, max: 90 }).withMessage('Invalid latitude.'),
    body('lng').isFloat({ min: -180, max: 180 }).withMessage('Invalid longitude.'),
    body('address').optional().trim(),
  ],
  validate,
  updateLocation
);

module.exports = router;
