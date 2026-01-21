import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/chat_message.dart';

/// Repository interface cho Chatbot AI
abstract class ChatRepository {
  /// Gửi tin nhắn và nhận phản hồi từ AI
  Future<Either<Failure, ChatMessage>> sendMessage({
    required String content,
    String? conversationId,
  });

  /// Lấy lịch sử chat
  Future<Either<Failure, List<ChatMessage>>> getChatHistory({
    String? conversationId,
    int page = 1,
    int pageSize = 20,
  });

  /// Lấy danh sách cuộc hội thoại
  Future<Either<Failure, List<Conversation>>> getConversations();

  /// Tạo cuộc hội thoại mới
  Future<Either<Failure, Conversation>> createConversation({String? title});

  /// Xóa cuộc hội thoại
  Future<Either<Failure, void>> deleteConversation(String conversationId);

  /// Stream tin nhắn từ WebSocket (cho real-time chat)
  Stream<ChatMessage> get messageStream;

  /// Kết nối WebSocket
  Future<Either<Failure, void>> connectWebSocket();

  /// Ngắt kết nối WebSocket
  Future<Either<Failure, void>> disconnectWebSocket();
}
