import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../profile/screens/profile_screen.dart';
import '../viewmodels/broker_viewmodel.dart';
import 'add_property_screen.dart';
import 'wallet_screen.dart';

/// Broker dashboard — shows uploaded properties, coin balance,
/// quick actions. Includes drawer for full navigation.
class BrokerDashboardScreen extends StatefulWidget {
  const BrokerDashboardScreen({super.key});

  @override
  State<BrokerDashboardScreen> createState() => _BrokerDashboardScreenState();
}

class _BrokerDashboardScreenState extends State<BrokerDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      final brokerVM = context.read<BrokerViewModel>();
      brokerVM.loadMyProperties();
      brokerVM.loadWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final brokerVM = context.watch<BrokerViewModel>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await brokerVM.loadMyProperties();
            await brokerVM.loadWallet();
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Row(
                    children: [
                      // Hamburger menu
                      GestureDetector(
                        onTap: () =>
                            _scaffoldKey.currentState?.openDrawer(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusSm),
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
                              'Hello, ${authVM.user?.name ?? 'Broker'}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Broker Dashboard',
                                style: AppTextStyles.h3),
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
                          backgroundColor: AppColors.accent,
                          child: Text(
                            (authVM.user?.name ?? 'B')[0].toUpperCase(),
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
              ),

              // ── Coins Card ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                  ),
                  child: _buildCoinsCard(brokerVM),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingLg),
              ),

              // ── Quick Actions ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _quickAction(
                          icon: Icons.add_home_rounded,
                          label: 'Add Property',
                          color: AppColors.primary,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AddPropertyScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _quickAction(
                          icon: Icons.account_balance_wallet_rounded,
                          label: 'Wallet',
                          color: AppColors.accent,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WalletScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingLg),
              ),

              // ── My Properties Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                  ),
                  child: Text('My Listings', style: AppTextStyles.h4),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingMd),
              ),

              // ── Properties List ──
              if (brokerVM.isLoading)
                const SliverFillRemaining(
                  child: LoadingWidget(
                      message: 'Loading properties...'),
                )
              else if (brokerVM.properties.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.home_work_outlined,
                    title: 'No properties listed yet',
                    subtitle:
                        'Start listing properties to earn coins',
                    actionText: 'Add Property',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddPropertyScreen(),
                        ),
                      );
                    },
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = brokerVM.properties[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spacingLg,
                          vertical: AppConstants.spacingXs,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                                AppConstants.radiusMd),
                            border: Border.all(
                                color: AppColors.cardBorder),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(
                                AppConstants.spacingMd),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusSm),
                              child: property.imageUrls.isNotEmpty
                                  ? Image.network(
                                      property.imageUrls[0],
                                      width: 64,
                                      height: 64,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                            ),
                            title: Text(
                              property.title,
                              style:
                                  AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  property.rent.toRent,
                                  style: AppTextStyles.priceSmall
                                      .copyWith(fontSize: 14),
                                ),
                                Text(
                                  '${property.area}, ${property.city}',
                                  style: AppTextStyles.bodySmall,
                                ),
                              ],
                            ),
                            trailing: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: property.isAvailable
                                    ? AppColors.success
                                        .withValues(alpha: 0.1)
                                    : AppColors.error
                                        .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(6),
                              ),
                              child: Text(
                                property.isAvailable
                                    ? 'Active'
                                    : 'Inactive',
                                style:
                                    AppTextStyles.caption.copyWith(
                                  color: property.isAvailable
                                      ? AppColors.success
                                      : AppColors.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: brokerVM.properties.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingXxl),
              ),
            ],
          ),
        ),
      ),

      // ── FAB: Add Property ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPropertyScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Property'),
      ),
    );
  }

  Widget _buildCoinsCard(BrokerViewModel brokerVM) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Coin Balance',
                  style: AppTextStyles.label.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
                brokerVM.isWalletLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        '${brokerVM.coinBalance.toInt()} Coins',
                        style: AppTextStyles.h2.copyWith(
                          color: Colors.white,
                        ),
                      ),
                const SizedBox(height: 4),
                Text(
                  'Earn 50 coins per listing',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius:
                  BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: const Icon(
              Icons.monetization_on_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
              BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.surfaceVariant,
      child: const Icon(Icons.image_outlined,
          color: AppColors.textHint),
    );
  }
}
