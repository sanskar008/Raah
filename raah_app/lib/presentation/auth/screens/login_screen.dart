import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'signup_screen.dart';

/// Login screen — phone number + OTP authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _otpSent = false;
  bool _isResendingOTP = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: AppConstants.animSlow,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.sendOTP(phone: _phoneController.text.trim());

    if (mounted) {
      if (success) {
        setState(() => _otpSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully! Use 123456 for demo.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Auto-focus OTP field
        FocusScope.of(context).requestFocus(FocusNode());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authVM.error ?? 'Failed to send OTP'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final authVM = context.read<AuthViewModel>();
    final success = await authVM.verifyOTP(
      phone: _phoneController.text.trim(),
      otp: _otpController.text.trim(),
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authVM.error ?? 'Invalid OTP'),
          backgroundColor: AppColors.error,
        ),
      );
    }
    // Navigation is handled by the app's auth state listener
  }

  Future<void> _resendOTP() async {
    setState(() => _isResendingOTP = true);
    await _handleSendOTP();
    setState(() => _isResendingOTP = false);
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),

                    // ── Logo / Brand ──
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusLg),
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: AppColors.textOnPrimary,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Text(AppConstants.appName, style: AppTextStyles.h1),
                          const SizedBox(height: AppConstants.spacingXs),
                          Text(
                            AppConstants.appTagline,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXxl),

                    // ── Welcome text ──
                    Text('Welcome back', style: AppTextStyles.h2),
                    const SizedBox(height: AppConstants.spacingXs),
                    Text(
                      _otpSent
                          ? 'Enter the OTP sent to your phone'
                          : 'Enter your phone number to continue',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXl),

                    // ── Phone Number Field ──
                    CustomTextField(
                      label: 'Phone Number',
                      hint: '9876543210',
                      controller: _phoneController,
                      validator: (v) => Validators.phone(v),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      enabled: !_otpSent,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                    ),

                    if (_otpSent) ...[
                      const SizedBox(height: AppConstants.spacingMd),

                      // ── OTP Field ──
                      CustomTextField(
                        label: 'OTP',
                        hint: '123456',
                        controller: _otpController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'OTP is required';
                          }
                          if (v.length != 6) {
                            return 'OTP must be 6 digits';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        onSubmitted: (_) => _handleVerifyOTP(),
                      ),

                      const SizedBox(height: AppConstants.spacingSm),

                      // ── Resend OTP ──
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _isResendingOTP ? null : _resendOTP,
                          child: _isResendingOTP
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Resend OTP',
                                  style: AppTextStyles.label.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacingSm),

                    // ── Action Button ──
                    CustomButton(
                      text: _otpSent ? 'Verify & Login' : 'Send OTP',
                      onPressed: _otpSent ? _handleVerifyOTP : _handleSendOTP,
                      isLoading: authVM.isLoading,
                    ),

                    const SizedBox(height: AppConstants.spacingLg),

                    // ── Demo Hint ──
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: AppConstants.spacingSm),
                          Expanded(
                            child: Text(
                              _otpSent
                                  ? 'Demo OTP: 123456 (works for any phone number)'
                                  : 'Enter your 10-digit phone number. Demo OTP will be 123456',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXl),

                    // ── Sign Up Link ──
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SignupScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppConstants.spacingXl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
