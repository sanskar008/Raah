import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/property_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/filter_bar.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';

/// Customer home feed — scrollable property cards with search & filters.
/// Inspired by Airbnb/Housing.com layout.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load properties on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadProperties();
    });
  }

  void _openPropertyDetail(PropertyModel property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(property: property),
      ),
    );
  }

  void _showRentFilterSheet() {
    final homeVM = context.read<HomeViewModel>();
    double minRent = homeVM.minRent ?? 0;
    double maxRent = homeVM.maxRent ?? 50000;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Text('Rent Range', style: AppTextStyles.h3),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                '₹${minRent.toInt()} - ₹${maxRent.toInt()}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spacingMd),
              RangeSlider(
                values: RangeValues(minRent, maxRent),
                min: 0,
                max: 100000,
                divisions: 20,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.divider,
                labels: RangeLabels(
                  '₹${minRent.toInt()}',
                  '₹${maxRent.toInt()}',
                ),
                onChanged: (values) {
                  setSheetState(() {
                    minRent = values.start;
                    maxRent = values.end;
                  });
                },
              ),
              const SizedBox(height: AppConstants.spacingLg),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        homeVM.clearFilters();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        homeVM.setRentRange(minRent, maxRent);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final homeVM = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingLg,
                AppConstants.spacingMd,
                AppConstants.spacingLg,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, ${authVM.user?.name ?? 'there'}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Find your perfect stay',
                          style: AppTextStyles.h3,
                        ),
                      ],
                    ),
                  ),
                  // Profile avatar
                  GestureDetector(
                    onTap: () => _showProfileMenu(context),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        (authVM.user?.name ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spacingMd),

            // ── Filters ──
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
              ),
              child: FilterBar(
                searchArea: homeVM.searchArea,
                selectedType: homeVM.selectedType,
                onSearchChanged: homeVM.setSearchArea,
                onTypeChanged: homeVM.setPropertyType,
                onFilterTap: _showRentFilterSheet,
                hasFilters: homeVM.hasFilters,
              ),
            ),

            const SizedBox(height: AppConstants.spacingSm),

            // ── Property List ──
            Expanded(
              child: _buildPropertyList(homeVM),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyList(HomeViewModel homeVM) {
    if (homeVM.isLoading) {
      return const ShimmerPropertyList();
    }

    if (homeVM.error != null) {
      return EmptyStateWidget(
        icon: Icons.error_outline_rounded,
        title: 'Something went wrong',
        subtitle: homeVM.error,
        actionText: 'Retry',
        onAction: homeVM.loadProperties,
      );
    }

    if (homeVM.properties.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: 'No properties found',
        subtitle: homeVM.hasFilters
            ? 'Try adjusting your filters'
            : 'New listings will appear here',
        actionText: homeVM.hasFilters ? 'Clear Filters' : null,
        onAction: homeVM.hasFilters ? homeVM.clearFilters : null,
      );
    }

    return RefreshIndicator(
      onRefresh: homeVM.loadProperties,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
          vertical: AppConstants.spacingSm,
        ),
        itemCount: homeVM.properties.length,
        itemBuilder: (context, index) {
          final property = homeVM.properties[index];
          return PropertyCard(
            property: property,
            onTap: () => _openPropertyDetail(property),
          );
        },
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primary,
              child: Text(
                (authVM.user?.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(authVM.user?.name ?? '', style: AppTextStyles.h4),
            Text(
              authVM.user?.email ?? '',
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text(
                'Sign Out',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(ctx);
                authVM.logout();
              },
            ),
            const SizedBox(height: AppConstants.spacingSm),
          ],
        ),
      ),
    );
  }
}
