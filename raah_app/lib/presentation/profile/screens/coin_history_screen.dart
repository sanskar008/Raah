import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_service.dart';

/// Coin history screen — lists all coin credits and debits,
/// including property unlocks, referral bonuses, and pack purchases.
class CoinHistoryScreen extends StatefulWidget {
  const CoinHistoryScreen({super.key});

  @override
  State<CoinHistoryScreen> createState() => _CoinHistoryScreenState();
}

class _CoinHistoryScreenState extends State<CoinHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  int _currentBalance = 0;
  int _freeViewsUsed = 0;
  int _freeViewsRemaining = 0;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final apiService = context.read<ApiService>();
    try {
      final response = await apiService.get(ApiEndpoints.coinHistory);
      if (!mounted) return;
      final txList = response['transactions'] as List<dynamic>? ?? [];
      setState(() {
        _currentBalance = (response['currentBalance'] ?? 0) as int;
        _freeViewsUsed = (response['freeViewsUsed'] ?? 0) as int;
        _freeViewsRemaining = (response['freeViewsRemaining'] ?? 0) as int;
        _transactions = txList
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load coin history';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Coin History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: AppTextStyles.bodyMedium))
          : Column(
              children: [
                // ── Summary cards ──
                Container(
                  color: AppColors.surface,
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.toll_rounded,
                          value: '$_currentBalance',
                          label: 'Current Balance',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.visibility_outlined,
                          value: '$_freeViewsUsed / 3',
                          label: 'Free Views Used',
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _summaryCard(
                          icon: Icons.lock_open_outlined,
                          value: '$_freeViewsRemaining',
                          label: 'Free Views Left',
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Transaction list ──
                Expanded(
                  child: _transactions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 56,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: AppConstants.spacingMd),
                              Text(
                                'No history available',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(AppConstants.spacingLg),
                          itemCount: _transactions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            return _transactionTile(_transactions[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: AppConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(color: color, fontSize: 15),
          ),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> tx) {
    final isCredit = tx['type'] == 'credit';
    final amount = (tx['amount'] ?? 0) as int;
    final reason = tx['reason']?.toString() ?? '';
    final balanceAfter = (tx['balanceAfter'] ?? 0) as int;
    final createdAt = tx['createdAt'] != null
        ? DateTime.tryParse(tx['createdAt'].toString())
        : null;

    // Property info (if unlocked)
    final propertyData = tx['propertyId'];
    final propertyTitle = propertyData is Map
        ? propertyData['title']?.toString()
        : null;

    final color = isCredit ? AppColors.success : AppColors.error;
    final icon = isCredit
        ? Icons.add_circle_outline_rounded
        : (amount == 0
              ? Icons.visibility_outlined
              : Icons.remove_circle_outline_rounded);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyTitle ?? reason,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (createdAt != null)
                  Text(
                    DateFormat(
                      'dd MMM yyyy, hh:mm a',
                    ).format(createdAt.toLocal()),
                    style: AppTextStyles.caption,
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount == 0 ? 'Free' : '${isCredit ? '+' : ''}$amount coins',
                style: AppTextStyles.bodySmall.copyWith(
                  color: amount == 0 ? AppColors.textSecondary : color,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('Balance: $balanceAfter', style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}
