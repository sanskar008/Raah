import '../../domain/enums/appointment_status.dart';
import '../models/appointment_model.dart';

/// Appointment repository — handles booking, listing, status updates.
/// Uses dummy data; replace with API calls when backend is ready.
class AppointmentRepository {
  // In-memory list for demo (simulates API state)
  final List<AppointmentModel> _appointments = [
    AppointmentModel(
      id: 'apt-1',
      propertyId: '1',
      propertyTitle: 'Cozy Studio Apartment in Koramangala',
      propertyImage:
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400',
      customerId: '1',
      customerName: 'Demo User',
      customerPhone: '9876543210',
      ownerId: '1',
      ownerName: 'Rahul Sharma',
      scheduledDate: DateTime.now().add(const Duration(days: 2)),
      scheduledTime: '10:00 AM',
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
    ),
    AppointmentModel(
      id: 'apt-2',
      propertyId: '3',
      propertyTitle: 'Single Room in HSR Layout',
      propertyImage:
          'https://images.unsplash.com/photo-1555854877-bab0e564b8d5?w=400',
      customerId: '1',
      customerName: 'Demo User',
      customerPhone: '9876543210',
      ownerId: '1',
      ownerName: 'Rahul Sharma',
      scheduledDate: DateTime.now().add(const Duration(days: 4)),
      scheduledTime: '2:00 PM',
      status: AppointmentStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ── Book a visit ──
  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _appointments.add(appointment);
    return appointment;
  }

  // ── Get customer's appointments ──
  Future<List<AppointmentModel>> getCustomerAppointments(
      String customerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _appointments
        .where((a) => a.customerId == customerId)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  // ── Get owner's incoming visit requests ──
  Future<List<AppointmentModel>> getOwnerAppointments(String ownerId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _appointments
        .where((a) => a.ownerId == ownerId)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }

  // ── Update appointment status (accept/reject) ──
  Future<void> updateStatus(String id, AppointmentStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _appointments[index];
      _appointments[index] = AppointmentModel(
        id: old.id,
        propertyId: old.propertyId,
        propertyTitle: old.propertyTitle,
        propertyImage: old.propertyImage,
        customerId: old.customerId,
        customerName: old.customerName,
        customerPhone: old.customerPhone,
        ownerId: old.ownerId,
        ownerName: old.ownerName,
        scheduledDate: old.scheduledDate,
        scheduledTime: old.scheduledTime,
        status: status,
        notes: old.notes,
        createdAt: old.createdAt,
      );
    }
  }
}
