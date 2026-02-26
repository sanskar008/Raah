const Conversation = require('../models/Conversation');
const Message = require('../models/Message');
const Property = require('../models/Property');
const ApiError = require('../utils/ApiError');
const { ROLES } = require('../utils/constants');

/**
 * Get or create a conversation between the current user (customer) and the property owner.
 */
const getOrCreateConversation = async (userId, propertyId) => {
  const property = await Property.findById(propertyId).lean();
  if (!property) throw new ApiError(404, 'Property not found.');

  const ownerId = property.ownerId;

  let conversation = await Conversation.findOne({
    propertyId,
    customerId: userId,
  })
    .populate('propertyId', 'title city area images rent')
    .populate('ownerId', 'name')
    .populate('customerId', 'name')
    .lean();

  if (conversation) {
    return conversation;
  }

  conversation = await Conversation.create({
    propertyId,
    customerId: userId,
    ownerId,
  });

  return Conversation.findById(conversation._id)
    .populate('propertyId', 'title city area images rent')
    .populate('ownerId', 'name')
    .populate('customerId', 'name')
    .lean();
};

/**
 * Get messages for a conversation. Only participant (customer or owner) can read.
 */
const getMessages = async (conversationId, userId, query) => {
  const conversation = await Conversation.findById(conversationId).lean();
  if (!conversation) throw new ApiError(404, 'Conversation not found.');

  const isParticipant =
    conversation.customerId.toString() === userId.toString() ||
    conversation.ownerId.toString() === userId.toString();
  if (!isParticipant) throw new ApiError(403, 'You are not part of this conversation.');

  const { page = 1, limit = 50 } = query;
  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(100, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const [messages, total] = await Promise.all([
    Message.find({ conversationId })
      .sort({ createdAt: 1 })
      .skip(skip)
      .limit(pageSize)
      .populate('senderId', 'name')
      .lean(),
    Message.countDocuments({ conversationId }),
  ]);

  return {
    messages,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

/**
 * Send a message. Only customer or owner can send.
 */
const sendMessage = async (conversationId, userId, text) => {
  const conversation = await Conversation.findById(conversationId);
  if (!conversation) throw new ApiError(404, 'Conversation not found.');

  const isParticipant =
    conversation.customerId.toString() === userId.toString() ||
    conversation.ownerId.toString() === userId.toString();
  if (!isParticipant) throw new ApiError(403, 'You are not part of this conversation.');

  const trimmed = String(text).trim();
  if (!trimmed) throw new ApiError(400, 'Message text is required.');

  const message = await Message.create({
    conversationId,
    senderId: userId,
    text: trimmed,
  });

  await Conversation.findByIdAndUpdate(conversationId, {
    lastMessageAt: new Date(),
    lastMessageText: trimmed.length > 100 ? trimmed.slice(0, 97) + '...' : trimmed,
  });

  return Message.findById(message._id).populate('senderId', 'name').lean();
};

/**
 * Get all conversations for the current user (as customer or as owner).
 */
const getMyConversations = async (userId, query) => {
  const { page = 1, limit = 20 } = query;
  const pageNum = Math.max(1, Number(page));
  const pageSize = Math.min(50, Math.max(1, Number(limit)));
  const skip = (pageNum - 1) * pageSize;

  const filter = {
    $or: [{ customerId: userId }, { ownerId: userId }],
  };

  const [conversations, total] = await Promise.all([
    Conversation.find(filter)
      .sort({ lastMessageAt: -1, createdAt: -1 })
      .skip(skip)
      .limit(pageSize)
      .populate('propertyId', 'title city area images rent')
      .populate('ownerId', 'name')
      .populate('customerId', 'name')
      .lean(),
    Conversation.countDocuments(filter),
  ]);

  return {
    conversations,
    pagination: {
      total,
      page: pageNum,
      limit: pageSize,
      totalPages: Math.ceil(total / pageSize),
    },
  };
};

module.exports = {
  getOrCreateConversation,
  getMessages,
  sendMessage,
  getMyConversations,
};
