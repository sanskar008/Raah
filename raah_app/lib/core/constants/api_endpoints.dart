/// Centralized API endpoint configuration.
/// Replace baseUrl with your actual server URL.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base ──
  static const String baseUrl = 'https://api.raah.app/v1'; // TODO: Replace with actual URL

  // ── Auth ──
  static const String login = '$baseUrl/auth/login';
  static const String signup = '$baseUrl/auth/signup';
  static const String refreshToken = '$baseUrl/auth/refresh';
  static const String logout = '$baseUrl/auth/logout';

  // ── Properties ──
  static const String properties = '$baseUrl/properties';
  static String propertyById(String id) => '$baseUrl/properties/$id';
  static const String myProperties = '$baseUrl/properties/mine';
  static const String addProperty = '$baseUrl/properties';

  // ── Appointments ──
  static const String appointments = '$baseUrl/appointments';
  static String appointmentById(String id) => '$baseUrl/appointments/$id';
  static const String myAppointments = '$baseUrl/appointments/mine';
  static String updateAppointmentStatus(String id) =>
      '$baseUrl/appointments/$id/status';

  // ── Wallet (Broker) ──
  static const String wallet = '$baseUrl/wallet';
  static const String walletTransactions = '$baseUrl/wallet/transactions';
  static const String walletWithdraw = '$baseUrl/wallet/withdraw';

  // ── User ──
  static const String profile = '$baseUrl/user/profile';
  static const String updateProfile = '$baseUrl/user/profile';
}
