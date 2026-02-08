const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const appointmentService = require('../services/appointment.service');
const { APPOINTMENT_STATUS } = require('../utils/constants');

/**
 * @route   POST /api/appointments/book
 * @desc    Book a visit appointment for a property
 * @access  Private – Customer
 */
const bookAppointment = asyncHandler(async (req, res) => {
  const { propertyId, date, time } = req.body;

  const appointment = await appointmentService.bookAppointment(
    { propertyId, date, time },
    req.user._id
  );

  res.status(201).json(new ApiResponse(201, 'Appointment booked successfully.', { appointment }));
});

/**
 * @route   GET /api/appointments/my
 * @desc    Get customer's own appointments
 * @access  Private – Customer
 */
const getMyAppointments = asyncHandler(async (req, res) => {
  const result = await appointmentService.getMyAppointments(req.user._id, req.query);

  res.status(200).json(new ApiResponse(200, 'Your appointments fetched.', result));
});

/**
 * @route   GET /api/appointments/received
 * @desc    Get appointments received by the property owner
 * @access  Private – Owner
 */
const getReceivedAppointments = asyncHandler(async (req, res) => {
  const result = await appointmentService.getReceivedAppointments(req.user._id, req.query);

  res.status(200).json(new ApiResponse(200, 'Received appointments fetched.', result));
});

/**
 * @route   POST /api/appointments/:id/accept
 * @desc    Accept a pending appointment
 * @access  Private – Owner
 */
const acceptAppointment = asyncHandler(async (req, res) => {
  const appointment = await appointmentService.updateAppointmentStatus(
    req.params.id,
    APPOINTMENT_STATUS.ACCEPTED,
    req.user._id
  );

  res
    .status(200)
    .json(new ApiResponse(200, 'Appointment accepted.', { appointment }));
});

/**
 * @route   POST /api/appointments/:id/reject
 * @desc    Reject a pending appointment
 * @access  Private – Owner
 */
const rejectAppointment = asyncHandler(async (req, res) => {
  const appointment = await appointmentService.updateAppointmentStatus(
    req.params.id,
    APPOINTMENT_STATUS.REJECTED,
    req.user._id
  );

  res
    .status(200)
    .json(new ApiResponse(200, 'Appointment rejected.', { appointment }));
});

module.exports = {
  bookAppointment,
  getMyAppointments,
  getReceivedAppointments,
  acceptAppointment,
  rejectAppointment,
};
