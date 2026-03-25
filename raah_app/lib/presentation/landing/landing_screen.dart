import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../auth/screens/login_screen.dart';

/// Visually appealing landing screen shown on app start.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) {
          final t = _bgController.value * 2 * math.pi;
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFF7FCFF),
                  const Color(0xFFEFF7FF),
                  const Color(0xFFFDFBFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _WavePainter(
                      progress: _bgController.value,
                      colors: [
                        const Color(0xFF7ED6FF).withValues(alpha: 0.30),
                        const Color(0xFF87A8FF).withValues(alpha: 0.22),
                        const Color(0xFFA3FFD6).withValues(alpha: 0.24),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: CustomPaint(painter: _TopGlowPainter(progress: t)),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 122,
                          height: 122,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 86,
                              height: 86,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacingLg),
                        Text(
                          AppConstants.appName,
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingSm),
                        Text(
                          AppConstants.appTagline,
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          'Discover verified rentals tailored to your city and budget.\n'
                          'Book visits, chat instantly, and unlock details with coins.\n'
                          'Your next home starts here with Raah.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.spacingXl),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openLogin(context),
                            icon: Transform.translate(
                              offset: Offset(2 + math.sin(t * 2.2) * 3, 0),
                              child: const Icon(
                                Icons.arrow_forward_rounded,
                                size: 20,
                              ),
                            ),
                            label: Text(
                              'Continue',
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 6,
                              shadowColor: AppColors.primary.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, __) =>
            FadeTransition(opacity: animation, child: const LoginScreen()),
        transitionsBuilder: (_, animation, __, child) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0.10, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );

          final scale = Tween<double>(
            begin: 0.985,
            end: 1,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

          return SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          );
        },
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final double progress;
  final List<Color> colors;

  _WavePainter({required this.progress, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress * 2 * math.pi;
    final heights = [
      size.height * 0.70,
      size.height * 0.76,
      size.height * 0.82,
    ];
    final amps = [26.0, 22.0, 18.0];

    for (var i = 0; i < 3; i++) {
      final path = Path()..moveTo(0, heights[i]);

      for (double x = 0; x <= size.width; x += 1) {
        final y =
            heights[i] +
            math.sin((x / size.width) * 2 * math.pi + p + (i * 0.9)) * amps[i];
        path.lineTo(x, y);
      }

      path
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();

      final paint = Paint()..color = colors[i];
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}

class _TopGlowPainter extends CustomPainter {
  final double progress;

  _TopGlowPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final c1 = Offset(
      size.width * 0.15 + math.sin(progress) * 20,
      size.height * 0.18,
    );
    final c2 = Offset(
      size.width * 0.82 + math.cos(progress * 0.9) * 18,
      size.height * 0.24,
    );

    final p1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF6BCBFF).withValues(alpha: 0.24),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: c1, radius: 140));

    final p2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFB86C).withValues(alpha: 0.18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: c2, radius: 170));

    canvas.drawCircle(c1, 140, p1);
    canvas.drawCircle(c2, 170, p2);
  }

  @override
  bool shouldRepaint(covariant _TopGlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
