import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Useful extensions used throughout the app.

extension StringExtension on String {
  /// Capitalize first letter
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}...';
}

extension DateTimeExtension on DateTime {
  /// Format: "12 Jan 2026"
  String get formatted => DateFormat('dd MMM yyyy').format(this);

  /// Format: "12 Jan 2026, 3:30 PM"
  String get formattedWithTime =>
      DateFormat('dd MMM yyyy, h:mm a').format(this);

  /// Format: "3:30 PM"
  String get timeFormatted => DateFormat('h:mm a').format(this);

  /// Format: "Mon, 12 Jan"
  String get shortFormatted => DateFormat('EEE, dd MMM').format(this);
}

extension NumberExtension on num {
  /// Format currency: ₹12,500
  String get toCurrency => '₹${NumberFormat('#,##0').format(this)}';

  /// Format: ₹12,500/mo
  String get toRent => '₹${NumberFormat('#,##0').format(this)}/mo';
}

extension ContextExtension on BuildContext {
  /// Quick access to theme
  ThemeData get theme => Theme.of(this);

  /// Quick access to text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Quick access to color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Screen size
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Screen width
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Screen height
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// Show snackbar
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(this).colorScheme.error : null,
      ),
    );
  }
}
