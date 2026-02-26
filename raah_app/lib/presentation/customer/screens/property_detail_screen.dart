import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../data/models/property_model.dart';
import '../../../domain/enums/user_role.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/property_detail_viewmodel.dart';
import '../viewmodels/coin_wallet_viewmodel.dart';
import '../widgets/image_carousel.dart';
import 'appointment_booking_screen.dart';
import 'chat_conversation_screen.dart';
import 'coin_wallet_screen.dart';

/// Property detail screen — full gallery, rent info, amenities, owner info.
/// Premium layout with elegant typography and spacing.
class PropertyDetailScreen extends StatefulWidget {
  final PropertyModel property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  late PropertyDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<PropertyDetailViewModel>();
    _viewModel.setProperty(widget.property);
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final isCustomer = authVM.userRole == UserRole.customer;
    final propertyVM = context.watch<PropertyDetailViewModel>();
    final property = propertyVM.property ?? widget.property;
    final isUnlocked = property.isUnlocked ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Collapsing Image Gallery ──
          SliverAppBar(
            expandedHeight: AppConstants.propertyDetailImageHeight,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: _buildBackButton(context),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ImageCarousel(
                    imageUrls: property.imageUrls,
                    height: AppConstants.propertyDetailImageHeight,
                  ),
                  // ── Lock overlay for customers ──
                  if (isCustomer && !isUnlocked)
                    Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.lock_outline,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: AppConstants.spacingMd),
                            Text(
                              'Unlock to view details',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingSm),
                            Text(
                              '2 coins required',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── Content ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title & Price Section ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            property.propertyType.label,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppConstants.spacingMd),

                        // Title
                        Text(property.title, style: AppTextStyles.h2),

                        const SizedBox(height: AppConstants.spacingSm),

                        // Location
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${property.address}, ${property.area}, ${property.city}',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppConstants.spacingLg),

                        // Rent & Deposit
                        Row(
                          children: [
                            Expanded(
                              child: _infoTile(
                                'Rent',
                                property.rent.toRent,
                                Icons.payments_outlined,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            if (property.deposit != null)
                              Expanded(
                                child: _infoTile(
                                  'Deposit',
                                  property.deposit!.toCurrency,
                                  Icons.account_balance_wallet_outlined,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingSm),

                  // ── Quick Stats ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    color: AppColors.surface,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (property.bedrooms != null)
                          _statItem(
                            Icons.bed_outlined,
                            '${property.bedrooms}',
                            'Bedroom',
                          ),
                        if (property.bathrooms != null)
                          _statItem(
                            Icons.bathtub_outlined,
                            '${property.bathrooms}',
                            'Bathroom',
                          ),
                        if (property.areaSqFt != null)
                          _statItem(
                            Icons.square_foot_outlined,
                            '${property.areaSqFt!.toInt()}',
                            'sq.ft',
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingSm),

                  // ── Description ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description', style: AppTextStyles.h4),
                        const SizedBox(height: AppConstants.spacingMd),
                        if (isCustomer && !isUnlocked)
                          _buildLockedContent()
                        else
                          Text(
                            property.description,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingSm),

                  // ── Amenities ──
                  if (property.amenities.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      color: AppColors.surface,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amenities', style: AppTextStyles.h4),
                          const SizedBox(height: AppConstants.spacingMd),
                          if (isCustomer && !isUnlocked)
                            _buildLockedContent()
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: property.amenities.map((amenity) {
                                return _amenityChip(amenity);
                              }).toList(),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppConstants.spacingSm),

                  // ── Owner / Inquiry & Chat ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.isBrokerListed
                              ? 'Listed by Broker'
                              : 'Property Owner',
                          style: AppTextStyles.h4,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                property.ownerName[0].toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.textOnPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: Text(
                                property.ownerName,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _openChatWithOwner(context, property),
                                icon: const Icon(Icons.question_answer_outlined, size: 18),
                                label: const Text('Inquiry'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(color: AppColors.primary),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _openChatWithOwner(context, property),
                                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                                label: const Text('Chat'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Spacer for bottom button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Book Visit Button ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Price summary
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.rent.toRent,
                      style: AppTextStyles.price,
                    ),
                    Text(
                      'Deposit: ${property.deposit?.toCurrency ?? 'N/A'}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // Unlock or Book button
              if (isCustomer && !isUnlocked)
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: propertyVM.isUnlocking
                        ? null
                        : () => _handleUnlock(context, propertyVM),
                    icon: Icon(
                      propertyVM.isUnlocking
                          ? null
                          : Icons.lock_open_outlined,
                      size: 18,
                    ),
                    label: Text(
                      propertyVM.isUnlocking
                          ? 'Unlocking...'
                          : 'Unlock (2 coins)',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AppointmentBookingScreen(
                            property: property,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.calendar_today_rounded, size: 18),
                    label: const Text('Book Visit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CircleAvatar(
        backgroundColor: Colors.black.withValues(alpha: 0.4),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(
                value,
                style: AppTextStyles.priceSmall.copyWith(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 26),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.h4.copyWith(fontSize: 16),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _amenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _amenityIcon(amenity),
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            amenity,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    final lower = amenity.toLowerCase();
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('ac')) return Icons.ac_unit;
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('gym')) return Icons.fitness_center;
    if (lower.contains('pool') || lower.contains('swim')) return Icons.pool;
    if (lower.contains('kitchen')) return Icons.kitchen;
    if (lower.contains('laundry') || lower.contains('wash')) {
      return Icons.local_laundry_service;
    }
    if (lower.contains('security')) return Icons.security;
    if (lower.contains('power') || lower.contains('backup')) return Icons.bolt;
    if (lower.contains('lift') || lower.contains('elevator')) {
      return Icons.elevator;
    }
    if (lower.contains('garden')) return Icons.park;
    if (lower.contains('meal') || lower.contains('food')) {
      return Icons.restaurant;
    }
    if (lower.contains('geyser')) return Icons.hot_tub;
    if (lower.contains('balcony')) return Icons.balcony;
    if (lower.contains('club')) return Icons.sports_tennis;
    if (lower.contains('play') || lower.contains('child')) {
      return Icons.child_care;
    }
    return Icons.check_circle_outline;
  }

  Widget _buildLockedContent() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_outline,
            color: AppColors.textHint,
            size: 24,
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              'Unlock property to view this content',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUnlock(
    BuildContext context,
    PropertyDetailViewModel propertyVM,
  ) async {
    final success = await propertyVM.unlockProperty();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Property unlocked successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Refresh wallet if available
      try {
        final walletVM = context.read<CoinWalletViewModel>();
        walletVM.refreshWallet();
      } catch (e) {
        // Wallet VM might not be available
      }
    } else {
      final error = propertyVM.error ?? 'Failed to unlock property';
      
      if (error.contains('Insufficient coins')) {
        // Show dialog to buy coins
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Insufficient Coins'),
            content: const Text(
              'You don\'t have enough coins to unlock this property. Would you like to buy more coins?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CoinWalletScreen(),
                    ),
                  );
                },
                child: const Text('Buy Coins'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _openChatWithOwner(BuildContext context, PropertyModel property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatConversationScreen(
          property: property,
          ownerName: property.ownerName,
        ),
      ),
    );
  }
}
