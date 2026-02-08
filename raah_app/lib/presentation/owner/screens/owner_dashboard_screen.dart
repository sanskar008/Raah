import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';
import '../../broker/screens/add_property_screen.dart';
import '../viewmodels/owner_viewmodel.dart';
import 'owner_appointments_screen.dart';

/// Owner dashboard — owned properties + appointment summary.
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthViewModel>().user;
      final ownerVM = context.read<OwnerViewModel>();
      ownerVM.loadMyProperties(user?.id ?? '1');
      ownerVM.loadAppointments(user?.id ?? '1');
    });
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final ownerVM = context.watch<OwnerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ownerVM.loadMyProperties(authVM.user?.id ?? '1');
            await ownerVM.loadAppointments(authVM.user?.id ?? '1');
          },
          child: CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${authVM.user?.name ?? 'Owner'}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Owner Dashboard', style: AppTextStyles.h3),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showProfileMenu(context, authVM),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            (authVM.user?.name ?? 'O')[0].toUpperCase(),
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

              // ── Stats Cards ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingLg,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.home_work_rounded,
                          label: 'Properties',
                          value: '${ownerVM.properties.length}',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const OwnerAppointmentsScreen(),
                              ),
                            );
                          },
                          child: _statCard(
                            icon: Icons.calendar_today_rounded,
                            label: 'Pending Visits',
                            value: '${ownerVM.pendingAppointments}',
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddPropertyScreen(
                                    showCoinsInfo: false),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _quickAction(
                          icon: Icons.event_note_rounded,
                          label: 'Appointments',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const OwnerAppointmentsScreen(),
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
                  child: Text('My Properties', style: AppTextStyles.h4),
                ),
              ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingMd),
              ),

              // ── Properties List ──
              if (ownerVM.isLoading)
                const SliverFillRemaining(
                  child: LoadingWidget(message: 'Loading properties...'),
                )
              else if (ownerVM.properties.isEmpty)
                SliverFillRemaining(
                  child: EmptyStateWidget(
                    icon: Icons.home_outlined,
                    title: 'No properties yet',
                    subtitle: 'Add your first property to get started',
                    actionText: 'Add Property',
                    onAction: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddPropertyScreen(showCoinsInfo: false),
                        ),
                      );
                    },
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final property = ownerVM.properties[index];
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
                            border:
                                Border.all(color: AppColors.cardBorder),
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
                                      errorBuilder: (_, __, ___) =>
                                          _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                            ),
                            title: Text(
                              property.title,
                              style: AppTextStyles.bodyLarge.copyWith(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: property.isAvailable
                                    ? AppColors.success
                                        .withValues(alpha: 0.1)
                                    : AppColors.error
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                property.isAvailable
                                    ? 'Active'
                                    : 'Inactive',
                                style: AppTextStyles.caption.copyWith(
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
                    childCount: ownerVM.properties.length,
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppConstants.spacingXxl),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddPropertyScreen(showCoinsInfo: false),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Property'),
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppConstants.spacingMd),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
      child: const Icon(Icons.image_outlined, color: AppColors.textHint),
    );
  }

  void _showProfileMenu(BuildContext context, AuthViewModel authVM) {
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
                (authVM.user?.name ?? 'O')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            Text(authVM.user?.name ?? '', style: AppTextStyles.h4),
            Text(authVM.user?.email ?? '', style: AppTextStyles.bodySmall),
            const SizedBox(height: 4),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Room Owner',
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            ListTile(
              leading:
                  const Icon(Icons.logout_rounded, color: AppColors.error),
              title: Text(
                'Sign Out',
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
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
