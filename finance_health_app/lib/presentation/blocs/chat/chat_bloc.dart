import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/chat_message.dart';
import '../../../domain/repositories/chat_repository.dart';

/// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();
  @override
  List<Object?> get props => [];
}

class ChatLoadHistory extends ChatEvent {
  final String? conversationId;

  const ChatLoadHistory({this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class ChatSendMessage extends ChatEvent {
  final String content;

  const ChatSendMessage({required this.content});

  @override
  List<Object?> get props => [content];
}

class ChatNewConversation extends ChatEvent {
  const ChatNewConversation();
}

class ChatDeleteConversation extends ChatEvent {
  final String conversationId;

  const ChatDeleteConversation({required this.conversationId});

  @override
  List<Object?> get props => [conversationId];
}

class ChatLoadConversations extends ChatEvent {
  const ChatLoadConversations();
}

/// States
abstract class ChatState extends Equatable {
  const ChatState();
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ChatLoaded extends ChatState {
  final List<ChatMessage> messages;
  final String? conversationId;
  final List<Conversation> conversations;
  final bool isSending;

  const ChatLoaded({
    required this.messages,
    this.conversationId,
    this.conversations = const [],
    this.isSending = false,
  });

  @override
  List<Object?> get props => [
    messages,
    conversationId,
    conversations,
    isSending,
  ];

  ChatLoaded copyWith({
    List<ChatMessage>? messages,
    String? conversationId,
    List<Conversation>? conversations,
    bool? isSending,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      conversations: conversations ?? this.conversations,
      isSending: isSending ?? this.isSending,
    );
  }
}

class ChatError extends ChatState {
  final String message;

  const ChatError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// BLoC
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final _uuid = const Uuid();

  ChatBloc({required this.chatRepository}) : super(const ChatInitial()) {
    on<ChatLoadHistory>(_onLoadHistory);
    on<ChatSendMessage>(_onSendMessage);
    on<ChatNewConversation>(_onNewConversation);
    on<ChatDeleteConversation>(_onDeleteConversation);
    on<ChatLoadConversations>(_onLoadConversations);
  }

  Future<void> _onLoadHistory(
    ChatLoadHistory event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await chatRepository.getChatHistory(
      conversationId: event.conversationId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (messages) => emit(
        ChatLoaded(messages: messages, conversationId: event.conversationId),
      ),
    );
  }

  Future<void> _onSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      // Thêm tin nhắn user vào list (optimistic update)
      final userMessage = ChatMessage(
        id: _uuid.v4(),
        conversationId: currentState.conversationId ?? '',
        role: MessageRole.user,
        content: event.content,
        createdAt: DateTime.now(),
      );

      emit(
        currentState.copyWith(
          messages: [...currentState.messages, userMessage],
          isSending: true,
        ),
      );

      // Gửi tin nhắn lên server và nhận phản hồi
      final result = await chatRepository.sendMessage(
        content: event.content,
        conversationId: currentState.conversationId,
      );

      result.fold(
        (failure) {
          emit(ChatError(message: failure.message));
          // Rollback nếu lỗi
          emit(currentState);
        },
        (aiMessage) {
          final updatedState = state;
          if (updatedState is ChatLoaded) {
            emit(
              updatedState.copyWith(
                messages: [...updatedState.messages, aiMessage],
                conversationId: aiMessage.conversationId,
                isSending: false,
              ),
            );
          }
        },
      );
    }
  }

  Future<void> _onNewConversation(
    ChatNewConversation event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.createConversation();

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (conversation) =>
          emit(ChatLoaded(messages: [], conversationId: conversation.id)),
    );
  }

  Future<void> _onDeleteConversation(
    ChatDeleteConversation event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.deleteConversation(
      event.conversationId,
    );

    result.fold(
      (failure) => emit(ChatError(message: failure.message)),
      (_) => add(const ChatLoadConversations()),
    );
  }

  Future<void> _onLoadConversations(
    ChatLoadConversations event,
    Emitter<ChatState> emit,
  ) async {
    final result = await chatRepository.getConversations();

    result.fold((failure) => emit(ChatError(message: failure.message)), (
      conversations,
    ) {
      final currentState = state;
      if (currentState is ChatLoaded) {
        emit(currentState.copyWith(conversations: conversations));
      } else {
        emit(ChatLoaded(messages: [], conversations: conversations));
      }
    });
  }
}
