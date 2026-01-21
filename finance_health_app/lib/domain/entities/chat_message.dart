import 'package:equatable/equatable.dart';

/// Entity đại diện cho tin nhắn chat
class ChatMessage extends Equatable {
  final String id;
  final String conversationId;
  final MessageRole role;
  final String content;
  final MessageType type;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    this.type = MessageType.text,
    this.metadata,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    conversationId,
    role,
    content,
    type,
    metadata,
    createdAt,
  ];
}

/// Entity đại diện cho cuộc hội thoại
class Conversation extends Equatable {
  final String id;
  final String userId;
  final String? title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Conversation({
    required this.id,
    required this.userId,
    this.title,
    required this.messages,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    messages,
    createdAt,
    updatedAt,
  ];
}

/// Vai trò của người gửi tin nhắn
enum MessageRole {
  user('user'),
  assistant('assistant'),
  system('system');

  final String value;
  const MessageRole(this.value);
}

/// Loại tin nhắn
enum MessageType {
  text('text'),
  suggestion('suggestion'),
  chart('chart'),
  planUpdate('plan_update'),
  error('error');

  final String value;
  const MessageType(this.value);
}
