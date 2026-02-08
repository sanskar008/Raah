const swaggerJsdoc = require('swagger-jsdoc');

/**
 * OpenAPI 3.0 specification generated from JSDoc annotations
 * found in the route files.
 *
 * Visit  /api-docs  when the server is running to explore the UI.
 */
const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Raah — Rental Discovery Platform API',
      version: '1.0.0',
      description:
        'REST API documentation for Raah. A role-based rental discovery platform supporting Customers, Brokers, and Room Owners.',
      contact: {
        name: 'Raah Team',
      },
    },
    servers: [
      {
        url: 'http://localhost:{port}/api',
        description: 'Local development server',
        variables: {
          port: {
            default: '5000',
          },
        },
      },
    ],

    /* ── Reusable components ─────────────────────────── */
    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: 'Enter your JWT token obtained from /auth/login or /auth/signup',
        },
      },
      schemas: {
        /* ── Request bodies ─────────────────────────── */
        SignupRequest: {
          type: 'object',
          required: ['name', 'email', 'phone', 'password'],
          properties: {
            name: { type: 'string', example: 'Sanskar Sharma' },
            email: { type: 'string', format: 'email', example: 'sanskar@example.com' },
            phone: { type: 'string', example: '9876543210' },
            password: { type: 'string', minLength: 6, example: 'secret123' },
            role: {
              type: 'string',
              enum: ['customer', 'broker', 'owner'],
              default: 'customer',
              example: 'customer',
            },
          },
        },
        LoginRequest: {
          type: 'object',
          required: ['email', 'password'],
          properties: {
            email: { type: 'string', format: 'email', example: 'sanskar@example.com' },
            password: { type: 'string', example: 'secret123' },
          },
        },
        CreatePropertyRequest: {
          type: 'object',
          required: ['title', 'description', 'rent', 'deposit', 'area', 'city'],
          properties: {
            title: { type: 'string', example: '2 BHK in Malviya Nagar' },
            description: { type: 'string', example: 'Spacious 2BHK with balcony, near metro station.' },
            rent: { type: 'number', example: 12000 },
            deposit: { type: 'number', example: 24000 },
            area: { type: 'string', example: 'Malviya Nagar' },
            city: { type: 'string', example: 'Jaipur' },
            images: {
              type: 'array',
              items: { type: 'string' },
              example: ['https://example.com/img1.jpg'],
            },
            amenities: {
              type: 'array',
              items: { type: 'string' },
              example: ['WiFi', 'Parking', 'AC'],
            },
            ownerId: {
              type: 'string',
              description: 'Required when broker lists on behalf of an owner',
              example: '665f1a2b3c4d5e6f7a8b9c0d',
            },
          },
        },
        BookAppointmentRequest: {
          type: 'object',
          required: ['propertyId', 'date', 'time'],
          properties: {
            propertyId: { type: 'string', example: '665f1a2b3c4d5e6f7a8b9c0d' },
            date: { type: 'string', format: 'date', example: '2026-03-15' },
            time: { type: 'string', example: '10:00 AM' },
          },
        },
        WithdrawRequest: {
          type: 'object',
          required: ['amount'],
          properties: {
            amount: { type: 'number', example: 50 },
          },
        },

        /* ── Response models ───────────────────────── */
        User: {
          type: 'object',
          properties: {
            _id: { type: 'string', example: '665f1a2b3c4d5e6f7a8b9c0d' },
            name: { type: 'string', example: 'Sanskar Sharma' },
            email: { type: 'string', example: 'sanskar@example.com' },
            phone: { type: 'string', example: '9876543210' },
            role: { type: 'string', enum: ['customer', 'broker', 'owner'] },
            wallet: { type: 'number', example: 0 },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        Property: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            title: { type: 'string' },
            description: { type: 'string' },
            rent: { type: 'number' },
            deposit: { type: 'number' },
            area: { type: 'string' },
            city: { type: 'string' },
            images: { type: 'array', items: { type: 'string' } },
            amenities: { type: 'array', items: { type: 'string' } },
            ownerId: { $ref: '#/components/schemas/UserSummary' },
            brokerId: { $ref: '#/components/schemas/UserSummary' },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        Appointment: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            propertyId: { type: 'string' },
            customerId: { type: 'string' },
            ownerId: { type: 'string' },
            date: { type: 'string', format: 'date-time' },
            time: { type: 'string' },
            status: { type: 'string', enum: ['pending', 'accepted', 'rejected'] },
            createdAt: { type: 'string', format: 'date-time' },
            updatedAt: { type: 'string', format: 'date-time' },
          },
        },
        WalletTransaction: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            brokerId: { type: 'string' },
            amount: { type: 'number' },
            type: { type: 'string', enum: ['credit', 'debit'] },
            reason: { type: 'string' },
            createdAt: { type: 'string', format: 'date-time' },
          },
        },
        UserSummary: {
          type: 'object',
          properties: {
            _id: { type: 'string' },
            name: { type: 'string' },
            email: { type: 'string' },
            phone: { type: 'string' },
          },
        },
        Pagination: {
          type: 'object',
          properties: {
            total: { type: 'integer', example: 42 },
            page: { type: 'integer', example: 1 },
            limit: { type: 'integer', example: 10 },
            totalPages: { type: 'integer', example: 5 },
          },
        },

        /* ── Generic response wrappers ─────────────── */
        SuccessResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: true },
            statusCode: { type: 'integer' },
            message: { type: 'string' },
            data: { type: 'object' },
          },
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            statusCode: { type: 'integer' },
            message: { type: 'string' },
            errors: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  field: { type: 'string' },
                  message: { type: 'string' },
                },
              },
            },
          },
        },
      },
    },

    /* ── Tags for grouping ───────────────────────────── */
    tags: [
      { name: 'Auth', description: 'Authentication & registration' },
      { name: 'Properties', description: 'Property listings (CRUD, search, filters)' },
      { name: 'Appointments', description: 'Booking & managing property visits' },
      { name: 'Wallet', description: 'Broker wallet & transactions' },
    ],
  },
  // Scan these files for JSDoc @swagger annotations
  apis: ['./src/routes/*.js'],
};

const swaggerSpec = swaggerJsdoc(options);

module.exports = swaggerSpec;
