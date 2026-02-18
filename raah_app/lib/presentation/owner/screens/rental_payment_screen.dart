import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/property_model.dart';
import '../viewmodels/rental_viewmodel.dart';

/// Rental payment screen — purchase rental periods for properties.
class RentalPaymentScreen extends StatefulWidget {
  final PropertyModel property;

  const RentalPaymentScreen({
    super.key,
    required this.property,
  });

  @override
  State<RentalPaymentScreen> createState() => _RentalPaymentScreenState();
}

class _RentalPaymentScreenState extends State<RentalPaymentScreen> {
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RentalViewModel>().loadRentalPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentalVM = context.watch<RentalViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Purchase Rental Period'),
      ),
      body: rentalVM.isLoading
          ? const LoadingWidget()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Property Info ──
                  _buildPropertyCard(),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── Rental Plans ──
                  Text(
                    'Select Rental Period',
                    style: AppTextStyles.h3,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  if (rentalVM.rentalPlans.isEmpty)
                    _buildEmptyState()
                  else
                    ...rentalVM.rentalPlans.map((plan) {
                      return _buildPlanCard(context, plan, rentalVM);
                    }).toList(),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── Purchase Button ──
                  if (_selectedDays != null)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: rentalVM.isPurchasing
                            ? null
                            : () => _purchaseRental(context, rentalVM),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: rentalVM.isPurchasing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Purchase Rental Period'),
                      ),
                    ),

                  const SizedBox(height: AppConstants.spacingLg),

                  // ── Info ──
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingMd),
                    decoration: BoxDecoration(
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.accent,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.spacingMd),
                        Expanded(
                          child: Text(
                            'First property gets 7 days free!',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPropertyCard() {
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
          Text(
            widget.property.title,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.property.area}, ${widget.property.city}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context,
    plan,
    RentalViewModel rentalVM,
  ) {
    final isSelected = _selectedDays == plan.days;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays = plan.days;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.divider,
                  width: 2,
                ),
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: AppConstants.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                      plan.name,
                      style: AppTextStyles.h4,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    plan.description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${plan.price.toStringAsFixed(0)}',
                  style: AppTextStyles.h4.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXxl),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64,
            color: AppColors.textHint,
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            'No rental plans available',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseRental(
    BuildContext context,
    RentalViewModel rentalVM,
  ) async {
    if (_selectedDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a rental period'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final plan = rentalVM.rentalPlans.firstWhere((p) => p.days == _selectedDays);
    final isFree = plan.price == 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text(
          isFree
              ? 'Activate ${_selectedDays} days free rental period?'
              : 'Purchase ${_selectedDays} days rental period for ₹${plan.price.toStringAsFixed(0)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await rentalVM.purchaseRentalPeriod(
                propertyId: widget.property.id,
                days: _selectedDays!,
              );

              if (!mounted) return;

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFree
                          ? 'Free rental period activated!'
                          : 'Rental period purchased successfully!',
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(rentalVM.error ?? 'Purchase failed'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
