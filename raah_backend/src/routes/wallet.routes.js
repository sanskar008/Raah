const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const authorise = require('../middlewares/role');
const { ROLES } = require('../utils/constants');
const { getWallet, withdraw } = require('../controllers/wallet.controller');

const router = Router();

/* ── All wallet routes require broker authentication ─ */
router.use(authenticate, authorise(ROLES.BROKER));

/* ── Validation for withdrawal ───────────────────── */
const withdrawValidation = [
  body('amount')
    .notEmpty()
    .withMessage('Amount is required.')
    .isFloat({ gt: 0 })
    .withMessage('Amount must be a positive number.'),
];

/* ── Routes ──────────────────────────────────────── */

/**
 * @swagger
 * /wallet:
 *   get:
 *     summary: Get broker's wallet balance and transaction history
 *     tags: [Wallet]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 20
 *     responses:
 *       200:
 *         description: Wallet details fetched
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *                       properties:
 *                         balance:
 *                           type: number
 *                           example: 120
 *                         transactions:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/WalletTransaction'
 *                         pagination:
 *                           $ref: '#/components/schemas/Pagination'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – brokers only
 */
router.get('/', getWallet);

/**
 * @swagger
 * /wallet/withdraw:
 *   post:
 *     summary: Withdraw coins from broker's wallet
 *     description: |
 *       Deducts the specified amount from the broker's wallet.
 *       The withdrawal is atomic – concurrent requests are handled safely.
 *     tags: [Wallet]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/WithdrawRequest'
 *     responses:
 *       200:
 *         description: Withdrawal successful
 *         content:
 *           application/json:
 *             schema:
 *               allOf:
 *                 - $ref: '#/components/schemas/SuccessResponse'
 *                 - type: object
 *                   properties:
 *                     data:
 *                       type: object
 *                       properties:
 *                         newBalance:
 *                           type: number
 *                           example: 70
 *                         transaction:
 *                           $ref: '#/components/schemas/WalletTransaction'
 *       400:
 *         description: Insufficient balance or invalid amount
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – brokers only
 *       422:
 *         description: Validation error
 */
router.post('/withdraw', withdrawValidation, validate, withdraw);

module.exports = router;
