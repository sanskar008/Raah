import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../auth/viewmodels/auth_viewmodel.dart';

/// Referral screen — shows the user's referral code, share options,
/// and stats (how many friends joined, coins earned).
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool _isLoading = true;
  String? _referralCode;
  int _referredCount = 0;
  int _coinsEarned = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReferralInfo();
  }

  Future<void> _loadReferralInfo() async {
    final authVM = context.read<AuthViewModel>();

    try {
      // ApiService may not be provided in some widget trees (screens access
      // repositories directly). Guard the lookup and fall back to cached
      // auth data when ApiService isn't available or the network call fails.
      ApiService apiService;
      try {
        apiService = context.read<ApiService>();
      } catch (err) {
        debugPrint(
          'ReferralScreen: ApiService provider not found, creating local instance.',
        );
        apiService = ApiService(storage: SecureStorageService());
      }
      debugPrint('ReferralScreen: requesting ${ApiEndpoints.referralInfo}');
      final response = await apiService.get(ApiEndpoints.referralInfo);
      debugPrint(
        'ReferralScreen: referral API response: ${response != null ? jsonEncode(response) : 'null'}',
      );
      if (!mounted) return;
      setState(() {
        _referralCode = response['referralCode']?.toString();
        _referredCount = (response['referredCount'] ?? 0) as int;
        _coinsEarned = (response['coinsEarnedFromReferrals'] ?? 0) as int;
        _isLoading = false;
      });
      debugPrint(
        'ReferralScreen: loaded referralCode=${_referralCode ?? 'null'}, referredCount=$_referredCount, coins=$_coinsEarned',
      );
    } catch (e) {
      // Detailed error logging for easier debugging
      debugPrint('ReferralScreen: failed to fetch referral info: $e');
      try {
        // print stack trace if available
        // ignore: avoid_print
        // (stack trace captured by logging system during runtime)
      } catch (_) {}
      if (!mounted) return;
      // Fallback to locally cached user data
      final user = authVM.user;
      debugPrint(
        'ReferralScreen: falling back to cached user: ${user != null ? jsonEncode(user.toJson()) : 'null'}',
      );
      setState(() {
        _referralCode = user?.referralCode;
        _referredCount = user?.referredCount ?? 0;
        _coinsEarned = (user?.referredCount ?? 0) * 5;
        _isLoading = false;
        _error = _referralCode == null
            ? 'Could not load referral info: ${e.toString()}'
            : null;
      });
    }
  }

  void _copyCode() {
    if (_referralCode == null) return;
    Clipboard.setData(ClipboardData(text: _referralCode!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Referral code copied!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareCode() {
    if (_referralCode == null) return;
    // Using share_plus would be ideal, but we don't have it in pubspec.
    // For now, copy to clipboard with a friendly message.
    Clipboard.setData(
      ClipboardData(
        text:
            'Join me on Raah — the best rental discovery app! Use my referral code $_referralCode when signing up to get started. 🏠',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share message copied to clipboard!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Refer & Earn'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero banner ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.spacingXl),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusLg,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.card_giftcard_rounded,
                          size: 52,
                          color: Colors.white,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          'Earn 5 Coins Per Referral',
                          style: AppTextStyles.h3.copyWith(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          'Share your code with friends. Every time someone signs up using your code, you earn 5 coins.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── Stats row ──
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          icon: Icons.people_outline,
                          value: '$_referredCount',
                          label: 'Friends Joined',
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: _statCard(
                          icon: Icons.toll_outlined,
                          value: '$_coinsEarned',
                          label: 'Coins Earned',
                          color: AppColors.accent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── Referral code box ──
                  Text('Your Referral Code', style: AppTextStyles.h4),
                  const SizedBox(height: AppConstants.spacingMd),

                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMd,
                        ),
                      ),
                      child: Text(
                        _error!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingLg,
                        vertical: AppConstants.spacingMd,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMd,
                        ),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _referralCode ?? '—',
                              style: AppTextStyles.h3.copyWith(
                                letterSpacing: 4,
                                color: AppColors.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            onPressed: _copyCode,
                            icon: const Icon(
                              Icons.copy_rounded,
                              color: AppColors.primary,
                            ),
                            tooltip: 'Copy code',
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppConstants.spacingLg),

                  // ── Share button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _referralCode != null ? _shareCode : null,
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: const Text('Share with Friends'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusMd,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppConstants.spacingXl),

                  // ── How it works ──
                  Text('How it works', style: AppTextStyles.h4),
                  const SizedBox(height: AppConstants.spacingMd),
                  _stepItem(
                    step: '1',
                    title: 'Share your code',
                    subtitle: 'Send your referral code to friends',
                  ),
                  _stepItem(
                    step: '2',
                    title: 'Friend signs up',
                    subtitle: 'They enter your code during registration',
                  ),
                  _stepItem(
                    step: '3',
                    title: 'You earn 5 coins',
                    subtitle: 'Coins are credited instantly to your account',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.h2.copyWith(color: color)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _stepItem({
    required String step,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
