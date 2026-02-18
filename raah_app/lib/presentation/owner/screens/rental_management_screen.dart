import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../viewmodels/rental_viewmodel.dart';

/// Rental management screen — view active rentals and subscriptions.
class RentalManagementScreen extends StatefulWidget {
  const RentalManagementScreen({super.key});

  @override
  State<RentalManagementScreen> createState() => _RentalManagementScreenState();
}

class _RentalManagementScreenState extends State<RentalManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalViewModel>().loadMyRentals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rentalVM = context.watch<RentalViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Rentals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Properties'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: rentalVM.isLoading
          ? const LoadingWidget()
          : TabBarView(
              controller: _tabController,
              children: [
                // ── Properties Tab ──
                RefreshIndicator(
                  onRefresh: () => rentalVM.loadMyRentals(),
                  child: rentalVM.properties.isEmpty
                      ? _buildEmptyProperties()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.spacingLg),
                          itemCount: rentalVM.properties.length,
                          itemBuilder: (context, index) {
                            return _buildPropertyCard(
                              rentalVM.properties[index],
                            );
                          },
                        ),
                ),

                // ── History Tab ──
                RefreshIndicator(
                  onRefresh: () => rentalVM.loadMyRentals(),
                  child: rentalVM.subscriptions.isEmpty
                      ? _buildEmptyHistory()
                      : ListView.builder(
                          padding: const EdgeInsets.all(AppConstants.spacingLg),
                          itemCount: rentalVM.subscriptions.length,
                          itemBuilder: (context, index) {
                            return _buildSubscriptionCard(
                              rentalVM.subscriptions[index],
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final isActive = property['isActive'] ?? false;
    final daysRemaining = property['daysRemaining'] ?? 0;
    final rentalPeriodEnd = property['rentalPeriodEnd'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(
          color: isActive ? AppColors.success : AppColors.divider,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'] ?? 'Property',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${property['area'] ?? ''}, ${property['city'] ?? ''}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : 'EXPIRED',
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          if (isActive && daysRemaining > 0) ...[
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$daysRemaining days remaining',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (rentalPeriodEnd != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expires: ${_formatDate(rentalPeriodEnd)}',
                style: AppTextStyles.caption,
              ),
            ],
          ] else if (!isActive) ...[
            Text(
              'Rental period has expired',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final property = subscription['propertyId'] as Map<String, dynamic>? ?? {};
    final days = subscription['days'] ?? 0;
    final amount = subscription['amount'] ?? 0;
    final wasFree = subscription['wasFree'] ?? false;
    final startDate = subscription['startDate'] as String?;
    final endDate = subscription['endDate'] as String?;
    final createdAt = subscription['createdAt'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property['title'] ?? 'Property',
                      style: AppTextStyles.h4,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$days days rental period',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
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
                  '₹${amount.toStringAsFixed(0)}',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          if (startDate != null && endDate != null) ...[
            _buildInfoRow('Start', _formatDate(startDate)),
            const SizedBox(height: 4),
            _buildInfoRow('End', _formatDate(endDate)),
          ],
          if (createdAt != null) ...[
            const SizedBox(height: 4),
            _buildInfoRow('Purchased', _formatDate(createdAt)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  Widget _buildEmptyProperties() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'No properties found',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'No rental history',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}
