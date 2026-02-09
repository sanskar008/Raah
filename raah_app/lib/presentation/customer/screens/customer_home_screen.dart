import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../data/models/property_model.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../profile/screens/profile_screen.dart';
import '../viewmodels/home_viewmodel.dart';
import '../widgets/filter_bar.dart';
import '../widgets/property_card.dart';
import 'property_detail_screen.dart';

/// Customer home feed — scrollable property cards with search & filters.
/// Includes drawer for navigation and profile access.
class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
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
                  // Hamburger menu
                  GestureDetector(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusSm),
                      ),
                      child: const Icon(
                        Icons.menu_rounded,
                        color: AppColors.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMd),
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
                  // Profile avatar → opens profile page
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
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
}
