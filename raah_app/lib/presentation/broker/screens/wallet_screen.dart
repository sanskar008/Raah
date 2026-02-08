import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/broker_viewmodel.dart';

/// Wallet screen — coin balance, transaction history, withdraw request.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      context.read<BrokerViewModel>().loadWallet(user?.id ?? '1');
    });
  }

  void _showWithdrawDialog() {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Withdraw Coins', style: AppTextStyles.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter the amount of coins to withdraw',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppConstants.spacingMd),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Amount',
                prefixIcon: Icon(Icons.monetization_on_outlined),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(ctx);
                final success = await context
                    .read<BrokerViewModel>()
                    .requestWithdrawal(amount);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        success
                            ? 'Withdrawal request submitted!'
                            : 'Withdrawal failed',
                      ),
                      backgroundColor:
                          success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brokerVM = context.watch<BrokerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: brokerVM.isWalletLoading
          ? const LoadingWidget(message: 'Loading wallet...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Balance Card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Available Balance',
                          style: AppTextStyles.label.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${brokerVM.coinBalance.toInt()} Coins',
                          style: AppTextStyles.h1.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _showWithdrawDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.radiusSm),
                              ),
                            ),
                            child: const Text('Withdraw'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── How Coins Work ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How Coins Work',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _coinInfoRow(
                            Icons.add_home, 'Earn 50 coins per listing'),
                        _coinInfoRow(
                            Icons.star, 'Bonus coins for verified listings'),
                        _coinInfoRow(Icons.account_balance,
                            'Withdraw to bank anytime'),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── Transaction History ──
                  Text('Transaction History', style: AppTextStyles.h4),
                  const SizedBox(height: AppConstants.spacingMd),

                  if (brokerVM.wallet?.transactions.isEmpty ?? true)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spacingXl),
                        child: Text(
                          'No transactions yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    )
                  else
                    ...brokerVM.wallet!.transactions.map((txn) {
                      final isEarn = txn.type == 'earn';
                      return Container(
                        margin: const EdgeInsets.only(
                            bottom: AppConstants.spacingSm),
                        padding:
                            const EdgeInsets.all(AppConstants.spacingMd),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radiusMd),
                          border:
                              Border.all(color: AppColors.cardBorder),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (isEarn
                                        ? AppColors.success
                                        : AppColors.error)
                                    .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isEarn
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isEarn
                                    ? AppColors.success
                                    : AppColors.error,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingMd),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    txn.description,
                                    style:
                                        AppTextStyles.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    txn.date.formatted,
                                    style: AppTextStyles.caption,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${isEarn ? '+' : '-'}${txn.amount.toInt()}',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isEarn
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _coinInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(text, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
