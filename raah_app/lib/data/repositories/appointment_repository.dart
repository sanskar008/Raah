import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_service.dart';
import '../../domain/enums/appointment_status.dart';
import '../models/appointment_model.dart';

/// Appointment repository — handles booking, listing, status updates.
class AppointmentRepository {
  final ApiService _apiService;

  AppointmentRepository({required ApiService apiService}) : _apiService = apiService;

  // ── Book a visit ──
  Future<AppointmentModel> bookAppointment({
    required String propertyId,
    required DateTime date,
    required String time,
  }) async {
    final response = await _apiService.post(
      ApiEndpoints.bookAppointment,
      body: {
        'propertyId': propertyId,
        'date': date.toIso8601String(),
        'time': time,
      },
    );

    // Response format: { appointment: {...} }
    final appointmentData = response['appointment'] ?? response;
    return AppointmentModel.fromJson(appointmentData as Map<String, dynamic>);
  }

  // ── Get customer's appointments ──
  Future<List<AppointmentModel>> getCustomerAppointments({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get(
      ApiEndpoints.myAppointments,
      queryParams: queryParams,
    );

    // Response format: { appointments: [...], pagination: {...} }
    final appointmentsList = response['appointments'] as List<dynamic>? ?? [];
    return appointmentsList
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Get owner's incoming visit requests ──
  Future<List<AppointmentModel>> getOwnerAppointments({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (status != null) queryParams['status'] = status;

    final response = await _apiService.get(
      ApiEndpoints.receivedAppointments,
      queryParams: queryParams,
    );

    // Response format: { appointments: [...], pagination: {...} }
    final appointmentsList = response['appointments'] as List<dynamic>? ?? [];
    return appointmentsList
        .map((json) => AppointmentModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Accept appointment ──
  Future<AppointmentModel> acceptAppointment(String id) async {
    final response = await _apiService.post(
      ApiEndpoints.acceptAppointment(id),
    );

    // Response format: { appointment: {...} }
    final appointmentData = response['appointment'] ?? response;
    return AppointmentModel.fromJson(appointmentData as Map<String, dynamic>);
  }

  // ── Reject appointment ──
  Future<AppointmentModel> rejectAppointment(String id) async {
    final response = await _apiService.post(
      ApiEndpoints.rejectAppointment(id),
    );

    // Response format: { appointment: {...} }
    final appointmentData = response['appointment'] ?? response;
    return AppointmentModel.fromJson(appointmentData as Map<String, dynamic>);
  }

  // ── Update appointment status (accept/reject) - kept for backward compatibility ──
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    if (status == AppointmentStatus.accepted) {
      await acceptAppointment(id);
    } else if (status == AppointmentStatus.rejected) {
      await rejectAppointment(id);
    }
  }
}
