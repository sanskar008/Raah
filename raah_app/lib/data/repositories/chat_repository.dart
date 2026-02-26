import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';

class ChatRepository {
  final ApiService _apiService;

  ChatRepository({required ApiService apiService}) : _apiService = apiService;

  Future<Map<String, dynamic>> getOrCreateConversation(String propertyId) async {
    final response = await _apiService.post(
      ApiEndpoints.chatConversation,
      body: {'propertyId': propertyId},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMyConversations({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.chatConversations,
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _apiService.get(
      ApiEndpoints.chatMessages(conversationId),
      queryParams: {'page': page.toString(), 'limit': limit.toString()},
    );
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sendMessage(
    String conversationId,
    String text,
  ) async {
    final response = await _apiService.post(
      ApiEndpoints.chatMessages(conversationId),
      body: {'text': text},
    );
    return response as Map<String, dynamic>;
  }
}
