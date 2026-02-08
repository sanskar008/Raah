import 'package:flutter/material.dart';

/// Raah app color palette — premium, minimal, soft.
/// Inspired by Airbnb/Housing.com aesthetics.
class AppColors {
  AppColors._();

  // ── Primary palette ──
  static const Color primary = Color(0xFF1A3C5E);       // Deep navy
  static const Color primaryLight = Color(0xFF2D5F8A);   // Lighter navy
  static const Color primaryDark = Color(0xFF0F2440);    // Darker navy

  // ── Secondary / Accent ──
  static const Color accent = Color(0xFFE8913A);         // Warm amber/gold
  static const Color accentLight = Color(0xFFF5B06B);    // Light amber
  static const Color accentSoft = Color(0xFFFFF3E0);     // Very soft amber bg

  // ── Neutrals ──
  static const Color background = Color(0xFFF8F9FA);     // Warm off-white
  static const Color surface = Color(0xFFFFFFFF);         // Pure white
  static const Color surfaceVariant = Color(0xFFF1F3F5);  // Slightly grey
  static const Color divider = Color(0xFFE9ECEF);         // Soft grey divider

  // ── Text ──
  static const Color textPrimary = Color(0xFF212529);     // Near black
  static const Color textSecondary = Color(0xFF6C757D);   // Medium grey
  static const Color textHint = Color(0xFFADB5BD);        // Light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);   // White on dark bg

  // ── Status ──
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);

  // ── Shadows ──
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x14000000);

  // ── Card ──
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFF1F3F5);
}
