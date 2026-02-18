import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../viewmodels/coin_wallet_viewmodel.dart';
import 'coin_store_screen.dart';

/// Coin wallet screen — shows balance, free views, and unlock history.
class CoinWalletScreen extends StatefulWidget {
  const CoinWalletScreen({super.key});

  @override
  State<CoinWalletScreen> createState() => _CoinWalletScreenState();
}

class _CoinWalletScreenState extends State<CoinWalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoinWalletViewModel>().loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletVM = context.watch<CoinWalletViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CoinStoreScreen(),
                ),
              );
            },
            tooltip: 'Buy Coins',
          ),
        ],
      ),
      body: walletVM.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () => walletVM.loadWallet(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Balance Card ──
                    _buildBalanceCard(walletVM),

                    const SizedBox(height: AppConstants.spacingLg),

                    // ── Free Views Info ──
                    _buildFreeViewsCard(walletVM),

                    const SizedBox(height: AppConstants.spacingLg),

                    // ── Unlock History ──
                    Text(
                      'Unlock History',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: AppConstants.spacingMd),

                    if (walletVM.unlockedProperties.isEmpty)
                      _buildEmptyState()
                    else
                      ...walletVM.unlockedProperties.map((unlock) {
                        return _buildUnlockItem(unlock);
                      }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard(CoinWalletViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Coins',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            '${vm.coins}',
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 48,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CoinStoreScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_shopping_cart_outlined, size: 18),
            label: const Text('Buy More Coins'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeViewsCard(CoinWalletViewModel vm) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Free Property Views',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vm.freePropertyViewsRemaining} of 3 remaining',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          LinearProgressIndicator(
            value: vm.freePropertyViewsRemaining / 3,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockItem(Map<String, dynamic> unlock) {
    final property = unlock['propertyId'] as Map<String, dynamic>? ?? {};
    final wasFree = unlock['wasFree'] ?? false;
    final coinsSpent = unlock['coinsSpent'] ?? 0;
    final createdAt = unlock['createdAt'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: wasFree
                  ? AppColors.accent.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(
              wasFree ? Icons.free_breakfast_outlined : Icons.lock_open_outlined,
              color: wasFree ? AppColors.accent : AppColors.primary,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['title'] ?? 'Property',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${property['city'] ?? ''}, ${property['area'] ?? ''}',
                  style: AppTextStyles.bodySmall,
                ),
                if (createdAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(createdAt),
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (wasFree)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'FREE',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  '-$coinsSpent coins',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXxl),
      child: Column(
        children: [
          Icon(
            Icons.lock_outline,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'No properties unlocked yet',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            'Unlock properties to view full details',
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateString;
    }
  }
}
