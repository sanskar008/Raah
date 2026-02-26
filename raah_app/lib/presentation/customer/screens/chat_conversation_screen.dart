import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/property_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';

/// Single chat conversation with room owner for a property.
class ChatConversationScreen extends StatefulWidget {
  final PropertyModel property;
  final String? conversationId;
  final String ownerName;

  const ChatConversationScreen({
    super.key,
    required this.property,
    this.conversationId,
    required this.ownerName,
  });

  @override
  State<ChatConversationScreen> createState() => _ChatConversationScreenState();
}

class _ChatConversationScreenState extends State<ChatConversationScreen> {
  final _textController = TextEditingController();
  String? _activeConversationId;

  @override
  void initState() {
    super.initState();
    if (widget.conversationId != null) {
      _activeConversationId = widget.conversationId;
      context.read<ChatViewModel>().loadMessages(widget.conversationId!);
    } else {
      _getOrCreateAndLoad();
    }
  }

  Future<void> _getOrCreateAndLoad() async {
    final chatVM = context.read<ChatViewModel>();
    final conv = await chatVM.getOrCreateConversation(widget.property.id);
    if (conv != null && mounted) {
      final id = conv['_id']?.toString() ?? conv['id']?.toString();
      if (id != null) {
        setState(() => _activeConversationId = id);
        await chatVM.loadMessages(id);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.ownerName),
            Text(
              widget.property.title,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatVM.isLoading && chatVM.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : chatVM.messages.isEmpty
                    ? Center(
                        child: Text(
                          'Send a message to start the conversation',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(AppConstants.spacingMd),
                        reverse: true,
                        itemCount: chatVM.messages.length,
                        itemBuilder: (context, index) {
                          final msg = chatVM.messages[chatVM.messages.length - 1 - index];
                          return _buildMessageBubble(msg, chatVM);
                        },
                      ),
          ),
          if (chatVM.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                chatVM.error!,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
              ),
            ),
          _buildInputBar(chatVM),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, ChatViewModel chatVM) {
    final authVM = context.read<AuthViewModel>();
    final myId = authVM.user?.id ?? '';
    final sender = msg['senderId'];
    final senderId = sender is Map ? sender['_id']?.toString() : sender?.toString();
    final isMe = senderId == myId;
    final text = msg['text'] ?? '';
    final senderName = sender is Map ? sender['name'] ?? 'User' : 'User';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              Text(
                senderName,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 2),
            Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isMe ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatViewModel chatVM) {
    if (_activeConversationId == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.only(
        left: AppConstants.spacingMd,
        right: AppConstants.spacingMd,
        top: AppConstants.spacingSm,
        bottom: MediaQuery.of(context).padding.bottom + AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: 3,
              minLines: 1,
              onSubmitted: (_) => _send(chatVM),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: chatVM.isSending ? null : () => _send(chatVM),
            icon: chatVM.isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }

  Future<void> _send(ChatViewModel chatVM) async {
    final text = _textController.text.trim();
    if (text.isEmpty || _activeConversationId == null) return;

    final ok = await chatVM.sendMessage(_activeConversationId!, text);
    if (ok) _textController.clear();
  }
}
