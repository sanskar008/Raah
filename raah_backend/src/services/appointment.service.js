const Appointment = require('../models/Appointment');
const Property = require('../models/Property');
const ApiError = require('../utils/ApiError');
const { APPOINTMENT_STATUS } = require('../utils/constants');

/**
 * Book a new appointment for a property visit.
 *
 * Business rules:
 *  - Only customers can book appointments.
 *  - The property must exist.
 *  - Prevent duplicate pending appointments for the same customer + property.
 */
const bookAppointment = async ({ propertyId, date, time }, customerId) => {
  const property = await Property.findById(propertyId);
  if (!property) {
    throw new ApiError(404, 'Property not found.');
  }

  // Check for existing pending appointment
  const existing = await Appointment.findOne({
    propertyId,
    customerId,
    status: APPOINTMENT_STATUS.PENDING,
  });

  if (existing) {
    throw new ApiError(
      409,
      'You already have a pending appointment for this property.'
    );
  }

  const appointment = await Appointment.create({
    propertyId,
    customerId,
    ownerId: property.ownerId,
    date,
    time,
    status: APPOINTMENT_STATUS.PENDING,
  });

  return appointment;
};

/**
 * Get all appointments belonging to the current customer.
 */
const getMyAppointments = async (customerId, query) => {
  const { page = 1, limit = 10, status } = query;
  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(50, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const filter = { customerId };
  if (status) filter.status = status;

  const [appointments, total] = await Promise.all([
    Appointment.find(filter)
      .sort('-createdAt')
      .skip(skip)
      .limit(pageSize)
      .populate('propertyId', 'title area city rent images')
      .populate('ownerId', 'name phone')
      .lean(),
    Appointment.countDocuments(filter),
  ]);

  return {
    appointments,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

/**
 * Get all appointments received by the property owner.
 */
const getReceivedAppointments = async (ownerId, query) => {
  const { page = 1, limit = 10, status } = query;
  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(50, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const filter = { ownerId };
  if (status) filter.status = status;

  const [appointments, total] = await Promise.all([
    Appointment.find(filter)
      .sort('-createdAt')
      .skip(skip)
      .limit(pageSize)
      .populate('propertyId', 'title area city rent images')
      .populate('customerId', 'name email phone')
      .lean(),
    Appointment.countDocuments(filter),
  ]);

  return {
    appointments,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

/**
 * Update appointment status (accept / reject).
 *
 * Business rules:
 *  - Only the property owner can accept or reject.
 *  - Appointment must be in 'pending' status.
 */
const updateAppointmentStatus = async (appointmentId, newStatus, ownerId) => {
  const appointment = await Appointment.findById(appointmentId);
  if (!appointment) {
    throw new ApiError(404, 'Appointment not found.');
  }

  // Ensure only the property owner can modify
  if (appointment.ownerId.toString() !== ownerId.toString()) {
    throw new ApiError(403, 'You are not authorised to modify this appointment.');
  }

  if (appointment.status !== APPOINTMENT_STATUS.PENDING) {
    throw new ApiError(
      400,
      `Appointment is already ${appointment.status}. Only pending appointments can be updated.`
    );
  }

  appointment.status = newStatus;
  await appointment.save();

  return appointment;
};

module.exports = {
  bookAppointment,
  getMyAppointments,
  getReceivedAppointments,
  updateAppointmentStatus,
};
