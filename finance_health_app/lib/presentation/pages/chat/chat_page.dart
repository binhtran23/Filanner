import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart' hide ChatState;
import 'package:uuid/uuid.dart';

import '../../../app/theme/colors.dart';
import '../../../domain/entities/chat_message.dart' as domain;
import '../../blocs/chat/chat_bloc.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<types.Message> _messages = [];
  final _user = const types.User(id: 'user', firstName: 'Bạn');
  final _aiUser = const types.User(
    id: 'ai',
    firstName: 'Trợ Lý AI',
    imageUrl: 'https://api.dicebear.com/7.x/bottts/png?seed=finance',
  );

  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(const ChatLoadHistory());
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = types.TextMessage(
      author: _aiUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text:
          'Xin chào! 👋 Tôi là trợ lý tài chính AI của bạn.\n\n'
          'Tôi có thể giúp bạn:\n'
          '• Phân tích chi tiêu và đưa ra lời khuyên\n'
          '• Lập kế hoạch tiết kiệm\n'
          '• Tư vấn đầu tư phù hợp\n'
          '• Trả lời các câu hỏi về tài chính cá nhân\n\n'
          'Hãy hỏi tôi bất cứ điều gì về tài chính nhé!',
    );
    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(Icons.smart_toy, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Trợ Lý Tài Chính', style: TextStyle(fontSize: 16)),
                Text(
                  _isTyping ? 'Đang trả lời...' : 'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: _isTyping ? AppColors.accent : AppColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showConversationHistory(),
            tooltip: 'Lịch sử hội thoại',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'new':
                  _startNewConversation();
                  break;
                case 'clear':
                  _clearConversation();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add),
                    SizedBox(width: 8),
                    Text('Cuộc trò chuyện mới'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 8),
                    Text('Xóa tin nhắn'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
            setState(() {
              _isTyping = false;
            });
          }

          if (state is ChatLoaded && !state.isSending) {
            // Update messages from loaded state
            if (state.messages.isNotEmpty) {
              final latestMessage = state.messages.first;
              if (latestMessage.role == domain.MessageRole.assistant) {
                final message = _convertToFlutterChatMessage(
                  latestMessage,
                  isAi: true,
                );
                setState(() {
                  _messages.insert(0, message);
                  _isTyping = false;
                });
              }
            }
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Quick Actions
              _buildQuickActions(),

              // Chat Messages
              Expanded(
                child: Chat(
                  messages: _messages,
                  onSendPressed: _handleSendPressed,
                  user: _user,
                  showUserNames: true,
                  showUserAvatars: true,
                  theme: _buildChatTheme(),
                  l10n: const ChatL10nVi(),
                  inputOptions: InputOptions(
                    sendButtonVisibilityMode: SendButtonVisibilityMode.always,
                  ),
                  emptyState: _buildEmptyState(),
                  typingIndicatorOptions: TypingIndicatorOptions(
                    typingUsers: _isTyping ? [_aiUser] : [],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    final quickActions = [
      ('💰', 'Phân tích chi tiêu'),
      ('📊', 'Tư vấn đầu tư'),
      ('🏦', 'Kế hoạch tiết kiệm'),
      ('💡', 'Lời khuyên'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.surface,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: quickActions.map((action) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                avatar: Text(action.$1, style: const TextStyle(fontSize: 14)),
                label: Text(action.$2, style: const TextStyle(fontSize: 12)),
                onPressed: () => _handleQuickAction(action.$2),
                backgroundColor: Colors.white,
                side: BorderSide(color: AppColors.divider),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Bắt đầu cuộc trò chuyện',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  DefaultChatTheme _buildChatTheme() {
    return DefaultChatTheme(
      primaryColor: AppColors.primary,
      backgroundColor: Colors.white,
      inputBackgroundColor: AppColors.surface,
      inputTextColor: AppColors.textPrimary,
      inputBorderRadius: BorderRadius.circular(24),
      messageBorderRadius: 16,
      sentMessageBodyTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        height: 1.4,
      ),
      receivedMessageBodyTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        height: 1.4,
      ),
      receivedMessageDocumentIconColor: AppColors.primary,
      sentMessageDocumentIconColor: Colors.white,
      inputTextCursorColor: AppColors.primary,
      inputTextDecoration: InputDecoration(
        hintText: 'Nhập tin nhắn...',
        hintStyle: TextStyle(color: AppColors.textSecondary),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
      sendButtonIcon: Icon(Icons.send_rounded, color: AppColors.primary),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _messages.insert(0, textMessage);
      _isTyping = true;
    });

    // Send to AI
    context.read<ChatBloc>().add(ChatSendMessage(content: message.text));
  }

  void _handleQuickAction(String action) {
    String message;
    switch (action) {
      case 'Phân tích chi tiêu':
        message = 'Hãy phân tích chi tiêu của tôi trong tháng này';
        break;
      case 'Tư vấn đầu tư':
        message = 'Tôi nên đầu tư vào đâu với mức tiết kiệm hiện tại?';
        break;
      case 'Kế hoạch tiết kiệm':
        message = 'Giúp tôi lập kế hoạch tiết kiệm hàng tháng';
        break;
      case 'Lời khuyên':
        message = 'Cho tôi một số lời khuyên về quản lý tài chính cá nhân';
        break;
      default:
        message = action;
    }

    _handleSendPressed(types.PartialText(text: message));
  }

  types.TextMessage _convertToFlutterChatMessage(
    domain.ChatMessage message, {
    required bool isAi,
  }) {
    return types.TextMessage(
      author: isAi ? _aiUser : _user,
      createdAt: message.createdAt.millisecondsSinceEpoch,
      id: message.id,
      text: message.content,
    );
  }

  void _showConversationHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return BlocBuilder<ChatBloc, ChatState>(
            builder: (context, state) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'Lịch sử hội thoại',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: state is ChatLoaded && state.conversations.isNotEmpty
                        ? ListView.builder(
                            controller: scrollController,
                            itemCount: state.conversations.length,
                            itemBuilder: (context, index) {
                              final conv = state.conversations[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primary.withOpacity(0.1),
                                  child: Icon(
                                    Icons.chat_bubble_outline,
                                    color: AppColors.primary,
                                  ),
                                ),
                                title: Text(
                                  conv.title ?? 'Cuộc trò chuyện',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  _formatDate(conv.updatedAt ?? conv.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.read<ChatBloc>().add(
                                    ChatLoadHistory(conversationId: conv.id),
                                  );
                                },
                              );
                            },
                          )
                        : const Center(
                            child: Text('Chưa có lịch sử hội thoại'),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _startNewConversation() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
    context.read<ChatBloc>().add(const ChatNewConversation());
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tin nhắn'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả tin nhắn trong cuộc trò chuyện này?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hôm nay, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Hôm qua';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Vietnamese localization for chat
class ChatL10nVi extends ChatL10nEn {
  const ChatL10nVi({
    super.attachmentButtonAccessibilityLabel = 'Gửi file',
    super.emptyChatPlaceholder = 'Chưa có tin nhắn',
    super.fileButtonAccessibilityLabel = 'File',
    super.inputPlaceholder = 'Nhập tin nhắn...',
    super.sendButtonAccessibilityLabel = 'Gửi',
    super.unreadMessagesLabel = 'Tin nhắn chưa đọc',
  });
}
