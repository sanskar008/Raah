const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const propertyService = require('../services/property.service');

/**
 * @route   POST /api/properties
 * @desc    Create a new property listing
 * @access  Private – Broker, Owner
 */
const createProperty = asyncHandler(async (req, res) => {
  const property = await propertyService.createProperty(req.body, req.user);

  res.status(201).json(new ApiResponse(201, 'Property created successfully.', { property }));
});

/**
 * @route   GET /api/properties
 * @desc    List properties with filters & pagination
 * @access  Public (anyone can browse)
 */
const listProperties = asyncHandler(async (req, res) => {
  const result = await propertyService.listProperties(req.query);

  res.status(200).json(new ApiResponse(200, 'Properties fetched.', result));
});

/**
 * @route   GET /api/properties/my
 * @desc    Get properties listed by the current user
 * @access  Private – Broker, Owner
 */
const getMyProperties = asyncHandler(async (req, res) => {
  const result = await propertyService.getMyProperties(req.user, req.query);

  res.status(200).json(new ApiResponse(200, 'Your properties fetched.', result));
});

/**
 * @route   GET /api/properties/:id
 * @desc    Get a single property by ID
 * @access  Public
 */
const getPropertyById = asyncHandler(async (req, res) => {
  const property = await propertyService.getPropertyById(req.params.id);

  res.status(200).json(new ApiResponse(200, 'Property details fetched.', { property }));
});

module.exports = { createProperty, listProperties, getMyProperties, getPropertyById };
