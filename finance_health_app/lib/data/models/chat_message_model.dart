import '../../domain/entities/chat_message.dart';

/// Model cho ChatMessage với JSON serialization
class ChatMessageModel extends ChatMessage {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    super.type = MessageType.text,
    super.metadata,
    required super.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      conversationId: json['conversation_id'] as String,
      role: MessageRole.values.firstWhere(
        (r) => r.value == json['role'],
        orElse: () => MessageRole.user,
      ),
      content: json['content'] as String,
      type: MessageType.values.firstWhere(
        (t) => t.value == json['type'],
        orElse: () => MessageType.text,
      ),
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'role': role.value,
      'content': content,
      'type': type.value,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Model cho Conversation
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.userId,
    super.title,
    required super.messages,
    required super.createdAt,
    super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String?,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'messages': messages
          .map((e) => (e as ChatMessageModel).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
