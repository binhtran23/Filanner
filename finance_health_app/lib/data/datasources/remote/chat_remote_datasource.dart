import 'dart:async';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/network/dio_client.dart';
import '../../models/chat_message_model.dart';

/// Remote data source cho Chat
abstract class ChatRemoteDataSource {
  Future<ChatMessageModel> sendMessage({
    required String content,
    String? conversationId,
  });

  Future<List<ChatMessageModel>> getChatHistory({
    String? conversationId,
    int page,
    int pageSize,
  });

  Future<List<ConversationModel>> getConversations();

  Future<ConversationModel> createConversation({String? title});

  Future<void> deleteConversation(String conversationId);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient dioClient;

  ChatRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<ChatMessageModel> sendMessage({
    required String content,
    String? conversationId,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.chatMessage,
        data: {'content': content, 'conversation_id': conversationId},
      );
      return ChatMessageModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ChatMessageModel>> getChatHistory({
    String? conversationId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await dioClient.get(
        ApiEndpoints.chatHistory,
        queryParameters: {
          if (conversationId != null) 'conversation_id': conversationId,
          'page': page,
          'page_size': pageSize,
        },
      );
      return (response.data as List)
          .map((e) => ChatMessageModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    try {
      final response = await dioClient.get(
        '${ApiEndpoints.chatHistory}/conversations',
      );
      return (response.data as List)
          .map((e) => ConversationModel.fromJson(e))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ConversationModel> createConversation({String? title}) async {
    try {
      final response = await dioClient.post(
        '${ApiEndpoints.chatHistory}/conversations',
        data: {'title': title},
      );
      return ConversationModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await dioClient.delete(
        '${ApiEndpoints.chatHistory}/conversations/$conversationId',
      );
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
