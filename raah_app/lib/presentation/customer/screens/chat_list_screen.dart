import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/property_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import 'chat_conversation_screen.dart';

/// List of chat conversations (with room owners).
class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatVM = context.watch<ChatViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: chatVM.isLoading && chatVM.conversations.isEmpty
          ? const LoadingWidget()
          : chatVM.conversations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 64,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      Text(
                        'No conversations yet',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spacingSm),
                      Text(
                        'Tap Inquiry or Chat on a property to start',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => chatVM.loadConversations(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    itemCount: chatVM.conversations.length,
                    itemBuilder: (context, index) {
                      final conv = chatVM.conversations[index];
                      return _buildConversationTile(context, conv);
                    },
                  ),
                ),
    );
  }

  Widget _buildConversationTile(BuildContext context, Map<String, dynamic> conv) {
    final property = conv['propertyId'] as Map<String, dynamic>? ?? {};
    final owner = conv['ownerId'] as Map<String, dynamic>? ?? {};
    final customer = conv['customerId'] as Map<String, dynamic>? ?? {};
    final authVM = context.read<AuthViewModel>();
    final myId = authVM.user?.id ?? '';
    final isOwner = conv['ownerId'] != null &&
        (owner['_id']?.toString() ?? owner['id']?.toString()) == myId;
    final otherName = isOwner
        ? (customer['name'] ?? 'Customer')
        : (owner['name'] ?? 'Owner');
    final propertyTitle = property['title'] ?? 'Property';
    final propertyId = property['_id']?.toString() ?? property['id']?.toString() ?? '';
    final lastText = conv['lastMessageText'] as String?;
    final conversationId = conv['_id']?.toString() ?? conv['id']?.toString();

    final propertyModel = PropertyModel.fromJson({
      '_id': propertyId,
      'title': property['title'] ?? 'Property',
      'description': property['description'] ?? '',
      'propertyType': property['propertyType'] ?? 'room',
      'rent': property['rent'] ?? 0,
      'deposit': property['deposit'],
      'address': property['address'] ?? '',
      'area': property['area'] ?? '',
      'city': property['city'] ?? '',
      'images': property['images'] ?? [],
      'amenities': property['amenities'] ?? [],
      'ownerId': owner,
      'ownerName': otherName,
      'ownerPhone': '',
      'isBrokerListed': property['brokerId'] != null,
    });

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.spacingMd),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            otherName[0].toUpperCase(),
            style: const TextStyle(
              color: AppColors.textOnPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(
          otherName,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              propertyTitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (lastText != null && lastText.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                lastText,
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatConversationScreen(
                property: propertyModel,
                conversationId: conversationId,
                ownerName: otherName,
              ),
            ),
          );
        },
      ),
    );
  }
}
