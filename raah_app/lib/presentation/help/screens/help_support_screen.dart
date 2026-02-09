import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';

/// Help & Support screen — FAQs, contact options, support resources.
/// User-friendly layout with expandable FAQ sections and quick contact actions.
class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I search for properties?',
      answer:
          'Use the search bar on the home screen to filter by area, rent range, and property type (Room/Flat). You can also use the filter button to adjust rent range.',
    ),
    FAQItem(
      question: 'How do I book a property visit?',
      answer:
          'Open any property detail page and tap the "Book Visit" button. Select your preferred date and time, then confirm your appointment.',
    ),
    FAQItem(
      question: 'How do brokers earn coins?',
      answer:
          'Brokers earn 50 coins for each property they successfully list on the platform. Coins can be withdrawn through the Wallet section.',
    ),
    FAQItem(
      question: 'Can I edit my property listing?',
      answer:
          'Yes! Go to your dashboard, find the property in "My Listings" or "My Properties", and tap to edit. You can update images, rent, description, and other details.',
    ),
    FAQItem(
      question: 'How do I cancel an appointment?',
      answer:
          'Go to your appointments section. For customers, you can cancel pending appointments. For owners, you can accept or reject visit requests.',
    ),
    FAQItem(
      question: 'What payment methods are accepted?',
      answer:
          'Currently, Raah is a discovery platform. Payment arrangements are made directly between customers and property owners/brokers.',
    ),
    FAQItem(
      question: 'How do I report a problem?',
      answer:
          'You can contact our support team via email at support@raah.com or use the "Contact Support" option below. We typically respond within 24 hours.',
    ),
    FAQItem(
      question: 'Is my personal information secure?',
      answer:
          'Yes! We use secure storage and encryption to protect your data. Your information is never shared with third parties without your consent. Read our Privacy Policy in Settings for more details.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Quick Help Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.help_outline_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Need Help?',
                    style: AppTextStyles.h3.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  Text(
                    'We\'re here to assist you',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // ── Contact Options ──
            Text(
              'Contact Us',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    onTap: () => _launchEmail(),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_outlined,
                    label: 'Call',
                    onTap: () => _launchPhone(),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingMd),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Chat',
                    onTap: () => _showChatDialog(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingXl),

            // ── FAQs Section ──
            Text(
              'Frequently Asked Questions',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ..._faqs.map((faq) => _FAQCard(faq: faq)),

            const SizedBox(height: AppConstants.spacingXl),

            // ── Additional Resources ──
            Text(
              'Resources',
              style: AppTextStyles.h4,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _ResourceCard(
              icon: Icons.video_library_outlined,
              title: 'Video Tutorials',
              subtitle: 'Watch step-by-step guides',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Video tutorials coming soon!'),
                  ),
                );
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            _ResourceCard(
              icon: Icons.article_outlined,
              title: 'User Guide',
              subtitle: 'Complete guide to using Raah',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('User guide coming soon!'),
                  ),
                );
              },
            ),

            const SizedBox(height: AppConstants.spacingXl),
          ],
        ),
      ),
    );
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@raah.com',
      query: 'subject=Raah App Support Request',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email: support@raah.com'),
          ),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+91-1800-123-4567');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Call: +91-1800-123-4567'),
          ),
        );
      }
    }
  }

  void _showChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Live Chat', style: AppTextStyles.h4),
        content: Text(
          'Live chat support is available Monday-Friday, 9 AM - 6 PM IST.\n\nOur team will respond to your message as soon as possible.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Live chat feature coming soon!'),
                ),
              );
            },
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}

/// FAQ item model.
class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

/// Expandable FAQ card.
class _FAQCard extends StatefulWidget {
  final FAQItem faq;

  const _FAQCard({required this.faq});

  @override
  State<_FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<_FAQCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ExpansionTile(
        title: Text(
          widget.faq.question,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(
          AppConstants.spacingMd,
          0,
          AppConstants.spacingMd,
          AppConstants.spacingMd,
        ),
        children: [
          Text(
            widget.faq.answer,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
        onExpansionChanged: (expanded) {
          setState(() => _isExpanded = expanded);
        },
        trailing: Icon(
          _isExpanded
              ? Icons.keyboard_arrow_up_rounded
              : Icons.keyboard_arrow_down_rounded,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Contact option card.
class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resource card.
class _ResourceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ResourceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
