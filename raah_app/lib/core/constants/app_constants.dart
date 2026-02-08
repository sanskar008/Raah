/// App-wide constants: spacing, sizing, durations, strings.
class AppConstants {
  AppConstants._();

  // ── App Info ──
  static const String appName = 'Raah';
  static const String appTagline = 'Find your perfect stay';

  // ── Spacing ──
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ── Border Radius ──
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // ── Card ──
  static const double cardElevation = 0.0;
  static const double cardBorderWidth = 1.0;

  // ── Animation Durations ──
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 500);

  // ── Image ──
  static const double propertyCardImageHeight = 200.0;
  static const double propertyDetailImageHeight = 300.0;

  // ── Pagination ──
  static const int pageSize = 20;

  // ── Secure Storage Keys ──
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String roleKey = 'user_role';
}
