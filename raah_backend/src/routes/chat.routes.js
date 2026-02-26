const { Router } = require('express');
const { body } = require('express-validator');
const validate = require('../middlewares/validate');
const authenticate = require('../middlewares/auth');
const {
  getOrCreateConversation,
  getMyConversations,
  getMessages,
  sendMessage,
} = require('../controllers/chat.controller');

const router = Router();

router.use(authenticate);

const conversationValidation = [
  body('propertyId').notEmpty().withMessage('Property ID is required.'),
];

const sendMessageValidation = [
  body('text').trim().notEmpty().withMessage('Message text is required.'),
];

router.post('/conversation', conversationValidation, validate, getOrCreateConversation);
router.get('/conversations', getMyConversations);
router.get('/conversations/:id/messages', getMessages);
router.post('/conversations/:id/messages', sendMessageValidation, validate, sendMessage);

module.exports = router;
