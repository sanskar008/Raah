const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const authorise = require('../middlewares/role');
const { ROLES } = require('../utils/constants');
const {
  bookAppointment,
  getMyAppointments,
  getReceivedAppointments,
  acceptAppointment,
  rejectAppointment,
} = require('../controllers/appointment.controller');

const router = Router();

/* ── All appointment routes require authentication ─ */
router.use(authenticate);

/* ── Validation chain for booking ────────────────── */
const bookValidation = [
  body('propertyId')
    .notEmpty()
    .withMessage('Property ID is required.')
    .isMongoId()
    .withMessage('Invalid property ID.'),
  body('date')
    .notEmpty()
    .withMessage('Date is required.')
    .isISO8601()
    .withMessage('Date must be a valid ISO 8601 date.'),
  body('time').trim().notEmpty().withMessage('Time is required.'),
];

/* ── Customer routes ─────────────────────────────── */

/**
 * @swagger
 * /appointments/book:
 *   post:
 *     summary: Book a property visit appointment
 *     description: Only **customers** can book appointments. Duplicate pending bookings for the same property are blocked.
 *     tags: [Appointments]
 *     security:
 *       - BearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/BookAppointmentRequest'
 *     responses:
 *       201:
 *         description: Appointment booked successfully
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
 *                         appointment:
 *                           $ref: '#/components/schemas/Appointment'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – customers only
 *       404:
 *         description: Property not found
 *       409:
 *         description: Duplicate pending appointment
 *       422:
 *         description: Validation error
 */
router.post('/book', authorise(ROLES.CUSTOMER), bookValidation, validate, bookAppointment);

/**
 * @swagger
 * /appointments/my:
 *   get:
 *     summary: Get the customer's own appointments
 *     tags: [Appointments]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, accepted, rejected]
 *         description: Filter by appointment status
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
 *     responses:
 *       200:
 *         description: Appointments fetched
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
 *                         appointments:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/Appointment'
 *                         pagination:
 *                           $ref: '#/components/schemas/Pagination'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – customers only
 */
router.get('/my', authorise(ROLES.CUSTOMER), getMyAppointments);

/* ── Owner routes ────────────────────────────────── */

/**
 * @swagger
 * /appointments/received:
 *   get:
 *     summary: Get appointments received by the property owner
 *     tags: [Appointments]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [pending, accepted, rejected]
 *         description: Filter by appointment status
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
 *     responses:
 *       200:
 *         description: Received appointments fetched
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
 *                         appointments:
 *                           type: array
 *                           items:
 *                             $ref: '#/components/schemas/Appointment'
 *                         pagination:
 *                           $ref: '#/components/schemas/Pagination'
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – owners only
 */
router.get('/received', authorise(ROLES.OWNER), getReceivedAppointments);

/**
 * @swagger
 * /appointments/{id}/accept:
 *   post:
 *     summary: Accept a pending appointment
 *     description: Only the **property owner** can accept. The appointment must be in `pending` status.
 *     tags: [Appointments]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Appointment ID
 *     responses:
 *       200:
 *         description: Appointment accepted
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
 *                         appointment:
 *                           $ref: '#/components/schemas/Appointment'
 *       400:
 *         description: Appointment already processed
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – not the property owner
 *       404:
 *         description: Appointment not found
 */
router.post('/:id/accept', authorise(ROLES.OWNER), acceptAppointment);

/**
 * @swagger
 * /appointments/{id}/reject:
 *   post:
 *     summary: Reject a pending appointment
 *     description: Only the **property owner** can reject. The appointment must be in `pending` status.
 *     tags: [Appointments]
 *     security:
 *       - BearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: Appointment ID
 *     responses:
 *       200:
 *         description: Appointment rejected
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
 *                         appointment:
 *                           $ref: '#/components/schemas/Appointment'
 *       400:
 *         description: Appointment already processed
 *       401:
 *         description: Unauthorized
 *       403:
 *         description: Forbidden – not the property owner
 *       404:
 *         description: Appointment not found
 */
router.post('/:id/reject', authorise(ROLES.OWNER), rejectAppointment);

module.exports = router;
