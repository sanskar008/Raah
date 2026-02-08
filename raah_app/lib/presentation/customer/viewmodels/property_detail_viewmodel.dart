import 'package:flutter/material.dart';
import '../../../data/models/property_model.dart';
import '../../../data/models/appointment_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/appointment_repository.dart';

/// ViewModel for property detail + appointment booking.
class PropertyDetailViewModel extends ChangeNotifier {
  final PropertyRepository _propertyRepository;
  final AppointmentRepository _appointmentRepository;

  PropertyDetailViewModel({
    required PropertyRepository propertyRepository,
    required AppointmentRepository appointmentRepository,
  })  : _propertyRepository = propertyRepository,
        _appointmentRepository = appointmentRepository;

  // ── State ──
  PropertyModel? _property;
  bool _isLoading = false;
  bool _isBooking = false;
  String? _error;
  bool _bookingSuccess = false;

  // ── Getters ──
  PropertyModel? get property => _property;
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  String? get error => _error;
  bool get bookingSuccess => _bookingSuccess;

  // ── Load property details ──
  Future<void> loadProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _property = await _propertyRepository.getPropertyById(id);
    } catch (e) {
      _error = 'Failed to load property details';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ── Set property directly (from card tap) ──
  void setProperty(PropertyModel property) {
    _property = property;
    notifyListeners();
  }

  // ── Book appointment ──
  Future<bool> bookAppointment({
    required DateTime date,
    required String time,
    required String customerId,
    required String customerName,
    required String customerPhone,
    String? notes,
  }) async {
    if (_property == null) return false;

    _isBooking = true;
    _bookingSuccess = false;
    notifyListeners();

    try {
      await _appointmentRepository.bookAppointment(
        AppointmentModel(
          id: 'apt-${DateTime.now().millisecondsSinceEpoch}',
          propertyId: _property!.id,
          propertyTitle: _property!.title,
          propertyImage:
              _property!.imageUrls.isNotEmpty ? _property!.imageUrls[0] : '',
          customerId: customerId,
          customerName: customerName,
          customerPhone: customerPhone,
          ownerId: _property!.ownerId,
          ownerName: _property!.ownerName,
          scheduledDate: date,
          scheduledTime: time,
          notes: notes,
          createdAt: DateTime.now(),
        ),
      );
      _bookingSuccess = true;
      _isBooking = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to book appointment';
      _isBooking = false;
      notifyListeners();
      return false;
    }
  }
}
