import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/enums/user_role.dart';
import '../auth/viewmodels/auth_viewmodel.dart';
import '../auth/screens/login_screen.dart';
import '../customer/screens/customer_home_screen.dart';
import '../broker/screens/broker_dashboard_screen.dart';
import '../owner/screens/owner_dashboard_screen.dart';

/// App router — handles role-based navigation.
/// Listens to auth state and routes to the correct dashboard.
class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    // Show loading while checking persisted auth
    if (!authVM.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Not logged in → Login
    if (!authVM.isLoggedIn) {
      return const LoginScreen();
    }

    // Logged in → Route by role
    return _buildDashboard(authVM.userRole!);
  }

  /// Returns the correct dashboard based on user role.
  Widget _buildDashboard(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const CustomerHomeScreen();
      case UserRole.broker:
        return const BrokerDashboardScreen();
      case UserRole.owner:
        return const OwnerDashboardScreen();
    }
  }
}
