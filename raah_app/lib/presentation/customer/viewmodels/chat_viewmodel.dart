import 'package:flutter/material.dart';
import '../../../core/utils/error_messages.dart';
import '../../../data/repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatViewModel({required ChatRepository chatRepository})
      : _chatRepository = chatRepository;

  List<Map<String, dynamic>> _conversations = [];
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _error;
  Map<String, dynamic>? _currentConversation;

  List<Map<String, dynamic>> get conversations => _conversations;
  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get error => _error;
  Map<String, dynamic>? get currentConversation => _currentConversation;

  Future<Map<String, dynamic>?> getOrCreateConversation(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _chatRepository.getOrCreateConversation(propertyId);
      _currentConversation = result['conversation'] as Map<String, dynamic>?;
      _isLoading = false;
      notifyListeners();
      return _currentConversation;
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _chatRepository.getMyConversations();
      _conversations = List<Map<String, dynamic>>.from(result['conversations'] ?? []);
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMessages(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _chatRepository.getMessages(conversationId);
      _messages = List<Map<String, dynamic>>.from(result['messages'] ?? []);
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendMessage(String conversationId, String text) async {
    if (text.trim().isEmpty) return false;

    _isSending = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _chatRepository.sendMessage(conversationId, text.trim());
      final message = result['message'] as Map<String, dynamic>?;
      if (message != null) {
        _messages = [..._messages, message];
      }
      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = ErrorMessages.getFriendlyMessage(e);
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  void setCurrentConversation(Map<String, dynamic>? conv) {
    _currentConversation = conv;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
