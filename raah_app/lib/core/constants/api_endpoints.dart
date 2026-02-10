/// Centralized API endpoint configuration.
class ApiEndpoints {
  ApiEndpoints._();

  // ── Base ──
  static const String baseUrl = 'https://raah-cqwp.onrender.com/api';

  // ── Auth ──
  static const String login = '$baseUrl/auth/login';
  static const String signup = '$baseUrl/auth/signup';
  static const String sendOTP = '$baseUrl/auth/send-otp';
  static const String verifyOTP = '$baseUrl/auth/verify-otp';
  static const String getMe = '$baseUrl/auth/me';

  // ── Properties ──
  static const String properties = '$baseUrl/properties';
  static String propertyById(String id) => '$baseUrl/properties/$id';
  static const String myProperties = '$baseUrl/properties/my';

  // ── Appointments ──
  static const String bookAppointment = '$baseUrl/appointments/book';
  static const String myAppointments = '$baseUrl/appointments/my';
  static const String receivedAppointments = '$baseUrl/appointments/received';
  static String acceptAppointment(String id) => '$baseUrl/appointments/$id/accept';
  static String rejectAppointment(String id) => '$baseUrl/appointments/$id/reject';

  // ── Wallet (Broker) ──
  static const String wallet = '$baseUrl/wallet';
  static const String walletWithdraw = '$baseUrl/wallet/withdraw';
}
