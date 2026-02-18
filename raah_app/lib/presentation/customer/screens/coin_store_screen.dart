import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../viewmodels/coin_store_viewmodel.dart';
import '../viewmodels/coin_wallet_viewmodel.dart';

/// Coin store screen — purchase coin packs.
class CoinStoreScreen extends StatefulWidget {
  const CoinStoreScreen({super.key});

  @override
  State<CoinStoreScreen> createState() => _CoinStoreScreenState();
}

class _CoinStoreScreenState extends State<CoinStoreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoinStoreViewModel>().loadCoinPacks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final storeVM = context.watch<CoinStoreViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Buy Coins'),
      ),
      body: storeVM.isLoading
          ? const LoadingWidget()
          : RefreshIndicator(
              onRefresh: () => storeVM.loadCoinPacks(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header ──
                    Text(
                      'Choose a Coin Pack',
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    Text(
                      'Unlock property details and explore more listings',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXl),

                    // ── Coin Packs ──
                    if (storeVM.coinPacks.isEmpty)
                      _buildEmptyState()
                    else
                      ...storeVM.coinPacks.map((pack) {
                        return _buildCoinPackCard(context, pack, storeVM);
                      }).toList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCoinPackCard(
    BuildContext context,
    pack,
    CoinStoreViewModel storeVM,
  ) {
    final isPopular = pack.bonusCoins > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isPopular ? AppColors.accent : AppColors.divider,
          width: isPopular ? 2 : 1,
        ),
        boxShadow: isPopular
            ? [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isPopular)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMd,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusLg),
                  topRight: Radius.circular(AppConstants.radiusLg),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'POPULAR',
                    style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppConstants.spacingLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monetization_on_rounded,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pack.name,
                            style: AppTextStyles.h4,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pack.totalCoins} coins',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (pack.bonusCoins > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '${pack.coins} + ${pack.bonusCoins} bonus',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '₹${pack.price.toStringAsFixed(0)}',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          '${(pack.price / pack.totalCoins).toStringAsFixed(2)} per coin',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: storeVM.isPurchasing
                          ? null
                          : () => _purchasePack(context, pack.id, storeVM),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: storeVM.isPurchasing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Buy Now'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePack(
    BuildContext context,
    String packId,
    CoinStoreViewModel storeVM,
  ) async {
    final success = await storeVM.purchaseCoinPack(packId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Coin pack purchased successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Refresh wallet if available
      final walletVM = context.read<CoinWalletViewModel>();
      walletVM.refreshWallet();

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(storeVM.error ?? 'Purchase failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXxl),
      child: Column(
        children: [
          Icon(
            Icons.store_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'No coin packs available',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
