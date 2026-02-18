const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const optionalAuthenticate = require('../middlewares/optionalAuth');
const authorise = require('../middlewares/role');
const { ROLES } = require('../utils/constants');
const {
  createProperty,
  listProperties,
  getMyProperties,
  getPropertyById,
} = require('../controllers/property.controller');

const router = Router();

/* ── Validation chain for creating a property ────── */
const createPropertyValidation = [
  body('title').trim().notEmpty().withMessage('Title is required.'),
  body('description').trim().notEmpty().withMessage('Description is required.'),
  body('rent').isNumeric().withMessage('Rent must be a number.'),
  body('deposit').isNumeric().withMessage('Deposit must be a number.'),
  body('area').trim().notEmpty().withMessage('Area / locality is required.'),
  body('city').trim().notEmpty().withMessage('City is required.'),
  body('images').optional().isArray().withMessage('Images must be an array of URLs.'),
  body('amenities').optional().isArray().withMessage('Amenities must be an array.'),
];

/* ── Routes ──────────────────────────────────────── */

/**
 * @swagger
 * /properties:
 *   get:
 *     summary: Browse properties with filters and pagination
 *     tags: [Properties]
 *     parameters:
 *       - in: query
 *         name: area
 *         schema:
 *           type: string
 *         description: Filter by area / locality (case-insensitive partial match)
 *       - in: query
 *         name: city
 *         schema:
 *           type: string
 *         description: Filter by city (case-insensitive partial match)
 *       - in: query
 *         name: minRent
 *         schema:
 *           type: number
 *         description: Minimum rent filter
 *       - in: query
 *         name: maxRent
 *         schema:
 *           type: number
 *         description: Maximum rent filter
 *       - in: query
 *         name: amenities
 *         schema:
 *           type: string
 *         description: Comma-separated amenities (match any)
 *         example: WiFi,Parking
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *           default: 1
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           default: 10
 *         description: Items per page (max 50)
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           default: -createdAt
 *         description: Sort field (prefix with - for descending)
 *     responses:
 *       200:
 *         description: Properties fetched successfully
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
 *                         properties:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/Property'
 *                         pagination:
 *                           $ref: '#/components/schemas/Pagination'
 */
router.get('/', listProperties);

/**
 * @swagger
 * /properties/my:
 *   get:
 *     summary: Get properties listed by the current user
 *     tags: [Properties]
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
 *           default: 10
 *       - in: query
 *         name: sort
 *         schema:
 *           type: string
 *           default: -createdAt
 *     responses:
 *       200:
 *         description: Your properties fetched
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
 *                         properties:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/Property'
 *                         pagination:
 *                           $ref: '#/components/schemas/Pagination'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – only brokers and owners
 */
router.get(
  '/my',
  authenticate,
  authorise(ROLES.BROKER, ROLES.OWNER),
  getMyProperties
);

/**
 * @swagger
 * /properties/{id}:
 *   get:
 *     summary: Get a single property by ID
 *     tags: [Properties]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Property ID (MongoDB ObjectId)
 *     responses:
 *       200:
 *         description: Property details fetched
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
 *                         property:
 *                           $ref: '#/components/schemas/Property'
 *       404:
 *         description: Property not found
 */
// Optional auth for getPropertyById - allows checking unlock status for customers
router.get('/:id', optionalAuthenticate, getPropertyById);

/**
 * @swagger
 * /properties:
 *   post:
 *     summary: Create a new property listing
 *     description: |
 *       **Brokers** and **Owners** can create listings.
 *       - Owners are automatically set as the property owner.
 *       - Brokers earn wallet coins on successful upload.
 *     tags: [Properties]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreatePropertyRequest'
 *     responses:
 *       201:
 *         description: Property created successfully
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
 *                         property:
 *                           $ref: '#/components/schemas/Property'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – only brokers and owners
 *       422:
 *         description: Validation error
 */
router.post(
  '/',
  authenticate,
  authorise(ROLES.BROKER, ROLES.OWNER),
  createPropertyValidation,
  validate,
  createProperty
);

module.exports = router;
