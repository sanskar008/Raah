const asyncHandler = require('../utils/asyncHandler');
const ApiResponse = require('../utils/ApiResponse');
const chatService = require('../services/chat.service');

/**
 * POST /api/chat/conversation
 * Get or create conversation for a property (customer starts chat).
 */
const getOrCreateConversation = asyncHandler(async (req, res) => {
  const { propertyId } = req.body;
  if (!propertyId) {
    return res.status(400).json(new ApiResponse(400, 'Property ID is required.', null));
  }
  const conversation = await chatService.getOrCreateConversation(req.user._id, propertyId);
  res.status(200).json(new ApiResponse(200, 'Conversation ready.', { conversation }));
});

/**
 * GET /api/chat/conversations
 * Get my conversations list.
 */
const getMyConversations = asyncHandler(async (req, res) => {
  const result = await chatService.getMyConversations(req.user._id, req.query);
  res.status(200).json(new ApiResponse(200, 'Conversations fetched.', result));
});

/**
 * GET /api/chat/conversations/:id/messages
 * Get messages for a conversation.
 */
const getMessages = asyncHandler(async (req, res) => {
  const result = await chatService.getMessages(req.params.id, req.user._id, req.query);
  res.status(200).json(new ApiResponse(200, 'Messages fetched.', result));
});

/**
 * POST /api/chat/conversations/:id/messages
 * Send a message.
 */
const sendMessage = asyncHandler(async (req, res) => {
  const { text } = req.body;
  const message = await chatService.sendMessage(req.params.id, req.user._id, text);
  res.status(201).json(new ApiResponse(201, 'Message sent.', { message }));
});

module.exports = {
  getOrCreateConversation,
  getMyConversations,
  getMessages,
  sendMessage,
};
