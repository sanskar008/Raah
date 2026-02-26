import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/user_role.dart';
import '../../presentation/auth/viewmodels/auth_viewmodel.dart';
import '../../presentation/broker/screens/add_property_screen.dart';
import '../../presentation/broker/screens/wallet_screen.dart';
import '../../presentation/customer/screens/chat_list_screen.dart';
import '../../presentation/customer/screens/coin_wallet_screen.dart';
import '../../presentation/help/screens/help_support_screen.dart';
import '../../presentation/owner/screens/owner_appointments_screen.dart';
import '../../presentation/owner/screens/rental_management_screen.dart';
import '../../presentation/profile/screens/profile_screen.dart';
import '../../presentation/settings/screens/settings_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_text_styles.dart';

/// Reusable app drawer — adapts navigation items based on user role.
/// Shows profile header + role-specific menu items + sign out.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;

    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            // ── Profile Header ──
            _buildProfileHeader(context, authVM),

            const Divider(height: 1, color: AppColors.divider),

            // ── Navigation Items ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingSm,
                ),
                children: [
                  // Home / Dashboard — always present
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    label: user?.role == UserRole.customer
                        ? 'Home'
                        : 'Dashboard',
                    onTap: () => Navigator.pop(context),
                  ),

                  // ── Customer-specific items ──
                  if (user?.role == UserRole.customer) ...[
                    _DrawerItem(
                      icon: Icons.search_rounded,
                      label: 'Explore Properties',
                      onTap: () {
                        Navigator.pop(context);
                        // Already on home screen, just close drawer
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'My Wallet',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CoinWalletScreen(),
                          ),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chats',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatListScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  // ── Broker-specific items ──
                  if (user?.role == UserRole.broker) ...[
                    _DrawerItem(
                      icon: Icons.add_home_rounded,
                      label: 'Add Property',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddPropertyScreen(),
                          ),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.list_alt_rounded,
                      label: 'My Listings',
                      onTap: () => Navigator.pop(context), // Already on dashboard
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_rounded,
                      label: 'Wallet & Coins',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WalletScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  // ── Owner-specific items ──
                  if (user?.role == UserRole.owner) ...[
                    _DrawerItem(
                      icon: Icons.add_home_rounded,
                      label: 'Add Property',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddPropertyScreen(
                                showCoinsInfo: false),
                          ),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.list_alt_rounded,
                      label: 'My Properties',
                      onTap: () => Navigator.pop(context),
                    ),
                    _DrawerItem(
                      icon: Icons.event_note_rounded,
                      label: 'Appointments',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OwnerAppointmentsScreen(),
                          ),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.calendar_today_outlined,
                      label: 'My Rentals',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RentalManagementScreen(),
                          ),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chats',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ChatListScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                    ),
                    child: Divider(color: AppColors.divider),
                  ),

                  // ── Common items ──
                  _DrawerItem(
                    icon: Icons.person_outline_rounded,
                    label: 'My Profile',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Sign Out at bottom ──
            const Divider(height: 1, color: AppColors.divider),
            _DrawerItem(
              icon: Icons.logout_rounded,
              label: 'Sign Out',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation(context, authVM);
              },
            ),
            const SizedBox(height: AppConstants.spacingSm),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AuthViewModel authVM) {
    final user = authVM.user;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spacingLg,
          AppConstants.spacingLg,
          AppConstants.spacingLg,
          AppConstants.spacingMd,
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              backgroundColor: AppColors.primary,
              child: Text(
                (user?.name ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingMd),
            // Name, email, role
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'User',
                    style: AppTextStyles.h4.copyWith(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.email ?? '',
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _roleBadgeColor(user?.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      user?.role.label ?? 'User',
                      style: AppTextStyles.caption.copyWith(
                        color: _roleBadgeColor(user?.role),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow to profile
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Color _roleBadgeColor(UserRole? role) {
    switch (role) {
      case UserRole.customer:
        return AppColors.primary;
      case UserRole.broker:
        return AppColors.accent;
      case UserRole.owner:
        return AppColors.info;
      case null:
        return AppColors.textSecondary;
    }
  }

  void _showLogoutConfirmation(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign Out', style: AppTextStyles.h4),
        content: Text(
          'Are you sure you want to sign out?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authVM.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

/// Individual drawer menu item — with icon, label, and optional destructive styling.
class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    final iconColor = isDestructive ? AppColors.error : AppColors.textSecondary;

    return ListTile(
      leading: Icon(icon, color: iconColor, size: 22),
      title: Text(
        label,
        style: AppTextStyles.bodyMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: 0,
      ),
      visualDensity: const VisualDensity(vertical: -1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      hoverColor: AppColors.surfaceVariant,
    );
  }
}
